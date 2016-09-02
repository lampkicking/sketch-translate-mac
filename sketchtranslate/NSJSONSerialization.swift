//
//  File.swift
//  sketchtranslate
//
//  Created by Charles Vu on 01/09/2016.
//  Copyright © 2016 Charles Vu. All rights reserved.
//

import Foundation

extension NSJSONSerialization
{
    class func JSONObjectFromFile(filePath : String) -> Dictionary<String, Dictionary<String, AnyObject>>
    {
        do
        {
            let content = try String(contentsOfFile: filePath)

            let data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!

            return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! Dictionary<String, Dictionary<String, AnyObject>>
        }
        catch
        {
            return [:]
        }
    }
}