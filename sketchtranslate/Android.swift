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
        andoridFile = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        andoridFile += "<resources>\n"
    }

    override func writeToFile(key: String, value: Item)
    {
        let androidReplacedValue = value.toAndroid()

        andoridFile += String(format: "    <!-- %@ -->\n", arguments: [value.screens.joined(separator: " ")])
        andoridFile += String(format: "    <string name=\"%@\">%@</string>\n", arguments: [key, androidReplacedValue])
    }

    override func writeCommentToFile(_ comment: String)
    {
        andoridFile += String("\n\n\n    <!-- \(comment) -->\n")
    }

    override func finalizeFile()
    {
        andoridFile += "</resources>"
        do
        {
            try andoridFile.write(toFile: exportFilename, atomically: true, encoding: String.Encoding.utf8)
        }
        catch
        {

        }
    }
    
}
