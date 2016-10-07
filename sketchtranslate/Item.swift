//
//  Item.swift
//  sketchtranslate
//
//  Created by Charles Vu on 31/08/2016.
//  Copyright © 2016 Charles Vu. All rights reserved.
//

import Foundation

class Item
{
    var value = ""
    var screens = Array<String>()

    init(value : Dictionary<String, AnyObject>)
    {
        self.value = value["value"] as! String
        self.screens = value["screens"] as! Array<String>
    }

    func toAndroid() -> String
    {
        var androidReplacedValue = value.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\'", with: "\\\'").replacingOccurrences(of: "\"", with: "\\\"")
        var androidVariableIndex = 1
        while let range = androidReplacedValue.range(of: "\\{[^}]+\\}",
                                                             options: .regularExpression)
        {
            let replacedString = String(format: "%%%d$s", arguments: [androidVariableIndex])
            androidVariableIndex += 1
            androidReplacedValue.replaceSubrange(range, with: replacedString)
        }

        return androidReplacedValue

    }

    func toiOS() -> String
    {
        var iosReplacedValue = value.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\'", with: "\\\'").replacingOccurrences(of: "\"", with: "\\\"")
        var iosVariableIndex = 1
        while let range = iosReplacedValue.range(of: "\\{[^}]+\\}",
                                                         options: .regularExpression)
        {
            let replacedString = String(format: "%%%d$@", arguments: [iosVariableIndex])
            iosVariableIndex += 1
            iosReplacedValue.replaceSubrange(range, with: replacedString)
        }

        return iosReplacedValue

    }

}
