#!/home/ubuntu/.rvm/rubies/ruby-2.4.0/bin/ruby
# Config is required to communicate with Google Drive.
# This should be in a file on disk, provided by DRIVE_CONFIG environment variable
# If this is not set, config.json from current dir is used
#
# Must be called with a single parameter, the id of the
# spreadsheet on Google Drive.
# Results are placed in results directory.

require "google_drive"

def writeToFile(name, data)
  File.write(name, data)
end

drive_config_path = ENV["DRIVE_CONFIG"]
if (drive_config_path == nil)
  drive_config_path = "config.json"
end

$whiteLabels=["postofficeid", "smartid"]

def createLocalisationMap(worksheet)
  whiteLabelsColumnName=["PO Value", "SmartID Value"]


  yotiResult = Hash.new
  whiteLabelResult = []
  $whiteLabels.each {|whiteLabel| whiteLabelResult.push(Hash.new) }

  localizationKeyIndex = 0
  yotiValueIndex = 0
  whiteLabelIndicies = []
  $whiteLabels.each {|whiteLabel| whiteLabelIndicies.push(0) }

  # Find the Key and Value column indexes
  (1..worksheet.num_cols).each do |col|
    if worksheet[1, col] == "Localisation Key"
      localizationKeyIndex = col
    end
    if worksheet[1, col] == "Localisation Value"
      yotiValueIndex = col
    end
    $whiteLabels.each_with_index do |whiteLabel, index|
      if worksheet[1, col] == whiteLabelsColumnName[index]
        whiteLabelIndicies[index] = col
      end
    end
  end

  # Create the map [key:value]
  (2..worksheet.num_rows).each do |row|
    key = worksheet[row, localizationKeyIndex]
    yotiValue = worksheet[row, yotiValueIndex]
    whiteLabelValues = []
    whiteLabelIndicies.each {|whiteLabelIndex| whiteLabelValues.push(worksheet[row, whiteLabelIndex]) }

    # Yoti copy
    if (!key.empty?)
      yotiResult[key] = yotiValue
    end
    
    # White label copy
    whiteLabelValues.each_with_index do |whiteLabelValue, index|
      if (!key.empty? && !whiteLabelValue.empty?)
        whiteLabelKey = key + "#" + $whiteLabels[index] + "#"
        if whiteLabelValue == "$NO_VALUE"
          whiteLabelResult[index][whiteLabelKey] = ""
        else
          whiteLabelResult[index][whiteLabelKey] = whiteLabelValue
        end
      end
    end
  end

  results = [yotiResult]
  whiteLabelResult.each{|result| results.push(result) }
  return results
end

def transformValueToIOS(value)
  value = value.gsub("\n", "\\n")
  value = value.gsub("\"", "\\\"")
  value = value.gsub("\'", "\\\\'")
  value = value.gsub("%", "\%%")

  value.gsub!(/\{.[^\}]*-([0-9]+)\}/) { |not_needed| val = "%#{$1}$@" }

  return value
end

def transformValueToAndroid(value)
  value = value.gsub("\"", "\\\"")
  value = value.gsub("  “", "\\\"")
  value = value.gsub("\'", "\\\\'")
  value = value.gsub("’", "\\\\'")
  value = value.gsub("’", "\\\\'")
  value = value.gsub("  ‘", "\\\\'")

  value = value.gsub("‘", "\\\\'")
  value = value.gsub("“", "\\\"")
  value = value.gsub("&", "&amp;")
  value = value.gsub("…", "&#8230;")
  value = value.gsub("%", "\%%")

  value.gsub!(/\{.[^\}]*-([0-9]+)\}/) { |not_needed| val = "%#{$1}$s" }

  return value
end

def transformValueToAndroidAfterXML(value)
  if (value.include? "•")
    value = value.sub("•", "<ul><li>")
    value = value.gsub("\n•", "</li>\n<li>")
    value = value.gsub("</string>", "</li></ul></string>")
  end

  value = value.gsub("\n", "\\n")

  return value
end

def exportToStrings(map)
  keys = map.keys.sort!

  stringResult = ""
  keys.each do |key|
    value = map[key]

    stringResult = stringResult + "\"" + key + "\" = \"" + transformValueToIOS(value) + "\";\n"
  end

  return stringResult
end

def exportToXML(map)
  keys = map.keys.sort!

  stringResult = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
  stringResult += "<resources>\n"

  keys.each do |key|
    value = map[key]
    newLine = "    <string name=\"" + key + "\">" + transformValueToAndroid(value) + "</string>"
    newLine = transformValueToAndroidAfterXML(newLine) + "\n"
    stringResult = stringResult + newLine
  end
  stringResult += "</resources>\n"

  return stringResult
end

def generateIOSFile(fileName, map)
  data = exportToStrings(map)
  writeToFile(fileName, data)
end

def generateAndroidFile(fileName, map)
  data = exportToXML(map)
  writeToFile(fileName, data)
end

spreadsheetKey = ARGV[0]
isRelease = ARGV[1]
if spreadsheetKey || isRelease == nil
  puts "Script called with wrong number of parameters"
  exit 1
end

puts "Reading config from " + drive_config_path
session = GoogleDrive::Session.from_config(drive_config_path)

spreadsheet = session.spreadsheet_by_key(spreadsheetKey)
spreadsheet.worksheets.each do |worksheet|
  if (worksheet.title == "iOS Export")

    puts "Checking iOS Export"

    resultsMaps = createLocalisationMap(worksheet)
    if isRelease = true
        generateIOSFile("results/ios.strings", resultsMaps[0])
    elsif
        generateIOSFile("results/ios.master.strings", resultsMaps[0])
    end

    puts "iOS Yoti written"

    resultsMaps.each_with_index do |resultsMap, index|
    if index != 0
      if isRelease = true
          generateIOSFile("results/ios_" + $whiteLabels[index - 1] + ".strings", resultsMap)
          puts "iOS #{$whiteLabels[index - 1]} written"
      elsif
          generateIOSFile("results/ios_master_" + $whiteLabels[index - 1] + ".strings", resultsMap)
          puts "iOS #{$whiteLabels[index - 1]} written"
      end
    end
  elsif (worksheet.title == "Android Export")

    puts "Checking Android Export"

    resultsMaps = createLocalisationMap(worksheet)
    if isRelease = true
        generateAndroidFile("results/strings.xml", resultsMaps[0])
    elsif
        generateAndroidFile("results/master_strings.xml", resultsMaps[0])
    end

    puts "Android Yoti written"

    resultsMaps.each_with_index do |resultsMap, index|
      if index != 0
        if isRelease = true
            generateAndroidFile("results/master_strings_" + $whiteLabels[index - 1] + ".xml", resultsMap)
            puts "Android #{$whiteLabels[index - 1]} written"
        elsif
            generateAndroidFile("results/master_strings_" + $whiteLabels[index - 1] + ".xml", resultsMap)
            puts "Android #{$whiteLabels[index - 1]} written"
      end
    end
  end
end
