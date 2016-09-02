//
//  Exportable.swift
//  sketchtranslate
//
//  Created by Charles Vu on 02/09/2016.
//  Copyright © 2016 Charles Vu. All rights reserved.
//

import Foundation

class Exportable
{
    let exportFilename: String
    let newFilePath: String
    let oldFilePath: String

    init(exportFilename: String, newFilePath: String, oldFilePath: String)
    {
        self.exportFilename = exportFilename
        self.newFilePath = newFilePath
        self.oldFilePath = oldFilePath

        initializeFile()
        processFile()
        finalizeFile()
    }

    func initializeFile()
    {
    }

    func finalizeFile()
    {
    }


    func writeToFile(key key: String, value: Item)
    {
    }

    func writeCommentToFile(comment: String)
    {
    }


    func processFile()
    {
        let newDataJson = NSJSONSerialization.JSONObjectFromFile(newFilePath)
        let oldDataJson = NSJSONSerialization.JSONObjectFromFile(oldFilePath)

        var newItems = Dictionary<String, Item>()
        var deletedItems = oldDataJson
        var changedItems = Dictionary<String, Item>()

        for (key, value) in newDataJson
        {
            let newItem = Item(value: value)

            if let oldValue = oldDataJson[key]
            {
                deletedItems.removeValueForKey(key)

                let oldItem = Item(value: oldValue)
                if oldItem.value != newItem.value
                {
                    changedItems[key] = newItem
                }

                writeToFile(key: key, value: newItem)
            }
            else
            {
                // We found a new key that didn't exist in the old file
                newItems[key] = newItem
            }
        }

        if newItems.count > 0
        {
            writeCommentToFile("New Items that didn't existed before")
            print("New Keys : ".blue)

            for (key, item) in newItems
            {
                writeToFile(key: key, value: item)
                print("    " + key.magenta + " on screen named : ".blue + item.screens.joinWithSeparator(", ").green)
            }
        }


        if deletedItems.count > 0
        {
            writeCommentToFile("Deleted Items that existed before")
            print("Deleted Keys : ".blue)

            for (key, value) in deletedItems
            {
                let oldItem = Item(value: value)
                writeToFile(key: key, value: oldItem)
                print("    " + key.magenta + " on screen named : ".blue + oldItem.screens.joinWithSeparator(", ").bold.red)

            }
        }
        
        for (key, value) in changedItems
        {
            print("Modified Copy : ".blue)
            print("    " + key.magenta + " was : ".blue + value.value.red + " is now ".blue + value.value.green)
        }

    }
}