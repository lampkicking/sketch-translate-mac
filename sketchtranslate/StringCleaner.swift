//
//  StringsProcessor.swift
//  StringsMerger
//
//  Created by John Mills on 25/05/2016.
//  Copyright © 2016 Yoti. All rights reserved.
//

import Foundation

class StringCleaner
{
    var unusedKeys = [String]()
    let fileManager = FileManager.default
    var oldStrings = [String]()
    var currentDirectory: String!
    var supportedExtensions: [String] = []

    func processPaths(_ files: [String])
    {
        print("Starting Search ...".blue)
        for (i, path) in files.enumerated()
        {
            if unusedKeys.count > 0
            {
                do
                {
                    let file = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                    for (x, key) in unusedKeys.enumerated().reversed()
                    {
                        if file.contains("\"\(key)\"")
                        {
                            unusedKeys.remove(at: x)
                        }
                    }
                }
                catch
                {
                    print("Couldn't open file at path: \(path)".red)
                    exit(EXIT_FAILURE)
                }
            }
            let percentage : Float = Float(i) / Float(files.count) * Float(100)
            print(String(format: "%.2f%% %@", percentage, path.components(separatedBy: "/").last!))
        }
    }

    func expandDirectories(_ directories: [String]?) -> [String]
    {
        var isPath: ObjCBool = ObjCBool(false)
        var expanded = [String]()
        if let directories = directories
        {
            for dir in directories
            {
                fileManager.fileExists(atPath: dir, isDirectory: &isPath)
                if isPath.boolValue
                {
                    if let subDirectories = fileManager.subpaths(atPath: dir)
                    {
                        let allPaths = subDirectories[subDirectories.startIndex...subDirectories.endIndex.advanced(by: -1)]
                        expanded.append(contentsOf: allPaths)
                    }
                }
                else
                {
                    print("Specified directory is not a directory".red)
                    exit(EXIT_FAILURE)
                }
            }
        }
        return expanded
    }

    func getFilePathsFromPath(includedPaths: [String], excludedPaths: [String]) -> [String]
    {
        print("Found \(includedPaths.count) files".blue)
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
        print("Found \(supportedFiles.count) supported source and interface files".green)
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
        print("Excluding \(excludedPaths.count) paths".red)
        print("\(leastSupportedFiles.count) remaining source and interface files".green)
        return leastSupportedFiles
    }

    func loadStrings(_ strings: [String])
    {
        oldStrings = strings
        unusedKeys.append(contentsOf: strings)
        print("Found: \(unusedKeys.count) keys".blue)
    }

    func processStringsInProject(_ projectDir: String,
                                 supportedExtensions: [String],
                                 excludedDirs: [String]? = [String](),
                                 strings: [String]) -> ([String], [String])
    {
        self.supportedExtensions = supportedExtensions
        var strings = strings
        currentDirectory = fileManager.currentDirectoryPath
        fileManager.changeCurrentDirectoryPath(projectDir)
        loadStrings(strings)
        let searchPaths = getFilePathsFromPath(includedPaths: expandDirectories([projectDir]),
                                               excludedPaths: expandDirectories(excludedDirs))
        processPaths(searchPaths)

        for key in unusedKeys
        {
            if let index = strings.index(of: key)
            {
                strings.remove(at: index)
            }
        }

        return (strings, unusedKeys)
    }
}
