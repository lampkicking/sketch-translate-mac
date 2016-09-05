//
//  main.swift
//  sketchtranslate
//
//  Created by Charles Vu on 01/10/2015.
//  Copyright © 2015 Charles Vu. All rights reserved.
//

import Foundation

enum Platform : String
{
    case iOS = "iOS"
    case Android = "Android"
}

let cli = CommandLine()

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .Error:
        str = s.red.bold
    case .OptionFlag:
        str = s
    case .OptionHelp:
        str = s.blue
    default:
        str = s
    }

    return cli.defaultFormat(str, type: type)
}

let newPath = StringOption(shortFlag: "n",
                           longFlag: "new",
                           required: true,
                            helpMessage: "Path to the new file.")

let oldPath = StringOption(shortFlag: "o",
                           longFlag: "old",
                           required: true,
                          helpMessage: "Path to the old file.")

let platform = EnumOption<Platform>(shortFlag: "p",
                                    longFlag: "platform",
                                    required: true,
                                    helpMessage: "Platform to build the files: iOS or Android.")

let projectDirectory = StringOption(shortFlag: "d",
                                    longFlag: "project",
                                    required: false,
                                    helpMessage: "Path to the iOS or Android Project")

let excludedDirectories = MultiStringOption(shortFlag: "x",
                                          longFlag: "exclude",
                                          required: false,
                                          helpMessage: "Full Path to excluded folders")

cli.addOptions(newPath, oldPath, platform, projectDirectory, excludedDirectories)

do
{
    try cli.parse()
}
catch
{
    cli.printUsage(error)
    exit(EX_USAGE)
}

let exportable: Exportable
switch platform.value!
{
case .iOS:
    exportable = iOS(exportFilename: "Localizable.strings",
                     newFilePath: newPath.value!,
                     oldFilePath: oldPath.value!,
                     projectPath: projectDirectory.value,
                     excludedPaths: excludedDirectories.value)
case .Android:
    exportable = Android(exportFilename: "strings.xml",
                         newFilePath: newPath.value!,
                         oldFilePath: oldPath.value!,
                         projectPath: projectDirectory.value,
                         excludedPaths: excludedDirectories.value)
}

exportable.processFile()