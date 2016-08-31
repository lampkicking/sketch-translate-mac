@import 'common/sandbox.js'

var com = {};

function Item(value)
{
    this.value = value
    this.screens = [[NSMutableArray alloc] init]
}

function Translations()
{
    this.items = [[NSMutableDictionary alloc] init]
}

com.yoti =
{
    alert: function (msg, title)
    {
        title = title || 'Sketch translate';
        var app = [NSApplication sharedApplication];
        [app displayDialog:msg withTitle:title];
    },

    getFileFolder: function()
    {
        var doc = context.document

        var file_url = [doc fileURL],
        file_path = [file_url path],
        file_folder = file_path.split([doc displayName])[0];
        return file_folder;
    },

    getExportPath: function()
    {
        var doc = context.document

        var file_folder = com.yoti.getFileFolder()
        return file_folder;
    },

    exportData : function (translations, conflictsMetadata)
    {
        var path = com.yoti.getExportPath();

        var data = [NSJSONSerialization dataWithJSONObject:translations.items options:NSJSONWritingPrettyPrinted error:nil];

        [data writeToFile:path + "/loc_data.json"]

        var conflictingPageName = [[NSMutableDictionary alloc] init]
        var keys = conflictsMetadata.allKeys()
        for (var i = 0; i < keys.count(); ++i)
        {
            pageName = keys[i]
            if (conflictsMetadata[pageName].count() > 1)
            {
                var firstItemValue = conflictsMetadata[pageName][0].value
                for (var j = 1; j < conflictsMetadata[pageName].count(); j++)
                {
                    var currentItem = conflictsMetadata[pageName][j]
                    if (!(firstItemValue.isEqualToString(currentItem.value)))
                    {
                        conflictingPageName[pageName] = conflictsMetadata[pageName]
                        break;
                    }
                }
            }
        }
        data = [NSJSONSerialization dataWithJSONObject:conflictingPageName options:NSJSONWritingPrettyPrinted error:nil];
        [data writeToFile:path + "/conflicts_data.json"]
    },

    generateLocalisation : function()
    {
        try
        {
            var document = context.document
            var translations = new Translations()

            var conflictsMetadata = [[NSMutableDictionary alloc] init]
            // Iterate through pages
            for (var pageIndex = 0; pageIndex < document.pages().count(); ++pageIndex)
            {
                var artBoards = document.pages()[pageIndex].artboards()

                // Iterate through ArtBoards (== screens)
                for (var artBoardIndex = 0; artBoardIndex < artBoards.count(); ++artBoardIndex)
                {
                    var artboard = artBoards[artBoardIndex]
                    var screenElements = artboard.children()
                    var artBoardName = artboard.name()

                    // Iterate through elements of the screen
                    for (var i = 0; i < screenElements.count(); ++i)
                    {
                        var element = screenElements[i]
                        var name = element.name()

                        if (element.isVisible())
                        {
                            if (([name rangeOfString:@"loc."].location == 0 || [name rangeOfString:@"btn."].location == 0) && [element isKindOfClass:[MSTextLayer class]])
                            {
                                // Export the translations
                                var item = translations.items[name]
                                if (item == null)
                                {
                                    item = new Item(element.stringValue())
                                    translations.items[name] = item
                                }

                                item.screens.addObject(artBoardName)

                                // Export the conflicts Metadata
                                var tmp = new Item(element.stringValue())
                                tmp.screens.addObject(artBoardName)

                                if (conflictsMetadata[name] == null)
                                {
                                    conflictsMetadata[name] = [[NSMutableArray alloc] init]
                                }
                                conflictsMetadata[name].addObject(tmp)

                            }
                        }
                    }
                  }
            }
            com.yoti.exportData(translations, conflictsMetadata)
        }
        catch (e)
        {
            log (e)
        }
    },

    translatePageWithData: function(data)
    {
        var errorCount = 0;
        for (var pageIndex = 0; pageIndex < context.document.pages().count(); ++pageIndex)
        {
          var children = context.document.pages()[pageIndex].children()
          for (var i = 0; i < children.count(); ++i)
          {
              var element = children[i]

              if ([element isKindOfClass:[MSTextLayer class]])
              {
                  var newName = element.name()

                  if ([newName rangeOfString:@"btn."].location == 0)
                      newName = element.name().replace("btn.", "")
                  else if ([newName rangeOfString:@"loc."].location == 0)
                      newName = element.name().replace("loc.", "")

                  if(data[newName])
                  {
                      if (element.stringValue() != data[newName])
                          errorCount++;
                      element.setStringValue(data[newName]);
                      [element adjustFrameToFit];
                  }

                  if(data[element.name()])
                  {
                      if (element.stringValue() != data[element.name()])
                          errorCount++;
                      element.setStringValue(data[element.name()]);
                      [element adjustFrameToFit];
                  }

              }
          }
      }

        return errorCount;
    },

    importLocalization : function ()
    {
        var openPanel = [NSOpenPanel openPanel];

        var defaultDirectory = [NSURL fileURLWithPath:"~/Documents/"];
        if([doc fileURL])
        {
            defaultDirectory = [[doc fileURL] URLByDeletingLastPathComponent]]
        }

        [openPanel setCanChooseDirectories:false];
        [openPanel setCanChooseFiles:true];
        [openPanel setAllowedFileTypes:['txt']];
        [openPanel setCanCreateDirectories:false];
        [openPanel setDirectoryURL:defaultDirectory];
        [openPanel setAllowsMultipleSelection: false]

        [openPanel setTitle:"Pick a translation file"];
        [openPanel setPrompt:"Translate"];

        if ([openPanel runModal] == NSOKButton)
        {
            var urls = [openPanel URLs];
            var errorCount = 0;

            var url, filename, getString;
            for (var i = 0; i < urls.count(); i++)
            {
                url = urls[i];
                getString = NSString.stringWithContentsOfFile_encoding_error(url, NSUTF8StringEncoding, null);

                if(getString)
                {
                    data = JSON.parse(getString.toString());
                    errorCount += this.translatePageWithData(data);
                }
            }
        }
    }

}
