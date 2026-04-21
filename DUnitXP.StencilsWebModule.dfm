object StencilsWebModule: TStencilsWebModule
  Actions = <
    item
      Name = 'FixturesListWebActionItem'
      PathInfo = '/fixtureslist'
    end>
  Height = 597
  Width = 761
  PixelsPerInch = 192
  object WebStencilsEngine: TWebStencilsEngine
    Dispatcher = WebFileDispatcher
    PathTemplates = <
      item
        Template = '/'
        Redirect = '/home.html'
      end
      item
        Template = '/{filename}'
      end>
    OnValue = WebStencilsEngineValue
    OnError = WebStencilsEngineError
    OnFileNotFound = WebStencilsEngineFileNotFound
    Left = 109
    Top = 51
  end
  object WebFileDispatcher: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/html'
        Extensions = 'html;htm'
      end
      item
        MimeType = 'application/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpeg;jpg'
      end
      item
        MimeType = 'image/png'
        Extensions = 'png'
      end>
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    VirtualPath = '/'
    Left = 109
    Top = 224
  end
  object WebSessionManager: TWebSessionManager
    Left = 108
    Top = 400
  end
  object WebStencilsProcessor: TWebStencilsProcessor
    Engine = WebStencilsEngine
    Left = 400
    Top = 52
  end
end
