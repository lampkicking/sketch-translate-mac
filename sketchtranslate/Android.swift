//
//  Android.swift
//  sketchtranslate
//
//  Created by Charles Vu on 02/09/2016.
//  Copyright © 2016 Charles Vu. All rights reserved.
//

import Foundation

class Android : Exportable
{
    var andoridFile = ""

    override init(exportFilename: String, newFilePath: String, oldFilePath: String, projectPath: String?, excludedPaths: [String]?) {
        super.init(exportFilename: exportFilename,
                   newFilePath: newFilePath,
                   oldFilePath: oldFilePath,
                   projectPath: projectPath,
                   excludedPaths: excludedPaths)

        supportedExtensions = ["/strings.xml"]
    }


    override func initializeFile()
    {
        var andoridFile = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        andoridFile += "<resources>\n"
    }

    override func writeToFile(key key: String, value: Item)
    {
        let androidReplacedValue = value.toAndroid()

        andoridFile += String(format: "    <!-- %@ -->\n", arguments: [value.screens.joinWithSeparator(" ")])
        andoridFile += String(format: "    <string name=\"%@\">%@</string>\n", arguments: [key, androidReplacedValue])
    }

    override func writeCommentToFile(comment: String)
    {
        andoridFile += String("\n\n\n    <!-- \(comment) -->\n")
    }

    override func finalizeFile()
    {
        andoridFile += "</resources>"
        do
        {
            try andoridFile.writeToFile(exportFilename, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch
        {

        }
    }
    
}