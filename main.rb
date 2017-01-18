require "google_drive"

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
    value = value.gsub("\'", "\\\'")
    i = 0

    value.gsub!(/\{.[^\}]*-([0-9]+)\}/) { |not_needed| val = "%#{$1}$s" }

    return value
end

def transformValueToAndroid (value)
    value = value.gsub("\n", "\\n")
    value = value.gsub("\"", "\\\"")
    value = value.gsub("\'", "\\\'")
    i = 0

    value.gsub!(/\{.[^\}]*-([0-9]+)\}/) { |not_needed| val = "%#{$1}$@" }

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
        stringResult =  stringResult + "    <string name=\"" + key + "\">" + transformValueToAndroid(value) + "</string>\n"
    end
    stringResult += "</resources>\n"

    return stringResult
end

session = GoogleDrive::Session.from_config("config.json")
spreadsheet = session.spreadsheet_by_key('1jKaSBFtZ_70qm3crM5saKQoC___M7PT1eQhTthFw88A')
spreadsheet.worksheets.each do |worksheet|
    if (worksheet.title == 'iOS Export')
        map = createLocalisationMap(worksheet)
        data = exportToStrings(map)
        writeToFile("ios.strings", data)
    end
    if (worksheet.title == 'Android Export')
        map = createLocalisationMap(worksheet)
        data = exportToXML(map)
        writeToFile("android.xml", data)
    end
end
