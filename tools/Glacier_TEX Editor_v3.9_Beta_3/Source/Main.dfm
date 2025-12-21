object frmTEXeditor: TfrmTEXeditor
  Left = 439
  Top = 235
  BorderStyle = bsSingle
  Caption = 'Glacier TEX Editor v3.9 Beta 3'
  ClientHeight = 453
  ClientWidth = 632
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lstTEX: TListView
    Left = 0
    Top = 54
    Width = 632
    Height = 312
    Align = alClient
    Columns = <
      item
        Caption = '+Offset'
        Width = 75
      end
      item
        Caption = 'Name'
        Width = 260
      end
      item
        Caption = 'Type'
        Width = 45
      end
      item
        Caption = 'Size'
        Width = 75
      end
      item
        Caption = 'Index'
        Width = 45
      end
      item
        Caption = 'Description'
        Width = 117
      end>
    GridLines = True
    HideSelection = False
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    SortType = stData
    TabOrder = 0
    ViewStyle = vsReport
    OnColumnClick = lstTEXColumnClick
    OnCompare = lstTEXCompare
    OnResize = lstTEXResize
    OnSelectItem = lstTEXSelectItem
  end
  object status: TStatusBar
    Left = 0
    Top = 434
    Width = 632
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Bevel = pbRaised
        Text = 'Total'
        Width = 40
      end
      item
        Alignment = taCenter
        Text = '0 entries'
        Width = 90
      end
      item
        Text = 'Idle'
        Width = 75
      end>
  end
  object panBottom: TPanel
    Left = 0
    Top = 366
    Width = 632
    Height = 68
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    OnResize = panBottomResize
    object bvlBottom: TBevel
      Left = 0
      Top = 40
      Width = 633
      Height = 9
      Shape = bsTopLine
    end
    object lblURL: TLabel
      Left = 391
      Top = 48
      Width = 234
      Height = 13
      Cursor = crHandPoint
      Hint = 'Go there for latest version'
      Alignment = taRightJustify
      Caption = 'http://forum.elberethzone.net/viewforum.php?f=8'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblURLClick
    end
    object ProgressBar2: TJvgProgress
      Left = 8
      Top = 46
      Width = 377
      Height = 18
      Colors.Delineate = clGray
      Colors.Shadow = clBlack
      Colors.Background = clBlack
      Gradient.FromColor = clRed
      Gradient.ToColor = clLime
      Gradient.Active = True
      Gradient.BufferedDraw = True
      Gradient.Orientation = fgdVertical
      Gradient.PercentFilling = 0
      GradientBack.FromColor = clMaroon
      GradientBack.ToColor = clGreen
      GradientBack.Active = True
      GradientBack.BufferedDraw = True
      GradientBack.Orientation = fgdVertical
      Percent = 0
      CaptionAlignment = taCenter
      Interspace = 0
      Options = []
      Caption = '%d%%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
    end
    object butImport: TButton
      Left = 8
      Top = 8
      Width = 65
      Height = 25
      Caption = 'Import'
      Enabled = False
      TabOrder = 0
      OnClick = butImportClick
    end
    object butExport: TButton
      Left = 80
      Top = 8
      Width = 65
      Height = 25
      Caption = 'Export'
      Enabled = False
      TabOrder = 1
      OnClick = butExportClick
    end
    object panSearch: TPanel
      Left = 160
      Top = 5
      Width = 305
      Height = 29
      BevelOuter = bvNone
      TabOrder = 2
      object lblSearch: TLabel
        Left = 0
        Top = 8
        Width = 37
        Height = 13
        Caption = 'Search:'
      end
      object txtSearch: TEdit
        Left = 40
        Top = 5
        Width = 121
        Height = 21
        TabOrder = 0
        OnChange = txtSearchChange
      end
      object butSearch: TButton
        Left = 166
        Top = 3
        Width = 43
        Height = 25
        Caption = 'Search'
        TabOrder = 1
        OnClick = butSearchClick
      end
      object butSearchNext: TButton
        Left = 262
        Top = 3
        Width = 43
        Height = 25
        Caption = 'Next'
        Enabled = False
        TabOrder = 2
        OnClick = butSearchNextClick
      end
      object butSearchPrev: TButton
        Left = 214
        Top = 3
        Width = 43
        Height = 25
        Caption = 'Prev.'
        Enabled = False
        TabOrder = 3
        OnClick = butSearchPrevClick
      end
    end
    object butExit: TButton
      Left = 560
      Top = 8
      Width = 67
      Height = 25
      Caption = 'Exit'
      TabOrder = 3
      OnClick = butExitClick
    end
    object butOptions: TButton
      Left = 488
      Top = 8
      Width = 65
      Height = 25
      Caption = 'Options'
      TabOrder = 4
      OnClick = butOptionsClick
    end
    object grpOptions: TGroupBox
      Left = 0
      Top = 0
      Width = 632
      Height = 68
      Align = alClient
      Caption = 'Options'
      TabOrder = 5
      Visible = False
      object butOptionsOk: TButton
        Left = 544
        Top = 24
        Width = 75
        Height = 25
        Caption = 'OK'
        TabOrder = 0
        OnClick = butOptionsOkClick
      end
      object chkScript: TCheckBox
        Left = 8
        Top = 16
        Width = 337
        Height = 17
        Caption = 'Save .TPS information (for HTP Maker tool) script when exporting'
        Enabled = False
        TabOrder = 1
        Visible = False
        OnClick = chkScriptClick
      end
      object chkXbox: TCheckBox
        Left = 8
        Top = 32
        Width = 329
        Height = 17
        Caption = 'XBox mode (swizzle/unswizzle textures automatically)'
        TabOrder = 2
        OnClick = chkXboxClick
      end
    end
  end
  object panTop: TPanel
    Left = 0
    Top = 0
    Width = 632
    Height = 54
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object panTopRight: TPanel
      Left = 431
      Top = 0
      Width = 201
      Height = 54
      Align = alRight
      BevelOuter = bvLowered
      TabOrder = 0
      object Label1: TLabel
        Left = 8
        Top = 2
        Width = 89
        Height = 13
        AutoSize = False
        Caption = 'Show only :'
      end
      object chkRGBAonly: TCheckBox
        Left = 8
        Top = 17
        Width = 57
        Height = 17
        Caption = 'RGBA'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = chkRGBAonlyClick
      end
      object chkPALNOnly: TCheckBox
        Left = 64
        Top = 17
        Width = 49
        Height = 17
        Caption = 'PALN'
        TabOrder = 1
        OnClick = chkPALNOnlyClick
      end
      object chkDXT3only: TCheckBox
        Left = 120
        Top = 1
        Width = 57
        Height = 17
        Caption = 'DXT3'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = chkDXT3onlyClick
      end
      object chkDXT1only: TCheckBox
        Left = 64
        Top = 1
        Width = 57
        Height = 17
        Caption = 'DXT1'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = chkDXT1onlyClick
      end
      object butReload: TButton
        Left = 118
        Top = 21
        Width = 75
        Height = 25
        Caption = 'Reload TEX'
        Enabled = False
        TabOrder = 4
        OnClick = butReloadClick
      end
      object chkI8only: TCheckBox
        Left = 8
        Top = 33
        Width = 57
        Height = 17
        Caption = 'I8'
        TabOrder = 5
        OnClick = chkI8onlyClick
      end
      object chkU8V8only: TCheckBox
        Left = 64
        Top = 33
        Width = 49
        Height = 17
        Caption = 'U8V8'
        TabOrder = 6
        OnClick = chkU8V8onlyClick
      end
    end
    object panTopLeft: TPanel
      Left = 0
      Top = 0
      Width = 431
      Height = 54
      Align = alClient
      BevelOuter = bvLowered
      TabOrder = 1
      OnResize = panTopLeftResize
      object lblSource: TLabel
        Left = 8
        Top = 32
        Width = 25
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'TEX:'
      end
      object lblZip: TLabel
        Left = 8
        Top = 8
        Width = 25
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'ZIP:'
      end
      object panNeedUpdate: TPanel
        Left = 344
        Top = 25
        Width = 81
        Height = 28
        BevelOuter = bvNone
        Color = clRed
        TabOrder = 3
        Visible = False
      end
      object txtSource: TEdit
        Left = 40
        Top = 29
        Width = 305
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
      object butOpen: TButton
        Left = 347
        Top = 4
        Width = 75
        Height = 22
        Caption = 'Open ZIP'
        Default = True
        TabOrder = 1
        OnClick = butOpenClick
      end
      object txtZipFile: TEdit
        Left = 40
        Top = 4
        Width = 297
        Height = 21
        ReadOnly = True
        TabOrder = 2
      end
      object butUpdate: TButton
        Left = 347
        Top = 28
        Width = 75
        Height = 22
        Caption = 'Update ZIP'
        Enabled = False
        TabOrder = 4
        OnClick = butUpdateClick
      end
    end
  end
  object importDialog: TOpenDialog
    Filter = 'Targa 32bpp with alpha channel (*.TGA)|*.TGA'
    Options = [ofFileMustExist, ofEnableSizing]
    Title = 'Select TGA to import...'
    Left = 40
    Top = 112
  end
  object saveDialog: TSaveDialog
    Filter = 'Targa 32bpp with alpha channel (*.TGA)|*.TGA'
    Title = 'Save TGA file...'
    Left = 8
    Top = 112
  end
  object openDialog: TOpenDialog
    Filter = 
      'Freedom Fighters - Ressource Archive (*.ZIP)|*.ZIP|Hitman: Silen' +
      't Assassin - Ressource Archive (*.ZIP)|*.ZIP|Hitman: Contracts -' +
      ' Ressource Archive (*.ZIP)|*.ZIP |Hitman: Blood Money - Ressourc' +
      'e Archive (*.ZIP)|*.ZIP '
    Title = 'Select Glacier Engine ressource archive (ZIP)...'
    Left = 40
    Top = 80
  end
  object ZipMaster: TZipMaster
    AddOptions = [AddDirNames]
    AddStoreSuffixes = [assGIF, assPNG, assZ, assZIP, assZOO, assARC, assLZH, assARJ, assTAZ, assTGZ, assLHA, assRAR, assACE, assCAB, assGZ, assGZIP, assJAR]
    Dll_Load = False
    DLLDirectory = 'ZipDll'
    ExtrOptions = [ExtrDirNames, ExtrOverWrite, ExtrForceDirs]
    FSpecArgs.Strings = (
      '*.tex')
    PasswordReqCount = 1
    Trace = False
    Unattended = True
    Verbose = False
    Version = '1.79.03.01'
    VersionInfo = '1.79.03.01'
    OnMessage = ZipMasterMessage
    OnProgress = ZipMasterProgress
    OnTotalProgress = ZipMasterTotalProgress
    Left = 8
    Top = 80
  end
  object selectDir: TJvSelectDirectory
    Title = 'Select directory for multi-export....'
    Left = 40
    Top = 144
  end
end
