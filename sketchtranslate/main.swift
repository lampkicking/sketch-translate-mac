//
//  main.swift
//  sketchtranslate
//
//  Created by Charles Vu on 01/10/2015.
//  Copyright © 2015 Charles Vu. All rights reserved.
//

import Foundation

enum Platform : String
{
    case iOS = "iOS"
    case Android = "Android"
}

let cli = CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s
    case .OptionHelp:
        str = s.blue
    default:
        str = s
    }

    return cli.defaultFormat(str, type: type)
}

let newPath = StringOption(shortFlag: "n", longFlag: "new", required: true,
                            helpMessage: "Path to the new file.")
let oldPath = StringOption(shortFlag: "o", longFlag: "old", required: true,
                          helpMessage: "Path to the old file.")

let platform = EnumOption<Platform>(shortFlag: "p", longFlag: "platform", required: true,
                                    helpMessage: "Platform to build the files iOS or Android.")

cli.addOptions(newPath, oldPath, platform)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let arguments = Process.arguments

let newDataJson = try NSJSONSerialization.JSONObjectFromFile(newPath.value!)
let oldDataJson = try NSJSONSerialization.JSONObjectFromFile(oldPath.value!)


var newItems = Dictionary<String, Item>()
var deletedItems = oldDataJson
var changedItems = Dictionary<String, Item>()

var andoridFile = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
andoridFile += "<resources>\n"

var iOSFile = ""

for (key, value) in newDataJson
{
    let newItem = Item(value: value)

    if let oldValue = oldDataJson[key]
    {
        deletedItems.removeValueForKey(key)

        let oldItem = Item(value: oldValue)
        if oldItem.value != newItem.value
        {
            changedItems[key] = newItem
        }

        var androidReplacedValue = newItem.toAndroid()
        var iosReplacedValue = newItem.toiOS()

        andoridFile += String(format: "    <!-- %@ -->\n", arguments: [newItem.screens.joinWithSeparator(" ")])
        andoridFile += String(format: "    <string name=\"%@\">%@</string>\n", arguments: [key, androidReplacedValue])

        iOSFile += String(format: "// %@\n", arguments: [newItem.screens.joinWithSeparator(" ")])
        iOSFile += String(format: "\"%@\" = \"%@\";\n", arguments: [key, iosReplacedValue])

    }
    else
    {
        // We found a new key that didn't exist in the old file
        newItems[key] = newItem
    }
}

if newItems.count > 0
{
    andoridFile += String("\n\n\n    <!-- New Items that didn't existed before -->\n")
    iOSFile += String("\n\n\n// New Items that didn't existed before\n")
    print("New Keys : ".blue)

    for (key, item) in newItems
    {
        var androidReplacedValue = item.toAndroid()
        var iosReplacedValue = item.toiOS()

        andoridFile += String(format: "    <!-- %@ -->\n", arguments: [item.screens.joinWithSeparator(" ")])
        andoridFile += String(format: "    <string name=\"%@\">%@</string>\n", arguments: [key, androidReplacedValue])

        iOSFile += String(format: "// %@\n", arguments: [item.screens.joinWithSeparator(" ")])
        iOSFile += String(format: "\"%@\" = \"%@\";\n", arguments: [key, iosReplacedValue])

        print("    " + key.magenta + " on screen named : ".blue + item.screens.joinWithSeparator(", ").green)

    }
}


if deletedItems.count > 0
{
    andoridFile += String("\n\n\n    <!-- Deleted Items that existed before -->\n")
    iOSFile += String("\n\n\n// Deleted Items that existed before\n")
    print("Deleted Keys : ".blue)

    for (key, value) in deletedItems
    {
        let oldItem = Item(value: value)

        var androidReplacedValue = oldItem.toAndroid()
        var iosReplacedValue = oldItem.toiOS()

        andoridFile += String(format: "    <!-- %@ -->\n", arguments: [oldItem.screens.joinWithSeparator(", ")])
        andoridFile += String(format: "    <string name=\"%@\">%@</string>\n", arguments: [key, androidReplacedValue])

        iOSFile += String(format: "// %@\n", arguments: [oldItem.screens.joinWithSeparator(", ")])
        iOSFile += String(format: "\"%@\" = \"%@\";\n", arguments: [key, iosReplacedValue])

        print("    " + key.magenta + " on screen named : ".blue + oldItem.screens.joinWithSeparator(", ").bold.red)
    }
}

for (key, value) in changedItems
{
    print("Modified Copy : ".blue)

    print("    " + key.magenta + " was : ".blue + value.value.red + " is now ".blue + value.value.green)
}

andoridFile += "</resources>"

try andoridFile.writeToFile("strings.xml", atomically: true, encoding: NSUTF8StringEncoding)
try iOSFile.writeToFile("Localizable.strings", atomically: true, encoding: NSUTF8StringEncoding)
