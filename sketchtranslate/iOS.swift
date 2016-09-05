//
//  iOS.swift
//  sketchtranslate
//
//  Created by Charles Vu on 02/09/2016.
//  Copyright © 2016 Charles Vu. All rights reserved.
//

import Foundation

class iOS : Exportable
{
    var iOSFile = ""

    override init(exportFilename: String, newFilePath: String, oldFilePath: String, projectPath: String?, excludedPaths: [String]?) {
        super.init(exportFilename: exportFilename,
                   newFilePath: newFilePath,
                   oldFilePath: oldFilePath,
                   projectPath: projectPath,
                   excludedPaths: excludedPaths)

        supportedExtensions = [".swift", ".h", ".m", ".mm", ".xib", ".storyboard"]
    }

    override func writeToFile(key key: String, value: Item)
    {
        let iosReplacedValue = value.toiOS()

        iOSFile += String(format: "// %@\n", arguments: [value.screens.joinWithSeparator(" ")])
        iOSFile += String(format: "\"%@\" = \"%@\";\n", arguments: [key, iosReplacedValue])
    }

    override func writeCommentToFile(comment: String)
    {
        iOSFile += String("\n\n\n// \(comment)\n")
    }

    override func finalizeFile()
    {
        do
        {
            try iOSFile.writeToFile(exportFilename, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch
        {

        }
    }
}