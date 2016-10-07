//
//  File.swift
//  sketchtranslate
//
//  Created by Charles Vu on 01/09/2016.
//  Copyright © 2016 Charles Vu. All rights reserved.
//

import Foundation

extension JSONSerialization
{
    class func JSONObjectFromFile(_ filePath : String) -> Dictionary<String, Dictionary<String, AnyObject>>
    {
        do
        {
            let content = try String(contentsOfFile: filePath)

            let data: Data = content.data(using: String.Encoding.utf8)!

            return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! Dictionary<String, Dictionary<String, AnyObject>>
        }
        catch
        {
            return [:]
        }
    }
}
