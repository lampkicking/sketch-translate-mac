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

let excludedDirectory = MultiStringOption(shortFlag: "x",
                                          longFlag: "exclude",
                                          required: false,
                                          helpMessage: "Path to the iOS or Android Project")

cli.addOptions(newPath, oldPath, platform)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

switch platform.value!
{
case .iOS:
    let _ = iOS(exportFilename: "localizable.strings", newFilePath: newPath.value!, oldFilePath: oldPath.value!)
case .Android:
    let _ = Android(exportFilename: "localizable.strings", newFilePath: newPath.value!, oldFilePath: oldPath.value!)
}
