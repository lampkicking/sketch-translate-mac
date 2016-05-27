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

    initRectSharedStyle : function (rectLayer, name)
    {
        var layerStyles = doc.documentData().layerStyles();
        var layerStylesLibrary = layerStyles.objectsSortedByName();

        // loop through existing styles, if "Specs background" already exists apply it and return
        for (var i = 0; i < [layerStylesLibrary count]; i++) {
            if (layerStylesLibrary[i].name() == name) {
                rectLayer.setStyle(layerStylesLibrary[i].newInstance());
                return;
            }
        }
        var style = MSStyle.alloc().init();

        if (name == "RED_STROKE")
        {
          var border = style.addStylePartOfType(1);
          border.color = MSColor.colorWithSVGString("#FF0000");
          border.thickness = 2;
        }
        else if (name == "WHITE_FILL")
        {
            var fill = style.addStylePartOfType(0);
            fill.color = MSColor.colorWithSVGString("#FFFFFF");
        }
        else if (name == "GREEEN_STROKE")
        {
          var border = style.addStylePartOfType(1);
          border.color = MSColor.colorWithSVGString("#00FF00");
          border.thickness = 2;
        }
        // Add style to the container of shared styles.
        // layerStyles.addSharedStyleWithName_firstInstance(name, style);

        // Apply the style to rectLayer
        [rectLayer setStyle: style];
    },

    initTextSharedStyle : function (textLayer, name)
    {
        var textStyles = doc.documentData().layerTextStyles();
        var textStylesLibrary = textStyles.objectsSortedByName();

        // loop through existing text styles, if "Specs text" already exists apply it and return
        for (var i = 0; i < [textStylesLibrary count]; i++) {
            if (textStylesLibrary[i].name() == name) {
                [textLayer finishEditing];
                [textLayer setIsEditingText:false];

                textLayer.setStyle(textStylesLibrary[i].newInstance());
                return;
            }
        }

        var style = MSStyle.alloc().init();

        if (name == "BLUE_TEXT")
        {
          var fill = style.addNewStylePart(0);
          fill.color = MSColor.colorWithSVGString("#0000FF");
        }
        else if (name == "GREEN_TEXT")
        {
          var fill = style.addNewStylePart(0);
          fill.color = MSColor.colorWithSVGString("#00FF00");
        }

        // textStyles.addSharedStyleWithName_firstInstance(name, style);
        [textLayer setStyle:style]
    },

    getFileFolder: function()
    {
        var file_url = [doc fileURL],
        file_path = [file_url path],
        file_folder = file_path.split([doc displayName])[0];
        return file_folder;
    },

    getExportPath: function()
    {
        var file_folder = com.yoti.getFileFolder(),
        export_folder = file_folder + ([doc displayName]).split('.sketch')[0] + "_export/";
        return export_folder;
    },

    exportData : function (jsonData)
    {
        var path = com.yoti.getExportPath();

        var data = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
        // [data writeToFile:path + "/loc_data.txt"]
        if (in_sandbox()) {
            sandboxAccess.accessFilePath_withBlock_persistPermission(path + "loc_data.txt", function() {
              [data writeToFile:path + "/loc_data.txt"]
            }, true)
        } else {
            [data writeToFile:path + "/loc_data.txt"]
        }

    },

    export_all_artboards: function(format,path)
    {
        if (path == undefined) {
            path = com.yoti.getExportPath();
        }
        log("export_all_artboards() to " + path)
        var pages = [doc pages]
        for(var i=0; i < [pages count]; i++)
        {
            var page = [pages objectAtIndex:i]
            [doc setCurrentPage:page]
            var pagename = [[doc currentPage] name]
            var layers = [[doc currentPage] artboards]

            for (var j=0; j < [layers count]; j++)
            {

                var artboard = [layers objectAtIndex:j]
                if (in_sandbox()) {
                    sandboxAccess.accessFilePath_withBlock_persistPermission(path + "/" + pagename, function() {
                        [doc saveArtboardOrSlice:artboard toFile:path + "/" + pagename + "/" + [artboard name] + "." + format];
                    }, true)
                } else {
                    [doc saveArtboardOrSlice:artboard toFile:path + "/" + pagename + "/" + [artboard name] + "." + format];
                }
            }
        }
    },

    cleanupStyles : function ()
    {
        var textStyles = doc.documentData().layerTextStyles();
        var textStylesLibrary = textStyles.objectsSortedByName();

        // loop through existing text styles, if "Specs text" already exists apply it and return
        for (var i = 0; i < [textStylesLibrary count]; i++)
        {
            if (textStylesLibrary[i].name() == 'BLUE_TEXT' || textStylesLibrary[i].name() == 'GREEN_TEXT')
            {
                textStyles.removeSharedStyle(textStylesLibrary[i])
            }
        }

        var layerStyles = doc.documentData().layerStyles();
        var layerStylesLibrary = layerStyles.objectsSortedByName();

        // loop through existing styles, if "Specs background" already exists apply it and return
        for (var i = 0; i < [layerStylesLibrary count]; i++)
        {
            if (layerStylesLibrary[i].name() == 'RED_STROKE' ||
            layerStylesLibrary[i].name() == 'GREEEN_STROKE' ||
            layerStylesLibrary[i].name() == 'WHITE_FILL')
            {
                layerStyles.removeSharedStyle(layerStylesLibrary[i])
            }
        }
    },

    createRectWithSize : function (x, y, width, height, parent, addedLayers, style)
    {
        var rectShape = MSRectangleShape.alloc().init();
        rectShape.frame = MSRect.rectWithRect(NSMakeRect(x, y, width, height));
        rectLayer = [MSShapeGroup shapeWithPath:rectShape];
        parent.addLayers([rectLayer])
        addedLayers.push(rectLayer)
        com.yoti.initRectSharedStyle(rectLayer, style)

        return rectLayer
    },

    createText : function (x, y, key, value, parent, addedLayers, isTextLayer, jsonData, style)
    {
        var new_layer = [parent addLayerOfType:"text"]
        var textFrame = [new_layer frame];

        var newName = key

        [new_layer setStringValue:newName]

        if (isTextLayer)
        {
            jsonData[newName] = value
        }

        [textFrame setX:x]
        [textFrame setY:y]
        [textFrame setWidth:200]

        com.yoti.initTextSharedStyle(new_layer, style)
        addedLayers.push(new_layer)
        return new_layer;
    },

    show_conflicts : function (argument) {
        var addedLayers = []
        var doc = context.document
        var documentName = context.document.displayName();
        var jsonData = [[NSMutableDictionary alloc] init]

        for (var pageIndex = 0; pageIndex < context.document.pages().count(); ++pageIndex)
        {
          var children = context.document.pages()[pageIndex].children()

          for (var i = 0; i < children.count(); ++i)
          {
              var element = children[i]
              var name = element.name()
              var parent = element.parentGroup()
              if (element.isVisible())
              {
                  if ([name rangeOfString:@"loc."].location == 0 || [name rangeOfString:@"btn."].location == 0)
                  {
                      var newName = name

                      if ([element isKindOfClass:[MSTextLayer class]])
                      {
                          if (jsonData[newName] && jsonData[newName] != element.stringValue())
                          {
                              // create the rectagle
                              var rectLayer = com.yoti.createRectWithSize(element.frame().x(),
                                                                          element.frame().y(),
                                                                          element.frame().width(),
                                                                          element.frame().height(),
                                                                          parent,
                                                                          addedLayers,
                                                                          "RED_STROKE")

                              //create the text
                              var textLayer = com.yoti.createText(element.frame().x(),
                                                                  element.frame().y() - 15,
                                                                  element.name(),
                                                                  element.stringValue ? element.stringValue() : null,
                                                                  parent,
                                                                  addedLayers,
                                                                  [element isKindOfClass:[MSTextLayer class]],
                                                                  jsonData,
                                                                  "BLUE_TEXT")

                              // add the text underlay
                              rectLayer = com.yoti.createRectWithSize(textLayer.frame().x() - 2,
                                                                      textLayer.frame().y(),
                                                                      textLayer.frame().width() + 4,
                                                                      textLayer.frame().height(),
                                                                      parent,
                                                                      addedLayers,
                                                                      "WHITE_FILL")

                              [parent removeLayer:textLayer]
                              parent.addLayers([textLayer])
                          }
                          jsonData[newName] = element.stringValue()
                      }
                  }

              }
          }
        }
    },

    export : function()
    {
        var addedLayers = []
        var doc = context.document
        var documentName = context.document.displayName();
        var jsonData = [[NSMutableDictionary alloc] init]


        for (var pageIndex = 0; pageIndex < context.document.pages().count(); ++pageIndex)
        {
          var children = context.document.pages()[pageIndex].children()

          for (var i = 0; i < children.count(); ++i)
          {
            var element = children[i]
            var name = element.name()
            var parent = element.parentGroup()
            if (element.isVisible())
            {
                if ([name rangeOfString:@"loc."].location == 0)
                {
                    // create the rectagle
                    var rectLayer = com.yoti.createRectWithSize(element.frame().x(),
                                                                element.frame().y(),
                                                                element.frame().width(),
                                                                element.frame().height(),
                                                                parent,
                                                                addedLayers,
                                                                "RED_STROKE")

                    //create the text
                    var textLayer = com.yoti.createText(element.frame().x(),
                                                        element.frame().y() - 15,
                                                        element.name(),
                                                        element.stringValue ? element.stringValue() : null,
                                                        parent,
                                                        addedLayers,
                                                        [element isKindOfClass:[MSTextLayer class]],
                                                        jsonData,
                                                        "BLUE_TEXT")

                    // add the text underlay
                    rectLayer = com.yoti.createRectWithSize(textLayer.frame().x() - 2,
                                                            textLayer.frame().y(),
                                                            textLayer.frame().width() + 4,
                                                            textLayer.frame().height(),
                                                            parent,
                                                            addedLayers,
                                                            "WHITE_FILL")

                    [parent removeLayer:textLayer]
                    parent.addLayers([textLayer])
                }

                if ([name rangeOfString:@"btn."].location == 0)
                {
                    var rectLayer = com.yoti.createRectWithSize(element.frame().x(),
                                                                element.frame().y(),
                                                                element.frame().width(),
                                                                element.frame().height(),
                                                                parent,
                                                                addedLayers,
                                                                "RED_STROKE")


                    var textLayer = com.yoti.createText(element.frame().x(),
                                                        element.frame().y() + element.frame().height() + 2,
                                                        element.name(),
                                                        element.stringValue ? element.stringValue() : null,
                                                        parent,
                                                        addedLayers,
                                                        [element isKindOfClass:[MSTextLayer class]],
                                                        jsonData,
                                                        "BLUE_TEXT")

                    // add the text underlay
                    rectLayer = com.yoti.createRectWithSize(textLayer.frame().x() - 2,
                                                            textLayer.frame().y() + 2,
                                                            textLayer.frame().width() + 4,
                                                            textLayer.frame().height(),
                                                            parent,
                                                            addedLayers,
                                                            "WHITE_FILL");

                    [parent removeLayer:textLayer]
                    parent.addLayers([textLayer])
                }

                if ([name rangeOfString:@"img."].location == 0)
                {
                    var rectLayer = com.yoti.createRectWithSize(element.frame().x(),
                                                                element.frame().y(),
                                                                element.frame().width(),
                                                                element.frame().height(),
                                                                parent,
                                                                addedLayers,
                                                                "GREEEN_STROKE")


                    var textLayer = com.yoti.createText(element.frame().x(),
                                                        element.frame().y(),
                                                        element.name(),
                                                        element.stringValue ? element.stringValue() : null,
                                                        parent,
                                                        addedLayers,
                                                        [element isKindOfClass:[MSTextLayer class]],
                                                        jsonData,
                                                        "GREEN_TEXT")

                    // add the text underlay
                    rectLayer = com.yoti.createRectWithSize(textLayer.frame().x() - 2,
                                                            textLayer.frame().y(),
                                                            textLayer.frame().width() + 4,
                                                            textLayer.frame().height(),
                                                            parent,
                                                            addedLayers,
                                                            "WHITE_FILL");

                    [parent removeLayer:textLayer]
                    parent.addLayers([textLayer])
                }

            }

          }
        }

        com.yoti.export_all_artboards("pdf");

        for (var j = 0; j < addedLayers.length; ++j)
        {
            var element = addedLayers[j]
            var name = element.name()
            var parent = element.parentGroup()

            [parent removeLayer:element]
        }

        com.yoti.cleanupStyles()

        com.yoti.exportData (jsonData)
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
