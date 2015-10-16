//
//  main.swift
//  sketchtranslate
//
//  Created by Charles Vu on 01/10/2015.
//  Copyright © 2015 Charles Vu. All rights reserved.
//

import Foundation


let arguments = Process.arguments
let filename = arguments[1]

let content = try String(contentsOfFile: filename)

var data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
var error: NSError?

let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! Dictionary<String, String>


var andoridFile = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
andoridFile += "<resources>\n"

var iOSFile = ""

for key in json.keys
{
    let value = json[key]!
    var androidReplacedValue = value.stringByReplacingOccurrencesOfString("\n", withString: "\\n").stringByReplacingOccurrencesOfString("\'", withString: "\\\'").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
    var iosReplacedValue = value.stringByReplacingOccurrencesOfString("\n", withString: "\\n").stringByReplacingOccurrencesOfString("\'", withString: "\\\'").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")

    var androidVariableIndex = 1
    while let range = androidReplacedValue.rangeOfString("\\{[^}]+\\}",
        options: .RegularExpressionSearch)
    {
        let replacedString = String(format: "%%%d$s", arguments: [androidVariableIndex++])
        androidReplacedValue.replaceRange(range, with: replacedString)
    }
    
    var iosVariableIndex = 1
    while let range = iosReplacedValue.rangeOfString("\\{[^}]+\\}",
        options: .RegularExpressionSearch)
    {
        let replacedString = String(format: "%%%d$@", arguments: [iosVariableIndex++])
        iosReplacedValue.replaceRange(range, with: replacedString)
    }

    andoridFile += String(format: "    <string name=\"%@\">%@</string>\n", arguments: [key, androidReplacedValue])

    iOSFile += String(format: "\"%@\" = \"%@\";\n", arguments: [key, iosReplacedValue])

}

andoridFile += "</resources>"

try andoridFile.writeToFile("strings.xml", atomically: true, encoding: NSUTF8StringEncoding)
try iOSFile.writeToFile("Localizable.strings", atomically: true, encoding: NSUTF8StringEncoding)