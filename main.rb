#!/home/ubuntu/.rvm/rubies/ruby-2.4.0/bin/ruby

require "google_drive"

drive_config_path=ENV['DRIVE_CONFIG']
if (drive_config_path == nil)
    drive_config_path = 'config.json'
end

def createLocalisationMap (worksheet)
    result = Hash.new

    keyIndex = 0
    valueIndex = 0
    # Find the Key and Value column indexes

    (1..worksheet.num_cols).each do |col|
        if worksheet[1, col] == "Localisation Key"
            keyIndex = col
        end
        if worksheet[1, col] == "Localisation Value"
            valueIndex = col
        end
    end

    # Create the map [key:value]
    (1..worksheet.num_rows).each do |row|
        key = worksheet[row, keyIndex]
        value = worksheet[row, valueIndex]
        result[key] = value
    end

    return result
end

def writeToFile(name, data)
    File.write(name, data)
end

def transformValueToIOS (value)
    value = value.gsub("\n", "\\n")
    value = value.gsub("\"", "\\\"")
    value = value.gsub("\'", "\\\\'")

    value.gsub!(/\{.[^\}]*-([0-9]+)\}/) { |not_needed| val = "%#{$1}$@" }

    return value
end

def transformValueToAndroid (value)
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

    value.gsub!(/\{.[^\}]*-([0-9]+)\}/) { |not_needed| val = "%#{$1}$s" }

    return value
end

def transformValueToAndroidAfterXML (value)
    if(value.include? "•")
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

        stringResult =  stringResult + "\"" + key + "\" = \"" + transformValueToIOS(value) + "\";\n"
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
        stringResult =  stringResult + newLine
    end
    stringResult += "</resources>\n"

    return stringResult
end

puts "Reading config from " + drive_config_path
session = GoogleDrive::Session.from_config(drive_config_path)
#spreadsheet = session.spreadsheet_by_key('1jKaSBFtZ_70qm3crM5saKQoC___M7PT1eQhTthFw88A')
spreadsheet = session.spreadsheet_by_key('1AdpkM6nO2TfFUU3BFZfyIyiiVLPtQUqfokWWJPOWODc')
spreadsheet.worksheets.each do |worksheet|
    if (worksheet.title == 'iOS Export')
        map = createLocalisationMap(worksheet)
        data = exportToStrings(map)
        writeToFile("ios.strings", data)
    end
    if (worksheet.title == 'Android Export')
        map = createLocalisationMap(worksheet)
        data = exportToXML(map)
        writeToFile("strings.xml", data)
    end
end
