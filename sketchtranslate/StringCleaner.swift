//
//  StringsProcessor.swift
//  StringsMerger
//
//  Created by John Mills on 25/05/2016.
//  Copyright © 2016 Yoti. All rights reserved.
//

import Foundation

struct StringsProcessor
{
    static var unusedKeys = [String]()
    static let supportedExtensions = [".swift", ".h", ".m", ".mm", ".xib", ".storyboard"]
    static let fileManager = NSFileManager.defaultManager()
    static var oldStrings: NSString!
    static var currentDirectory: String!

    static func write(string: String, path: String)
    {
        let fullPath = path.stringByAppendingString("/Localizable_Cleaned.strings")

        do
        {
            try string.writeToFile(fullPath, atomically: true, encoding: NSUTF8StringEncoding)
            print("Success! output in \(fullPath)\n".green)
            exit(EXIT_SUCCESS)
        }
        catch{
            print("Failed to write processed file \(path)\n".red)
            exit(EXIT_FAILURE)
        }
    }

    static func processPaths(paths: [String])
    {
        print("Starting Search:\n".blue)
        for (i, path) in paths.enumerate()
        {
            if unusedKeys.count > 0
            {
                do
                {
                    let file = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                    for (x, key) in unusedKeys.enumerate().reverse()
                    {
                        if file.containsString("\"\(key)\"")
                        {
                            unusedKeys.removeAtIndex(x)
                        }
                    }
                }
                catch
                {
                    print("Couldn't open file at path: \(path)".red)
                    exit(EXIT_FAILURE)
                }
            }
            let percentage : Float = Float(i) / Float(paths.count) * Float(100)
            let logString = String(format: "%.2f%%\u{1B}[\(1)A", percentage)
            print(logString)
        }
    }

    static func expandDirectories(directories: [String]) -> [String]
    {
        var isPath :ObjCBool = ObjCBool(false)
        var expanded = [String]()
        for dir in directories
        {
            fileManager.fileExistsAtPath(dir, isDirectory: &isPath)
            if Bool(isPath)
            {
                if let subDirectories = fileManager.subpathsAtPath(dir)
                {
                    let allPaths = subDirectories[subDirectories.startIndex...subDirectories.endIndex.advancedBy(-1)]
                    expanded.appendContentsOf(allPaths)
                }
            }
            else
            {
                print("Specified directory is not a directory".red)
                exit(EXIT_FAILURE)
            }
        }
        return expanded
    }

    static func filterDirectories(includedPaths: [String], excludedPaths: [String]) -> [String]
    {
        print("Found \(includedPaths.count) paths\n".red)
        let supportedFiles = includedPaths.filter{
            var found = false
            for extention in supportedExtensions
            {
                if $0.hasSuffix(extention)
                {
                    found = true
                    break
                }
            }
            return found
        }
        print("Found \(supportedFiles.count) supported source and interface files\n".blue)
        let leastSupportedFiles = supportedFiles.filter{
            var notFound = true
            for exclusion in excludedPaths
            {
                if $0.hasSuffix(exclusion)
                {
                    notFound = false
                    break
                }
            }
            return notFound
        }
        print("Excluding \(excludedPaths.count) paths\n".blue)
        print("\(leastSupportedFiles.count) remaining source and interface files\n".blue)
        return leastSupportedFiles
    }

    static func loadStrings(stringsPath: String)
    {
        do
        {
            oldStrings = try NSString(contentsOfFile: stringsPath, encoding: NSUTF8StringEncoding)
            if let stringsDictionary = oldStrings.propertyListFromStringsFileFormat() as? [String : String]
            {
                unusedKeys.appendContentsOf(stringsDictionary.keys)
                print("Loaded strings file: \(unusedKeys.count) keys\n".blue)
            }
        }
        catch
        {
            print("Couldn't open Strings file".red)
            exit(EXIT_FAILURE)
        }
    }

    static func processStringsInProject(projectDir: String, excludedDirs: [String] = [String](), stringsPath: String, outputPath: String?)
    {
        currentDirectory = fileManager.currentDirectoryPath
        fileManager.changeCurrentDirectoryPath(projectDir)
        loadStrings(stringsPath)
        let searchPaths = filterDirectories(expandDirectories([projectDir]), excludedPaths: expandDirectories(excludedDirs))
        processPaths(searchPaths)

        if var oldDictionary = oldStrings.propertyListFromStringsFileFormat()
        {
            for key in unusedKeys
            {
                oldDictionary.removeValueForKey(key)
            }

            var mergedStrings = ""

            for (key, value) in oldDictionary
            {
                let newValue = value.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
                let stringSafe = newValue.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
                mergedStrings += ("\"\(key)\" = \"\(stringSafe)\";\n")
            }

            if let output = outputPath as String?
            {
                write(mergedStrings, path: output)
            }
            else
            {
                write(mergedStrings, path: currentDirectory)
            }
        }
        else
        {
            print("Couldn't parse Strings file".red)
            exit(EXIT_FAILURE)
        }
    }
}