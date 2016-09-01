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
    enum ComparaisonResult
    {

    }

    var value = ""
    var screens = Array<String>()

    init(value : Dictionary<String, AnyObject>)
    {
        self.value = value["value"] as! String
        self.screens = value["screens"] as! Array<String>
    }

    func toAndroid() -> String
    {
        var androidReplacedValue = value.stringByReplacingOccurrencesOfString("\n", withString: "\\n").stringByReplacingOccurrencesOfString("\'", withString: "\\\'").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        var androidVariableIndex = 1
        while let range = androidReplacedValue.rangeOfString("\\{[^}]+\\}",
                                                             options: .RegularExpressionSearch)
        {
            let replacedString = String(format: "%%%d$s", arguments: [androidVariableIndex])
            androidVariableIndex += 1
            androidReplacedValue.replaceRange(range, with: replacedString)
        }

        return androidReplacedValue

    }

    func toiOS() -> String
    {
        var iosReplacedValue = value.stringByReplacingOccurrencesOfString("\n", withString: "\\n").stringByReplacingOccurrencesOfString("\'", withString: "\\\'").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        var iosVariableIndex = 1
        while let range = iosReplacedValue.rangeOfString("\\{[^}]+\\}",
                                                         options: .RegularExpressionSearch)
        {
            let replacedString = String(format: "%%%d$@", arguments: [iosVariableIndex])
            iosVariableIndex += 1
            iosReplacedValue.replaceRange(range, with: replacedString)
        }

        return iosReplacedValue

    }

}
