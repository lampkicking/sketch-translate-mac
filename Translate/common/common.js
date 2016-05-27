@import 'common/sandbox.js'

var com = {};

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

    exportData : function (exportableData, jsonData, textPageName)
    {
        var path = com.yoti.getExportPath();

        var data = [NSJSONSerialization dataWithJSONObject:exportableData options:NSJSONWritingPrettyPrinted error:nil];

        [data writeToFile:path + "/loc_data.txt"]

        var conflictingPageName = [[NSMutableDictionary alloc] init]
        var keys = textPageName.allKeys()
        for (var i = 0; i < keys.count(); ++i)
        {
          pageName = keys[i]
          if (textPageName[pageName].count() > 1)
          {
            conflictingPageName[pageName] = textPageName[pageName]
          }
        }
        data = [NSJSONSerialization dataWithJSONObject:conflictingPageName options:NSJSONWritingPrettyPrinted error:nil];
        [data writeToFile:path + "/conflicts_data.txt"]

    },

    export : function()
    {
        var addedLayers = []
        var doc = context.document
        var documentName = context.document.displayName()

        var jsonData = [[NSMutableDictionary alloc] init]
        var textPageName = [[NSMutableDictionary alloc] init]
        var exportableData = [[NSMutableDictionary alloc] init]

        for (var pageIndex = 0; pageIndex < context.document.pages().count(); ++pageIndex)
        {
          var artBoards = context.document.pages()[pageIndex].artboards()
          for (var artBoardIndex = 0; artBoardIndex < artBoards.count(); ++ artBoardIndex)
          {
            var arboard = artBoards[artBoardIndex]
            var children = arboard.children()

            for (var i = 0; i < children.count(); ++i)
            {
              var element = children[i]
              var name = element.name()
              var parent = element.parentGroup()
              if (element.isVisible())
              {
                  if ([name rangeOfString:@"loc."].location == 0 || [name rangeOfString:@"btn."].location == 0)
                  {
                      //create the text
                      var newName = name

                      if ([element isKindOfClass:[MSTextLayer class]])
                      {
                          if (exportableData[newName] && !exportableData[newName].isEqualToString(element.stringValue()))
                          {
                              //create the text
                              var tmp = [[NSMutableArray alloc] init]
                              tmp.addObject(arboard.name())
                              tmp.addObject(element.stringValue())
                              textPageName[newName].addObject(tmp)
                          }
                          else
                          {
                              textPageName[newName] = [[NSMutableArray alloc] init]
                              var tmp = [[NSMutableArray alloc] init]
                              tmp.addObject(arboard.name())
                              tmp.addObject(element.stringValue())
                              textPageName[newName].addObject(tmp)
                              exportableData[newName] = element.stringValue()
                          }
                      }

                    }
                  }
                }
              }
        }

        com.yoti.exportData (exportableData, jsonData, textPageName)
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
            if (errorCount > 0)
            {
                this.alert('Translation completed with ' + errorCount + ' changes.', null);
            }
            else
            {
                this.alert('Translation completed successfully', null);
            }
        }
    }

}
