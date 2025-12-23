unit Main;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is Main.pas, released May 29, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

{$R ZipMsgUS.res}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, class_Images, spec_HMC, spec_DDS, INIFiles,
  resample, JclShell, ExtCtrls, ZipMstr, strUtils, JvBaseDlg,
  JvSelectDirectory, JvExControls, JvComponent, JvgProgress,
  class_Xbox;

type
  TCurrentAction = (tcaIdle, tcaExtract, tcaUpdate);

  TfrmTEXeditor = class(TForm)
    lstTEX: TListView;
    status: TStatusBar;
    importDialog: TOpenDialog;
    saveDialog: TSaveDialog;
    panBottom: TPanel;
    butImport: TButton;
    bvlBottom: TBevel;
    butExport: TButton;
    panSearch: TPanel;
    lblSearch: TLabel;
    txtSearch: TEdit;
    butSearch: TButton;
    butSearchNext: TButton;
    butExit: TButton;
    lblURL: TLabel;
    panTop: TPanel;
    panTopRight: TPanel;
    chkRGBAonly: TCheckBox;
    chkPALNOnly: TCheckBox;
    chkDXT3only: TCheckBox;
    chkDXT1only: TCheckBox;
    butReload: TButton;
    Label1: TLabel;
    panTopLeft: TPanel;
    txtSource: TEdit;
    lblSource: TLabel;
    butOpen: TButton;
    openDialog: TOpenDialog;
    butSearchPrev: TButton;
    ZipMaster: TZipMaster;
    lblZip: TLabel;
    txtZipFile: TEdit;
    panNeedUpdate: TPanel;
    butUpdate: TButton;
    selectDir: TJvSelectDirectory;
    ProgressBar2: TJvgProgress;
    butOptions: TButton;
    grpOptions: TGroupBox;
    butOptionsOk: TButton;
    chkScript: TCheckBox;
    chkXbox: TCheckBox;
    procedure butImportClick(Sender: TObject);
    procedure butOpenClick(Sender: TObject);
    procedure lstTEXSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure butExitClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure butExportClick(Sender: TObject);
    procedure chkRGBAonlyClick(Sender: TObject);
    procedure lblURLClick(Sender: TObject);
    procedure chkScriptClick(Sender: TObject);
    procedure chkDXT1onlyClick(Sender: TObject);
    procedure chkDXT3onlyClick(Sender: TObject);
    procedure chkPALNOnlyClick(Sender: TObject);
    procedure butReloadClick(Sender: TObject);
    procedure butSearchClick(Sender: TObject);
    procedure butSearchNextClick(Sender: TObject);
    procedure txtSearchChange(Sender: TObject);
    procedure panTopLeftResize(Sender: TObject);
    procedure panBottomResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lstTEXResize(Sender: TObject);
    procedure butSearchPrevClick(Sender: TObject);
    procedure lstTEXCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lstTEXColumnClick(Sender: TObject; Column: TListColumn);
    procedure ZipMasterMessage(Sender: TObject; ErrCode: Integer;
      Message: String);
    procedure ZipMasterTotalProgress(Sender: TObject; TotalSize: Cardinal;
      PerCent: Integer);
    procedure ZipMasterProgress(Sender: TObject; ProgrType: ProgressType;
      Filename: String; FileSize: Cardinal);
    procedure butUpdateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure butOptionsClick(Sender: TObject);
    procedure butOptionsOkClick(Sender: TObject);
    procedure chkXboxClick(Sender: TObject);
  private
    texFile: TFileStream;
    iniFile: TIniFile;
    sortColumn: Integer;
    sortInvert: boolean;
    currentZIPaction: TCurrentAction;
    currentTEXfile: TFileName;
    { Private declarations }
    procedure exportRGBA(offset: integer; outname: string);
    procedure exportPALN(offset: integer; outname: string);
    procedure exportDXT(dxtchar: char; offset: integer; outname: string);
    function canCloseTool: boolean;
    function testHMZip(trunc: string): boolean;
    function getTEXinZIP: string;
    procedure deleteTempFiles;
    procedure deleteTempFilesRec(dir: String);
    procedure closeTEX();
    procedure parseTEX(fil: string);
    procedure setNumEntries(num: integer);
    procedure setStatusMessage(msg: string);
    function strip0(str : string): string;
    function get0(stm: TStream): string;
    function revstr(str: string): string;
    function getInt64Rec(src: int64): Int64Rec;
    function getInt64(lo, high: integer): Int64;
  public
    { Public declarations }
  end;

var
  frmTEXeditor: TfrmTEXeditor;

implementation

{$R *.dfm}

function Get0(src: integer): string;
var tchar: Char;
    res: string;
begin

  repeat
    FileRead(src,tchar,1);
    res := res + tchar;
  until tchar = chr(0);

  Get0 := res;

end;

procedure TfrmTEXeditor.txtSearchChange(Sender: TObject);
begin

  butSearchNext.Enabled := false;
  butSearchPrev.Enabled := false;

end;

procedure TfrmTEXeditor.butImportClick(Sender: TObject);
var importfile, section: string;
    offset, curoffset, palsize: integer;
    x, mx, y, my, W, H: integer;
    img: TSaveImage32;
    img8: TSaveImage;
    mipmap: array of TSaveImage32;
    bmp: array of TBitmap;
    HDR: HMC_TEX_Entry;
    DDS: DDSHeader;
    inFile: TFileStream;
    Buffer: PByteArray;
    expectedFlags, fsize: cardinal;
    dxtchar: char;
    xbox: TXboxTexture;
begin

  importDialog.InitialDir := IniFile.ReadString('HMCEditor','ImportPath',ExtractFilePath(Application.ExeName));

  if (lstTEX.SelCount  = 1) and ((lstTEX.Selected.SubItems.Strings[1] = 'DXT1') or (lstTEX.Selected.SubItems.Strings[1] = 'DXT3')) then
  begin

   dxtchar := lstTEX.Selected.SubItems.Strings[1][4];

   importDialog.Title := 'Select DDS (DXT'+dxtchar+') to import...';
   importDialog.Filter := 'Microsoft DirectDraw Surface (*.DDS)|*.DDS';

   if importDialog.Execute then
   begin

    panNeedUpdate.Visible := true;

    importfile := importDialog.FileName;

    IniFile.WriteString('HMCEditor','ImportPath',ExtractFilePath(importfile));

    if not(FileExists(importfile)) then
    begin
      SetStatusMessage('Error: DDS file not found');
      MessageDlg('Error: DDS file not found.', mtError, [mbOk], 0);
      exit;
    end;

    offset := strtoint(lstTEX.Selected.Caption);

    inFile := TFileStream.Create(importfile,fmOpenRead);

    try
      setStatusMessage('DDS->DXT'+dxtchar+': [1/3] Reading DDS file...');
      inFile.Read(DDS,SizeOf(DDSHeader));

      if (DDS.ID <> 'DDS ') or (DDS.SurfaceDesc.dwSize <> 124) or (DDS.SurfaceDesc.ddpfPixelFormat.dwSize <> 32) then
        raise Exception.Create('Source file is not a DDS file!');

      setStatusMessage('DDS->DXT'+dxtchar+': [2/3] Reading TEX file...');
      texFile.Seek(offset,soFromBeginning);
      texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
      strip0(Get0(texFile));
      texFile.Read(fsize,4);

      expectedFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT or DDSD_LINEARSIZE;

      if (DDS.SurfaceDesc.dwFlags and (expectedFlags)) <> expectedFlags then
        raise Exception.Create('Bad flags in DDS file!');

      if (HDR.NumMipMap > 1) and
         (((DDS.SurfaceDesc.dwFlags and DDSD_MIPMAPCOUNT) <> DDSD_MIPMAPCOUNT) or
          (DDS.SurfaceDesc.dwMipMapCount <> HDR.NumMipMap)) then
        raise Exception.Create(inttostr(HDR.NumMipMap)+' mipmap level expected in DDS file ('+inttostr(DDS.SurfaceDesc.dwMipMapCount)+' found)!');

      if (DDS.SurfaceDesc.dwHeight <> HDR.Height) or (DDS.SurfaceDesc.dwWidth <> HDR.Width) then
        raise Exception.Create('DDS texture is '+inttostr(DDS.SurfaceDesc.dwWidth)+'x'+inttostr(DDS.SurfaceDesc.dwHeight)+' ('+inttostr(HDR.Width)+'x'+inttostr(HDR.Height)+' expected)');

      if (DDS.SurfaceDesc.dwPitchOrLinearSize <> fsize) then
        raise Exception.Create('DDS Main Image linear size unexpected '+inttostr(DDS.SurfaceDesc.dwPitchOrLinearSize)+' ('+inttostr(fsize)+' expected)');

      if (DDS.SurfaceDesc.ddpfPixelFormat.dwFlags <> DDPF_FOURCC)
      or (DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC <> ('DXT'+dxtchar)) then
        raise Exception.Create('DXT'+dxtchar+' compression expected in DDS file (incompatible format found)');

      progressBar2.Caption := 'Copying data... %d%%';
      setStatusMessage('DDS->DXT'+dxtchar+': [3/3] Copying main image data ('+inttostr(fsize)+' bytes) to TEX file...');
      texFile.CopyFrom(inFile,fsize);
      progressBar2.Percent := round((1 / HDR.NumMipMap) * 100);
      for x := 2 to HDR.NumMipMap do
      begin
        texFile.Read(fsize,4);
        setStatusMessage('DDS->DXT'+dxtchar+': [3/3] Copying mipmap level '+inttostr(x)+' data ('+inttostr(fsize)+' bytes) to TEX file...');
        texFile.CopyFrom(inFile,fsize);
        progressBar2.Percent := round((x / HDR.NumMipMap) * 100);
      end;
      progressBar2.Percent := 100;
      setStatusMessage('DDS->DXT'+dxtchar+': Done! (Import successfull)');

    except
      on E: exception do
      begin
        SetStatusMessage('Error: '+E.Message);
        MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
      end;
    end;
    inFile.Free;

   end;

  end
  else if (lstTEX.SelCount = 1) and (lstTEX.Selected.SubItems.Strings[1] = 'RGBA') then
  begin

   importDialog.Title := 'Select TGA to import...';
   importDialog.Filter := 'Targa 32bpp with alpha channel (*.TGA)|*.TGA';

   if importDialog.Execute then
   begin

     panNeedUpdate.Visible := true;
    importfile := importDialog.FileName;

    IniFile.WriteString('HMCEditor','ImportPath',ExtractFilePath(importfile));

    if not(FileExists(importfile)) then
    begin
      SetStatusMessage('Error: TGA file not found');
      MessageDlg('Error: TGA file not found.', mtError, [mbOk], 0);
      exit;
    end;

// offset := 16;
    offset := strtoint(lstTEX.Selected.Caption);

    img := TSaveImage32.Create;

    try
      setStatusMessage('TGA->RGBA: [1/5] Reading TGA file...');
      img.LoadFromTGA32(importfile);

      setStatusMessage('TGA->RGBA: [2/5] Reading TEX file...');
      texFile.Seek(offset,soFromBeginning);
      texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
      Get0(texFile);
      texFile.Read(fsize,4);
      W := HDR.Width;
      H := HDR.Height;

      if (W <> img.Width) or (H <> img.Height) then
      begin
        raise Exception.Create('Wrong TGA resolution '+inttostr(img.Width)+'x'+inttostr(img.Height)+' [should be '+inttostr(W)+'x'+inttostr(H)+']');
      end;

      setStatusMessage('TGA->RGBA: [3/5] Converting data to RGBA...');
      GetMem(Buffer,W*H*4);
      try
        for y := 0 to H-1 do
          for x := 0 to W-1 do
          begin
            Buffer[(y*W*4)+x*4] := img.Pixels[x][y].R;
            Buffer[(y*W*4)+x*4+1] := img.Pixels[x][y].G;
            Buffer[(y*W*4)+x*4+2] := img.Pixels[x][y].B;
            Buffer[(y*W*4)+x*4+3] := img.Pixels[x][y].A;
          end;

        if chkXbox.Checked then
        begin
          setStatusMessage('TGA->RGBA: [4/5] Writing Xbox RGBA data to TEX file ('+inttostr(H*W*4)+' bytes)...');
          xbox := TXboxTexture.create;
          try
            xbox.intex.Write(Buffer^,H*W*4);
            xbox.reswizzle(W,H,4,1);
            xbox.outtex.Seek(0,soFromBeginning);
            texFile.CopyFrom(xbox.outtex,H*W*4);
          finally
            xbox.destroy;
          end;
        end
        else
        begin
          setStatusMessage('TGA->RGBA: [4/5] Writing RGBA data to TEX file ('+inttostr(H*W*4)+' bytes)...');
          texFile.Write(Buffer^,H*W*4);
        end;

        if HDR.NumMipMap > 1 then
        begin
          setLength(bmp,HDR.NumMipMap);
          setLength(mipmap,HDR.NumMipMap-1);
          bmp[0] := img.GetBitmap;
        end;

        progressBar2.Caption := 'Computing MipMaps... %d%%';
        progressBar2.Percent := round((1 / HDR.NumMipMap) * 100);
        for x := 1 to HDR.NumMipMap-1 do
        begin
          progressBar2.Percent := round(((x+1) / HDR.NumMipMap) * 100);
          bmp[x] := TBitmap.Create;
          if bmp[x-1].Width > 1 then
            bmp[x].Width := bmp[x-1].Width div 2
          else
            bmp[x].width := 1;
          if bmp[x-1].Height > 1 then
            bmp[x].Height := bmp[x-1].Height div 2
          else
            bmp[x].height := 1;
          setStatusMessage('TGA->RGBA: [4/5] Computing mipmap '+inttostr(x+1)+' ('+inttostr(bmp[x].Width)+'x'+inttostr(bmp[x].height)+')...');
          Strecth(bmp[x-1],bmp[x],ResampleFilters[5].Filter,ResampleFilters[5].Width);
          mipmap[x-1] := TSaveImage32.Create;
          mipmap[x-1].LoadFromTBitmap(bmp[x]);
          H := mipmap[x-1].Height;
          W := mipmap[x-1].Width;
          for my := 0 to H-1 do
            for mx := 0 to W-1 do
            begin
              Buffer[(my*W*4)+mx*4] := mipmap[x-1].Pixels[mx][my].R;
              Buffer[(my*W*4)+mx*4+1] := mipmap[x-1].Pixels[mx][my].G;
              Buffer[(my*W*4)+mx*4+2] := mipmap[x-1].Pixels[mx][my].B;
              if x = 1 then
                Buffer[(my*W*4)+mx*4+3] := ((img.Pixels[mx*2][my*2].A + img.Pixels[(mx*2) + 1][(my*2) +1].A) div 2)
              else
                Buffer[(my*W*4)+mx*4+3] := ((mipmap[x-2].Pixels[mx*2][my*2].A + mipmap[x-2].Pixels[(mx*2) + 1][(my*2) + 1].A ) div 2);
            end;
          texFile.Read(fsize,4);
          if chkXbox.Checked then
          begin
            setStatusMessage('TGA->RGBA: [4/5] Writing Xbox mipmap '+inttostr(x+1)+' ('+inttostr(H*W*4)+' bytes)...');
            xbox := TXboxTexture.create;
            try
              xbox.intex.Write(Buffer^,H*W*4);
              xbox.reswizzle(W,H,4,1);
              xbox.outtex.Seek(0,soFromBeginning);
              texFile.CopyFrom(xbox.outtex,H*W*4);
            finally
              xbox.destroy;
            end;
          end
          else
          begin
            setStatusMessage('TGA->RGBA: [4/5] Writing mipmap '+inttostr(x+1)+' ('+inttostr(H*W*4)+' bytes)...');
            texFile.Write(Buffer^,H*W*4);
          end;

//          mipmap[x-1].SaveToTGA32('h:\test-mipmap-'+inttostr(x)+'.tga')

//          bmp[x].SaveToFile('h:\test-mipmap-'+inttostr(x)+'.bmp');
        end;

        progressBar2.Percent := 100;
        setStatusMessage('TGA->RGBA: [5/5] Done! (Import successfull)');
      finally
        FreeMem(Buffer);
      end;
    except
      on E: exception do
      begin
        SetStatusMessage('Error: '+E.Message);
        MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
      end;
    end;
    img.Free;
    for x := 0 to High(mipmap) do
      if mipmap[x] is TSaveImage32 then
        mipmap[x].Free;
    for x := 0 to High(bmp) do
      if bmp[x] is TBitmap then
        bmp[x].Free;
   end;
  end
  else if (lstTEX.SelCount = 1) and (lstTEX.Selected.SubItems.Strings[1] = 'PALN') then
  begin

   importDialog.Title := 'Select TGA to import...';
   importDialog.Filter := 'Targa 32bpp with alpha channel (*.TGA)|*.TGA';

   if importDialog.Execute then
   begin

    panNeedUpdate.Visible := true;
    importfile := importDialog.FileName;

    IniFile.WriteString('HMCEditor','ImportPath',ExtractFilePath(importfile));

    if not(FileExists(importfile)) then
    begin
      SetStatusMessage('Error: TGA file not found');
      MessageDlg('Error: TGA file not found.', mtError, [mbOk], 0);
      exit;
    end;

// offset := 16;
    offset := strtoint(lstTEX.Selected.Caption);

    img8 := TSaveImage.Create;

    try
      setStatusMessage('TGA->PALN: [1/5] Reading TGA file...');
      img8.LoadFromTGA32(importfile);

      setStatusMessage('TGA->PALN: [2/5] Reading TEX file...');
      texFile.Seek(offset,soFromBeginning);
      texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
      Get0(texFile);
      texFile.Read(fsize,4);
      W := HDR.Width;
      H := HDR.Height;

      if (W <> img8.Width) or (H <> img8.Height) then
      begin
        raise Exception.Create('Wrong TGA resolution '+inttostr(img8.Width)+'x'+inttostr(img8.Height)+' [should be '+inttostr(W)+'x'+inttostr(H)+']');
      end;

      curOffset := texFile.Seek(0,soFromCurrent);
      texFile.Seek(fsize,soFromCurrent);
      texFile.Read(palsize,4);

      if (palsize <> img8.PaletteSize) then
      begin
        raise Exception.Create('Wrong number of unique colors in TGA : '+inttostr(img8.PaletteSize)+' [should be '+inttostr(palsize)+']');
      end;

      texFile.Seek(curOffset,soFromBeginning);

      setStatusMessage('TGA->PALN: [3/5] Converting data to PALN...');
      GetMem(Buffer,W*H);
      try
        for y := 0 to H-1 do
          for x := 0 to W-1 do
            Buffer[(y*W)+x] := img8.Pixels[x][y];
        if chkXbox.Checked then
        begin
          setStatusMessage('TGA->PALN: [4/5] Writing Xbox PALN data to TEX file ('+inttostr(H*W)+' bytes)...');
          xbox := TXboxTexture.create;
          try
            xbox.intex.write(Buffer^,H*W);
            xbox.reswizzle(W,H,1,1);
            xbox.outtex.Seek(0,soFromBeginning);
            texFile.CopyFrom(xbox.outtex,H*W);   
          finally
            xbox.destroy;
          end;
        end
        else
        begin
          setStatusMessage('TGA->PALN: [4/5] Writing PALN data to TEX file ('+inttostr(H*W)+' bytes)...');
          texFile.Write(Buffer^,H*W);
        end;
      finally
        FreeMem(Buffer);
      end;
      texFile.Seek(4,soFromCurrent); 
      GetMem(Buffer,palsize*4);
      try
        for y := 0 to palsize do
        begin
          Buffer[(y*4)] := img8.Palette[y].R;
          Buffer[(y*4)+1] := img8.Palette[y].G;
          Buffer[(y*4)+2] := img8.Palette[y].G;
          Buffer[(y*4)+3] := img8.Palette[y].A;
        end;
        setStatusMessage('TGA->PALN: [4/5] Writing PALN palette to TEX file ('+inttostr(palsize*4)+' bytes)...');
        texFile.Write(Buffer^,palsize*4);

        setStatusMessage('TGA->PALN: [5/5] Done! (Import successfull)');
      finally
        FreeMem(Buffer);
      end;
    except
      on E: exception do
      begin
        SetStatusMessage('Error: '+E.Message);
        MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
      end;
    end;
    img8.Free;
   end;
  end;

end;

function TfrmTEXeditor.strip0(str : string): string;
var pos0: integer;
begin

  pos0 := pos(chr(0),str);

  if pos0 > 0 then
    strip0 := copy(str, 1, pos0 - 1)
  else
    strip0 := str;

end;

procedure TfrmTEXeditor.parseTEX(fil: string);
var HDR: TEX_Header;
    ENT: TEX_Entry;
    NumE, NumShown, NumRGBA, NumDXT1, NumDXT3, NumPALN: cardinal;
    x: integer;
    nam: string;
    offsets: array[1..2048] of cardinal;
    item: TListItem;
    alwaysShow: boolean;
begin

  if texFile is TFileStream then
  begin
    setStatusMessage('Error: TEX file already opened.');
    MessageDlg('Error: TEX file already opened.', mtError, [mbOk], 0);
  end
  else if not(fileexists(fil)) then
  begin
    setStatusMessage('Error: TEX file not found.');
    MessageDlg('Error: TEX file not found.', mtError, [mbOk], 0);
  end
  else
  begin
    texFile := TFileStream.Create(fil,fmOpenReadWrite or fmShareDenyWrite); 
    try
      texFile.Read(HDR,SizeOf(HDR));
      if ((HDR.ID3 <> 3) or (HDR.ID4 <> 4) or (HDR.IndexOffset >= texFile.Size) or (HDR.UnknownOffset >= texFile.Size) or (HDR.UnknownOffset >= texFile.Size) or ((HDR.UnknownOffset-HDR.IndexOffset) <> $2000)) then
      begin
        closeTEX;
        setStatusMessage('Error: Source file doesn''t seems to be a Hitman: Contrats TEX file.');
        MessageDlg('Error: Source file doesn''t seems to be a Hitman: Contrats TEX file.', mtError, [mbOk], 0);
      end
      else
      begin
        SetStatusMessage('Parse TEX: [1/3] Reading offsets...');
        texFile.Seek(HDR.IndexOffset+$80,soFromBeginning);

        x := 0;

        repeat
          inc(x);
          texFile.read(Offsets[x],4);
        until Offsets[x] = 0;
        dec(x);

        NumE := x;
        NumShown := 0;
        NumRGBA := 0;
        NumDXT1 := 0;
        NumDXT3 := 0;
        NumPALN := 0;
        setNumEntries(NumE);

        SetStatusMessage('Parse TEX: [2/3] Reading entries information...');

        for x := 1 to NumE do
        begin

          texFile.seek(offsets[x],0);
          texFile.Read(ENT,SizeOf(ENT));
          nam := Strip0(Get0(texFile));

          alwaysShow := false;

          if ENT.Type1 = 'ABGR' then
            inc(NumRGBA)
          else if ENT.Type1 = '1TXD' then
            inc(NumDXT1)
          else if ENT.Type1 = '3TXD' then
            inc(NumDXT3)
          else if ENT.Type1 = 'NLAP' then
            inc(NumPALN)
          else
          begin
//            inc(NumUnk);
            alwaysShow := true;
          end;

          if (chkRGBAOnly.Checked and (ENT.Type1 = 'ABGR'))
          or (chkDXT1only.Checked and (ENT.Type1 = '1TXD'))
          or (chkDXT3only.Checked and (ENT.Type1 = '3TXD'))
          or (chkPALNonly.Checked and (ENT.Type1 = 'NLAP'))
          or alwaysShow
          then
          begin
            inc(NumShown);
            item := lstTEX.Items.Add;
            item.Caption := inttostr(Offsets[x]);
            item.SubItems.Add(nam);
            item.SubItems.Add(revstr(ent.Type1));
            item.SubItems.Add(inttostr(ENT.Size));
            if (ENT.NumMipMap > 1) then
              item.SubItems.Add(inttostr(ENT.Width)+'x'+inttostr(ENT.Height)+' w/MipMap')
            else
              item.SubItems.Add(inttostr(ENT.Width)+'x'+inttostr(ENT.Height));
          end;
          //FSE_Add(StringReplace(nam,'/','\',[rfReplaceAll])+'.'+revstr(ent.Type1),Offsets[x],ENT.Size,0,0);

        end;
        SetNumEntries(NumShown);
        SetStatusMessage('Parse TEX: Done! '+inttostr(NumRGBA)+' RGBA / '+inttostr(NumDXT1)+' DXT1 / '+inttostr(NumDXT3)+' DXT3 / '+inttostr(NumPALN) +' PALN textures in TEX ('+inttostr(NumE-NumShown)+' textures were hidden)');
        butReload.Enabled := true;
      end;
    except
      on E: Exception do
      begin
        closeTEX;
        setStatusMessage('Error: '+E.Message);
        MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
      end;
    end;

  end;

end;

function TfrmTEXeditor.get0(stm: TStream): string;
var tchar: Char;
    res: string;
begin

  repeat
    stm.Read(tchar,1);
    res := res + tchar;
  until tchar = chr(0);

  result := res;

end;

function TfrmTEXeditor.revstr(str: string): string;
var res: string;
    x: integer;
begin

  for x := 1 to length(str) do
    res := str[x]+res;

  revstr := res;

end;

procedure TfrmTEXeditor.butOpenClick(Sender: TObject);
var partname: string;
    texname: string;
begin

  openDialog.InitialDir := IniFile.ReadString('HMCEditor','TEXPath',ExtractFilePath(Application.ExeName));

  if not(Zipmaster.busy) and openDialog.Execute then
  begin
    closeTEX;
    panNeedUpdate.Visible := false;
    butUpdate.Enabled := false;
    txtZipFile.Text := '';
    txtSource.Text := '';
    Zipmaster.ZipFileName := openDialog.FileName;
    if (Zipmaster.ErrCode = 0) or (Zipmaster.ErrCode = 10204) then
    begin
      partname := changefileext(extractfilename(openDialog.FileName),'');
      if testHMZip(partname) then
      begin
        txtZipFile.Text := openDialog.FileName;
        IniFile.WriteString('HMCEditor','TEXPath',ExtractFilePath(openDialog.FileName));
        Zipmaster.FSpecArgs.Clear;
        Zipmaster.ExtrBaseDir := IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\');
        Zipmaster.DLLDirectory := ExtractFilePath(Application.ExeName)+'ZipDll\';
        texname := getTEXinZIP;
        txtSource.Text := texname;
        Zipmaster.FSpecArgs.Add(texname);
        deleteTempFiles;
        currentTEXfile := IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\');
        if RightStr(currentTEXfile,1) <> '\' then
          currentTEXfile := currentTEXfile + '\';
        currentTEXfile := currentTEXfile + texname;
        currentZipAction := tcaExtract;
        ProgressBar2.Caption := 'Unzipping... %d%%';
        try
          Zipmaster.Extract;
        except
          on E:Exception do
          begin
            setStatusMessage('Error: '+e.Message);
            MessageDlg('Error: '+E.Message,mtError,[mbOk],0);
          end;
        end;
      end
      else
      begin
        SetStatusMessage('Error: Not an Hitman: Contracts ZIP file.');
        MessageDlg('Error: Not an Hitman: Contracts ZIP archive.'+#10+#10+'Note: You must not rename Hitman: Contracts ZIP files'+#10+'or this tool will be unable to recognize them.',mtWarning,[mbOk],0);
      end;
   //    closeTEX;
   //    txtSource.Text := openDialog.FileName;
   //    parseTEX(openDialog.FileName);
    end;
  end;

end;

procedure TfrmTEXeditor.lstTEXSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin

  if lstTEX.SelCount > 1 then
  begin
    butImport.Enabled := false;
    butExport.Enabled := true;
  end
  else
  begin
    if (Item.SubItems[1] = 'RGBA') or (Item.SubItems[1] = 'DXT1') or (Item.SubItems[1] = 'DXT3') or (Item.SubItems[1] = 'PALN') then
    begin
      butImport.Enabled := true;
      butExport.Enabled := true;
    end
    else
    begin
      butImport.Enabled := false;
      butExport.Enabled := false;
    end;
  end;

end;

procedure TfrmTEXeditor.closeTEX;
begin

  if texFile is TFileStream then
    texFile.Free;

  if lstTEX.Items.Count > 0 then
    lstTEX.Clear;

  texFile := nil;
//  txtSource.Text := '';
  butImport.Enabled := false;
  butExport.Enabled := false;
  setNumEntries(0);
  setStatusMessage('Idle');

end;

procedure TfrmTEXeditor.setNumEntries(num: integer);
begin

  status.Panels.Items[1].Text := inttostr(num)+' entries';
  refresh;

end;

procedure TfrmTEXeditor.setStatusMessage(msg: string);
begin

  status.Panels.Items[2].Text := msg;
  refresh;

end;

procedure TfrmTEXeditor.butExitClick(Sender: TObject);
begin

  if canCloseTool then
  begin
    closeTEX;
    deleteTempFiles;
    Application.Terminate;
  end;

end;

procedure TfrmTEXeditor.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin

 canClose := canCloseTool;

 if canClose then
 begin
   closeTEX;
   deleteTempFiles;
 end;

end;

procedure TfrmTEXeditor.FormCreate(Sender: TObject);
var inisrc: string;
begin

  inisrc := ChangeFileExt(Application.ExeName,'.ini');

  sortColumn := 0;
  sortInvert := false;

  IniFile := TIniFile.Create(inisrc);
  if not(IniFile.SectionExists('HMCEditor')) then
  begin
    IniFile.WriteString('HMCEditor','TEXPath',ExtractFilePath(Application.ExeName));
    IniFile.WriteString('HMCEditor','ExportPath',ExtractFilePath(Application.ExeName));
    IniFile.WriteString('HMCEditor','ImportPath',ExtractFilePath(Application.ExeName));
    IniFile.WriteString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\');
    IniFile.WriteString('HMCEditor','SearchValue','');
    IniFile.WriteBool('HMCEditor','ShowOnlyRGBA',true);
    IniFile.WriteBool('HMCEditor','ShowOnlyDXT1',true);
    IniFile.WriteBool('HMCEditor','ShowOnlyDXT3',true);
    IniFile.WriteBool('HMCEditor','ShowOnlyPALN',true);
    IniFile.WriteBool('HMCEditor','SaveScript',false);
    IniFile.WriteBool('HMCEditor','ReadWarning',false);
    IniFile.WriteBool('HMCEditor','XboxMode',false);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','SearchValue')) then
  begin
    IniFile.WriteString('HMCEditor','SearchValue','');
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','TEXPath')) then
  begin
    IniFile.WriteString('HMCEditor','TEXPath',ExtractFilePath(Application.ExeName));
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','TempPath')) then
  begin
    IniFile.WriteString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\');
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ReadWarning')) then
  begin
    IniFile.WriteBool('HMCEditor','ReadWarning',false);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ShowOnlyRGBA')) then
  begin
    IniFile.WriteBool('HMCEditor','ShowOnlyRGBA',true);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ShowOnlyDXT1')) then
  begin
    IniFile.WriteBool('HMCEditor','ShowOnlyDXT1',true);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ShowOnlyDXT3')) then
  begin
    IniFile.WriteBool('HMCEditor','ShowOnlyDXT3',true);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ShowOnlyPALN')) then
  begin
    IniFile.WriteBool('HMCEditor','ShowOnlyPALN',true);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','SaveScript')) then
  begin
    IniFile.WriteBool('HMCEditor','SaveScript',false);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','XboxMode')) then
  begin
    IniFile.WriteBool('HMCEditor','XboxMode',false);
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ExportPath')) then
  begin
    IniFile.WriteString('HMCEditor','ExportPath',ExtractFilePath(Application.ExeName));
    IniFile.UpdateFile;
  end
  else if not(IniFile.ValueExists('HMCEditor','ImportPath')) then
  begin
    IniFile.WriteString('HMCEditor','ImportPath',ExtractFilePath(Application.ExeName));
    IniFile.UpdateFile;
  end;

  chkRGBAonly.Checked := IniFile.ReadBool('HMCEditor','ShowOnlyRGBA',true);
  chkDXT1only.Checked := IniFile.ReadBool('HMCEditor','ShowOnlyDXT1',true);
  chkDXT3only.Checked := IniFile.ReadBool('HMCEditor','ShowOnlyDXT3',true);
  chkPALNonly.Checked := IniFile.ReadBool('HMCEditor','ShowOnlyPALN',true);
  chkScript.Checked := IniFile.ReadBool('HMCEditor','SaveScript',true);
  chkXbox.Checked := IniFile.ReadBool('HMCEditor','XboxMode',false); 
  txtSearch.Text := IniFile.ReadString('HMCEditor','SearchValue','');

  if not(DirExists(IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\'))) then
    if not(forceDirectories(IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\'))) then
    begin
      MessageDlg('Temp directory doesn''t exist.'+#10+'Impossible to create temp directory.'+#10+#10+IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\')+#10+#10+'Program will now close.',mtError,[mbOk],0);
      Application.Terminate;
    end;

  if not(IniFile.ReadBool('HMCEditor','ReadWarning',false)) then
    if (MessageDlg('Welcome to'+#10+'Hitman: Contracts TEX Editor'+#10+#10+'This tool can modify your Hitman: Contracts [Hm:C] .TEX files.'+#10+'You should consider making a backup of those files.'+#10+#10+'This tool is provided with no guarantee.'+#10+'It is in no way an official tool.'+#10+#10+'Do you understand and accept that this tool might mess up your TEX files ?',mtConfirmation,[mbYes, mbNo],0) = mrNo) then
    begin
      MessageDlg('Too bad... Run it back when you are not afraid anymore. :-P',mtInformation,[mbOk],0);
      Application.Terminate;
    end
    else
      IniFile.WriteBool('HMCEditor','ReadWarning',true);

  ZipMaster.Load_Zip_Dll;
  ZipMaster.Load_Unz_Dll;

  SetStatusMessage('Information: ZipMaster v'+zipmaster.VersionInfo+' loaded! (UnZip DLL v'+inttostr(trunc(Zipmaster.UnzVers / 100))+'.'+inttostr(Zipmaster.UnzVers - (trunc(Zipmaster.UnzVers / 100)*100))+' / Zip DLL v'+inttostr(trunc(Zipmaster.ZipVers / 100))+'.'+inttostr(Zipmaster.ZipVers - (trunc(Zipmaster.ZipVers / 100)*100))+')');

end;

procedure TfrmTEXeditor.butExportClick(Sender: TObject);
var outsrc, outdir, origname: string;
    offset, selc, x: integer;
begin

  if (lstTEX.SelCount = 1) and ((lstTEX.Selected.SubItems.Strings[1] = 'DXT1') or (lstTEX.Selected.SubItems.Strings[1] = 'DXT3')) then
  begin

    setStatusMessage(lstTEX.Selected.SubItems.Strings[1]+'->DDS: Asking for output filename...');
    offset := strtoint(lstTEX.Selected.Caption);
    origname := lstTEX.Selected.SubItems.Strings[0];

    saveDialog.InitialDir := IniFile.ReadString('HMCEditor','ExportPath',ExtractFilePath(Application.ExeName));
    outsrc := StringReplace(origname,'\','_',[rfReplaceAll]);
    outsrc := StringReplace(outsrc,'/','_',[rfReplaceAll]);
    outsrc := outsrc + '.dds';
    saveDialog.FileName := outsrc;
    saveDialog.Filter := 'Microsoft DirectDraw Surface (*.DDS)|*.DDS';
    saveDialog.Title := 'Save DDS file...';

    if saveDialog.Execute then
      try
        IniFile.WriteString('HMCEditor','ExportPath',ExtractFilePath(saveDialog.FileName));
        exportDXT(lstTEX.Selected.SubItems.Strings[1][4],offset,saveDialog.FileName)
      except
        on e:exception do
        begin
          SetStatusMessage('Error: '+E.Message);
          MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
        end;
      end
    else
      setStatusMessage(lstTEX.Selected.SubItems.Strings[1]+'->DDS: Canceled.');

  end
  else if (lstTEX.SelCount = 1) and (lstTEX.Selected.SubItems.Strings[1] = 'PALN') then
  begin

    setStatusMessage('PALN->TGA: Asking for output filename...');
    offset := strtoint(lstTEX.Selected.Caption);
    origname := lstTEX.Selected.SubItems.Strings[0];

    saveDialog.InitialDir := IniFile.ReadString('HMCEditor','ExportPath',ExtractFilePath(Application.ExeName));
    outsrc := StringReplace(origname,'\','_',[rfReplaceAll]);
    outsrc := StringReplace(outsrc,'/','_',[rfReplaceAll]);
    outsrc := outsrc + '.tga';
    saveDialog.FileName := outsrc;
    saveDialog.Filter := 'Targa 32bpp with alpha channel (*.TGA)|*.TGA';
    saveDialog.Title := 'Save TGA file...';

    if saveDialog.Execute then
      try
        IniFile.WriteString('HMCEditor','ExportPath',ExtractFilePath(saveDialog.FileName));
        exportPALN(offset,saveDialog.FileName)
      except
        on e:exception do
        begin
          SetStatusMessage('Error: '+E.Message);
          MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
        end;
      end
    else
      setStatusMessage('PALN->TGA: Canceled.');

  end
  else if (lstTEX.SelCount = 1) and (lstTEX.Selected.SubItems.Strings[1] = 'RGBA') then
  begin

    setStatusMessage('RGBA->TGA: [0/4] Asking for output filename...');
    offset := strtoint(lstTEX.Selected.Caption);
    origname := lstTEX.Selected.SubItems.Strings[0];

    saveDialog.InitialDir := IniFile.ReadString('HMCEditor','ExportPath',ExtractFilePath(Application.ExeName));
    outsrc := StringReplace(origname,'\','_',[rfReplaceAll]);
    outsrc := StringReplace(outsrc,'/','_',[rfReplaceAll]);
    outsrc := outsrc + '.tga';
    saveDialog.FileName := outsrc;
    saveDialog.Filter := 'Targa 32bpp with alpha channel (*.TGA)|*.TGA';
    saveDialog.Title := 'Save TGA file...';

    if saveDialog.Execute then
      try
        IniFile.WriteString('HMCEditor','ExportPath',ExtractFilePath(saveDialog.FileName));
        exportRGBA(offset,saveDialog.FileName)
      except
        on e:exception do
        begin
          SetStatusMessage('Error: '+E.Message);
          MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
        end;
      end
    else
      setStatusMessage('RGBA->TGA: Canceled.');

  end
  else if lstTEX.SelCount > 1 then
  begin
    selectDir.InitialDir := IniFile.ReadString('HMCEditor','ExportPath',ExtractFilePath(Application.ExeName));

    if selectDir.Execute then
    begin
      IniFile.WriteString('HMCEditor','ExportPath',selectDir.Directory);

      if rightstr(selectDir.Directory, 1) = '\' then
        outdir := selectDir.Directory
      else
        outdir := selectDir.Directory + '\';

      selc := 0;
      ProgressBar2.Caption := 'Multi-exporting... %d%%';

      for x := 0 to lstTEX.Items.Count-1 do
        if lstTEX.Items.Item[x].Selected then
        begin
          inc(selc);
          offset := strtoint(lstTEX.Items.Item[x].Caption);
          origname := lstTEX.Items.Item[x].SubItems.Strings[0];
          outsrc := StringReplace(origname,'\','_',[rfReplaceAll]);
          outsrc := StringReplace(outsrc,'/','_',[rfReplaceAll]);

          outsrc := outdir + outsrc;

          if (lstTEX.Items.Item[x].SubItems.Strings[1] = 'DXT1')
          or (lstTEX.Items.Item[x].SubItems.Strings[1] = 'DXT3') then
          begin
            exportDXT(lstTEX.Items.Item[x].SubItems.Strings[1][4],offset,outsrc + '.dds');
          end
          else if lstTEX.Items.Item[x].SubItems.Strings[1] = 'RGBA' then
          begin
            exportRGBA(offset,outsrc + '.tga');
          end
          else if lstTEX.Items.Item[x].SubItems.Strings[1] = 'PALN' then
          begin
            exportPALN(offset,outsrc + '.tga');
          end;

          progressBar2.Percent := round((selc / lstTEX.SelCount) * 100);

        end;

    end
    else
      setStatusMessage('Multi-export: Canceled.');

  end;

end;

procedure TfrmTEXeditor.chkRGBAonlyClick(Sender: TObject);
begin

  IniFile.WriteBool('HMCEditor','ShowOnlyRGBA',chkRGBAonly.Checked);

end;

procedure TfrmTEXeditor.lblURLClick(Sender: TObject);
begin

  ShellExec(application.Handle,'open',lblURL.Caption,'','',SW_SHOW);

end;

procedure TfrmTEXeditor.chkScriptClick(Sender: TObject);
begin

  IniFile.WriteBool('HMCEditor','SaveScript',chkRGBAonly.Checked);

end;

procedure TfrmTEXeditor.chkDXT1onlyClick(Sender: TObject);
begin

  IniFile.WriteBool('HMCEditor','ShowOnlyDXT1',chkDXT1only.Checked);

end;

procedure TfrmTEXeditor.chkDXT3onlyClick(Sender: TObject);
begin

  IniFile.WriteBool('HMCEditor','ShowOnlyDXT3',chkDXT3only.Checked);

end;

procedure TfrmTEXeditor.chkPALNOnlyClick(Sender: TObject);
begin

  IniFile.WriteBool('HMCEditor','ShowOnlyPALN',chkPALNonly.Checked);

end;

procedure TfrmTEXeditor.butReloadClick(Sender: TObject);
//var src: string;
begin

  closeTEX;
  parseTEX(currentTEXfile);

end;

procedure TfrmTEXeditor.butSearchClick(Sender: TObject);
var x: integer;
    sval: string;
begin

  IniFile.WriteString('HMCEditor','SearchValue',txtSearch.Text);
  sval := uppercase(txtSearch.Text);

  butSearchPrev.Enabled := false;
  butSearchNext.Enabled := false;

  for x := 0 to lstTEX.Items.Count-1 do
  begin
    if pos(sval,Uppercase(lstTEX.Items.Item[x].SubItems.Strings[0])) > 0 then
    begin
//      lstTex.ItemIndex := x;
      lstTex.Items.Item[x].Focused := true;
      lstTex.ItemFocused.MakeVisible(false);
      lstTex.SetFocus;
      lstTex.Refresh;
      butSearchPrev.Enabled := true;
      butSearchNext.Enabled := true;
      break;
    end;
  end;

end;

procedure TfrmTEXeditor.butSearchNextClick(Sender: TObject);
var x: integer;
    sval: string;
begin

  sval := uppercase(txtSearch.Text);

  for x := lstTex.ItemFocused.Index+1 to lstTEX.Items.Count-1 do
  begin
    if pos(sval,Uppercase(lstTEX.Items.Item[x].SubItems.Strings[0])) > 0 then
    begin
//      lstTex.ItemIndex := x;
      lstTex.Items.Item[x].Focused := true;
//      lstTex.Items.Item[x].Selected := true;
      lstTex.ItemFocused.MakeVisible(false);
      lstTex.SetFocus;
      lstTex.Refresh;
      break;
    end;
  end;

  lstTex.SetFocus;

end;

function TfrmTEXeditor.getInt64Rec(src: int64): Int64Rec;
begin

  Move(src,result,8);

end;

function TfrmTEXeditor.getInt64(lo, high: integer): Int64;
var mid: int64rec;
begin

  mid.Lo := lo;
  mid.Hi := high;

  move(mid,result,8);

end;

procedure TfrmTEXeditor.panTopLeftResize(Sender: TObject);
begin

  txtZipFile.Width := panTopLeft.Width - 130;
  txtSource.Width := panTopLeft.Width - 130;
  butOpen.Left := panTopLeft.Width - (butOpen.Width + 10);
  butUpdate.Left := panTopLeft.Width - (butUpdate.Width + 10);
  panNeedUpdate.Left := panTopLeft.Width - (panNeedUpdate.Width + 7);

end;

procedure TfrmTEXeditor.panBottomResize(Sender: TObject);
begin

   lblURL.Left := panBottom.Width - (lblURL.Width + 8);
   bvlBottom.Width := panBottom.Width;
   butExit.Left := panBottom.Width - (butExit.Width + 5);
   progressBar2.Width := panBottom.Width - 259;

end;

procedure TfrmTEXeditor.FormResize(Sender: TObject);
begin

  if frmTEXeditor.Width < 640 then
    frmTEXEditor.Width := 640;

end;

procedure TfrmTEXeditor.lstTEXResize(Sender: TObject);
begin

  lstTEX.Columns.Items[1].Width := lstTEX.Width - (lstTEX.Columns.Items[0].Width +
                                                   lstTEX.Columns.Items[2].Width +
                                                   lstTEX.Columns.Items[3].Width +
                                                   lstTEX.Columns.Items[4].Width +
                                                   20);

end;

procedure TfrmTEXeditor.butSearchPrevClick(Sender: TObject);
var x: integer;
    sval: string;
begin

  sval := uppercase(txtSearch.Text);

  for x := lstTex.ItemFocused.Index-1 downto 0 do
  begin
    if pos(sval,Uppercase(lstTEX.Items.Item[x].SubItems.Strings[0])) > 0 then
    begin
//      lstTex.ItemIndex := x;
      lstTex.Items.Item[x].Focused := true;
//      lstTex.Items.Item[x].Selected := true;
      lstTex.ItemFocused.MakeVisible(false);
      lstTex.SetFocus;
      lstTex.Refresh;
      break;
    end;
  end;

  lstTex.SetFocus;

end;

procedure TfrmTEXeditor.lstTEXCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin

  case sortColumn of
    0: Compare := strtoint(Item1.Caption) - strtoint(Item2.Caption);
    1: Compare := CompareText(Item1.SubItems.Strings[0],Item2.SubItems.Strings[0]);
    2: Compare := CompareText(Item1.SubItems.Strings[1],Item2.SubItems.Strings[1]);
    3: Compare := strtoint(Item1.SubItems.Strings[2]) - strtoint(Item2.SubItems.Strings[2]);
    4: Compare := CompareText(Item1.SubItems.Strings[3],Item2.SubItems.Strings[3]);
  end;

  if sortInvert then
    if compare < 0 then
      Compare := 1
    else if compare > 0 then
      Compare := -1;

end;

procedure TfrmTEXeditor.lstTEXColumnClick(Sender: TObject;
  Column: TListColumn);
var x: integer;
begin

  if SortColumn = Column.Index then
    sortInvert := not(sortInvert)
  else
  begin
    sortInvert := false;
    sortColumn := Column.Index;
  end;

  for x := 0 to lstTEX.Columns.Count-1 do
    if (copy(lstTEX.Columns.Items[x].Caption,0,1) = '+')
    or (copy(lstTEX.Columns.Items[x].Caption,0,1) = '-') then
      lstTEX.Columns.Items[x].Caption := Copy(lstTEX.Columns.Items[x].Caption,2,length(lstTEX.Columns.Items[x].Caption)-1);

  if sortInvert then
    Column.Caption := '-'+Column.Caption
  else
    Column.Caption := '+'+Column.Caption;

  lstTEX.CustomSort(nil,0);

end;

procedure TfrmTEXeditor.ZipMasterMessage(Sender: TObject; ErrCode: Integer;
  Message: String);
begin

//  if (not(currentZIPaction = tcaUpdate) and (ErrCode > 0))
//  or ((currentZIPaction = tcaUpdate) and (ErrCode > 0) and (ErrCode <= 11000)) then
  if ErrCode > 0 then
  begin

    setStatusMessage('Zip Error: '+message);
    MessageDlg('Zip Error: '+message,mtError,[mbOk],0);

  end
  else
  begin

    setStatusMessage(message);

  end;

end;

function TfrmTEXeditor.testHMZip(trunc: string): boolean;
var x: integer;
begin

  result := true;
  trunc := uppercase(trunc);

  for x := 0 to Zipmaster.ZipContents.Count-1 do
  begin
    result := result and (pos(trunc, uppercase(Zipmaster.DirEntry[x]^.FileName)) > 0);
    if not(result) then
      break;
  end;

end;

procedure TfrmTEXeditor.ZipMasterTotalProgress(Sender: TObject;
  TotalSize: Cardinal; PerCent: Integer);
begin

  if Percent > 0 then
    ProgressBar2.Percent := Percent;

end;

function TfrmTEXeditor.getTEXinZIP: string;
var x: integer;
begin

  for x := 0 to Zipmaster.ZipContents.Count-1 do
  begin
    if (pos('.TEX', uppercase(Zipmaster.DirEntry[x]^.FileName)) > 0) then
    begin
      result := Zipmaster.DirEntry[x]^.FileName;
      break;
    end;
  end;

end;

procedure TfrmTEXeditor.deleteTempFilesRec(dir: String);
var sr: TSearchRec;
begin

  if RightStr(dir,1) <> '\' then
    dir := dir + '\';

  if FindFirst(dir+'*.*',faAnyFile,sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
        if (sr.Attr and faDirectory) = faDirectory then
        begin
          deleteTempFilesRec(dir+sr.Name+'\');
          rmdir(dir+sr.Name);
        end
        else
          deletefile(dir+sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

end;

procedure TfrmTEXeditor.ZipMasterProgress(Sender: TObject;
  ProgrType: ProgressType; Filename: String; FileSize: Cardinal);
begin

  if ProgrType = EndOfBatch	then
  begin
    if (currentZipAction = tcaExtract) then
    begin
      currentZipAction := tcaIdle;
      parseTex(currentTEXfile);
      butUpdate.Enabled := true;
    end
    else if (currentZipAction = tcaUpdate) then
    begin
      panNeedUpdate.Visible := false;
      setStatusMessage('Updated ZIP file with success!');
    end;
  end;

end;

procedure TfrmTEXeditor.butUpdateClick(Sender: TObject);
begin

  if not(Zipmaster.Busy) then
  begin
    Zipmaster.RootDir := IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\');
    Zipmaster.FSpecArgs.Clear;
    Zipmaster.FSpecArgs.Add(txtSource.text);
    currentZIPAction := tcaUpdate;
    ProgressBar2.Caption := 'Updating ZIP... %d%%';
    try
      Zipmaster.Add;
    except
      on E:Exception do
      begin
        setStatusMessage('Error: '+e.Message);
        MessageDlg('Error: '+E.Message,mtError,[mbOk],0);
      end;
    end;
    if Zipmaster.SuccessCnt = 1 then
      MessageDlg('Updated ZIP file successfully!',mtInformation,[mbOk],0);
  end;

end;

procedure TfrmTEXeditor.deleteTempFiles;
var tempdir: string;
begin

  tempdir := IniFile.ReadString('HMCEditor','TempPath',ExtractFilePath(Application.ExeName)+'Temp\');
  if RightStr(tempdir,1) <> '\' then
    tempdir := tempdir + '\';

  deleteTempFilesRec(tempdir);

end;

function TfrmTEXeditor.canCloseTool: boolean;
begin

  result := (panNeedUpdate.visible and (MessageDlg('ATTENTION: You haven''t updated the ZIP file with'+#10+'your changes done to the TEX file.'+#10+#10+'Are you SURE you want to exit WITHOUT keeping changes?',mtConfirmation,[mbYes, mbNo],0) = mrYes))
         or (not(panNeedUpdate.Visible) and (MessageDlg('Are you sure you want to close the program ?',mtConfirmation,[mbYes, mbNo],0) = mrYes));

end;

procedure TfrmTEXeditor.exportRGBA(offset: integer; outname: string);
var x, y, W, H, fsize: integer;
    img: TSaveImage32;
    HDR: HMC_TEX_Entry;
    Buffer: PByteArray;
    xbox: TXboxTexture;
begin

  setStatusMessage('RGBA->TGA: [1/4] Reading RGBA header in TEX file...');
  texFile.Seek(offset,soFromBeginning);
  texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
  Get0(texFile);

  if (HDR.Type1 <> 'ABGR') or (HDR.Type2 <> 'ABGR') then
    raise Exception.Create('Not an RGBA texture!');

  texFile.Read(fsize,4);
  W := HDR.Width;
  H := HDR.Height;

  img := TSaveImage32.Create;
  try
    setStatusMessage('RGBA->TGA: [2/4] Reading RGBA data from TEX file...');
    img.SetSize(W,H);
    GetMem(Buffer,W*H*4);
    try
      if chkXbox.Checked then
      begin
        setStatusMessage('RGBA->TGA: [2/4] Reading RGBA data from TEX file... Xbox unswizzle...');
        xbox := TXboxTexture.create;
        try
          xbox.intex.CopyFrom(texFile,H*W*4);
          xbox.unswizzle(W,H,4,1);
          xbox.outtex.Seek(0,soFromBeginning);
          xbox.outtex.Read(Buffer^,H*W*4);
        finally
          xbox.destroy;
        end;
      end
      else
        texFile.Read(Buffer^,H*W*4);
      setStatusMessage('RGBA->TGA: [3/4] Converting RGBA data...');
      for y := 0 to H-1 do
        for x := 0 to W-1 do
        begin
          img.Pixels[x][y].R := Buffer[(y*W*4)+x*4];
          img.Pixels[x][y].G := Buffer[(y*W*4)+x*4+1];
          img.Pixels[x][y].B := Buffer[(y*W*4)+x*4+2];
          img.Pixels[x][y].A := Buffer[(y*W*4)+x*4+3];
        end;
    finally
      FreeMem(Buffer);
    end;
    setStatusMessage('RGBA->TGA: [4/4] Saving Targa 32bpp file...');
    img.SaveToTGA32(outname);
{        if chkScript.Checked then
        begin
          setStatusMessage('TGA->RGBA: [5/5] Done! (Import successfull) [Writing TIS script...]');
          scriptFile := IniFile.Create(changeFileExt(outortfile,'.tis'));
          try
            scriptFile.WriteInteger('TIS','Version',1);
            scriptFile.WriteString('TIS','Description','Automatically generated by '+Application.Title);
            scriptFile.WriteString('TIS','Author',Application.Title);
            section := 'Inject-'+changeFileExt(extractFileName(txtSource.Text),'-')+inttostr(HDR.Index)+'-'+StringReplace(StringReplace(StringReplace(lstTex.Selected.SubItems.Strings[0],'\','_',[rfReplaceAll]),'/','_',[rfReplaceAll]),'.','_',[rfReplaceAll]);
            scriptFile.WriteString(section,'TexFile',extractFileName(txtSource.Text));
            scriptFile.WriteString(section,'SrcFile',importFile);
            scriptFile.WriteString(section,'Texture',LstTEX.Selected.SubItems.Strings[0]);
            scriptFile.WriteInteger(section,'Size',HDR.Size);
            scriptFile.WriteInteger(section,'MainSize',MainSize);
            scriptFile.WriteInteger(section,'Index',HDR.Index);
            scriptFile.WriteInteger(section,'Width',HDR.Width);
            scriptFile.WriteInteger(section,'Height',HDR.Height);
            scriptFile.WriteInteger(section,'MipMapLevel',HDR.NumMipMap);
            if HDR.Type1 = 'AGBR' then
              scriptFile.WriteInteger(section,'Type',1)
            else if HDR.Type1 = '1TXD' then
              scriptFile.WriteInteger(section,'Type',2)
            else if HDR.Type1 = '3TXD' then
              scriptFile.WriteInteger(section,'Type',3)
            else if HDR.Type1 = 'NLAP' then
              scriptFile.WriteInteger(section,'Type',4);
            scriptFile.UpdateFile;
          finally
            scriptFile.Free;
          end;
        end;}
    setStatusMessage('RGBA->TGA: Done! (Export successfull)');
  except
    on E: exception do
    begin
      SetStatusMessage('Error: '+E.Message);
      MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
    end;
  end;
  img.Free;

end;

procedure TfrmTEXeditor.exportDXT(dxtchar: char; offset: integer; outname: string);
var HDR: HMC_TEX_Entry;
    DDS: DDSHeader;
    outFile: TFileStream;
    fsize: cardinal;
    x: integer;
begin

  setStatusMessage('DXT'+dxtchar+'->DDS: [1/3] Reading DXT'+dxtchar+' header in TEX file...');
  texFile.Seek(offset,soFromBeginning);
  texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
  Get0(texFile);

  if (HDR.Type1 <> (dxtchar+'TXD')) or (HDR.Type2 <> (dxtchar+'TXD')) then
    raise Exception.Create('Not an DXT'+dxtchar+' texture!');

  setStatusMessage('DXT'+dxtchar+'->DDS: [2/3] Writing DDS Header...');

  outFile := TFileStream.Create(outname,fmCreate);
  try
    texFile.Read(fsize,4);
    FillChar(DDS,SizeOf(DDSHeader),0);
    DDS.ID[0] := 'D';
    DDS.ID[1] := 'D';
    DDS.ID[2] := 'S';
    DDS.ID[3] := ' ';
    DDS.SurfaceDesc.dwSize := 124;
    DDS.SurfaceDesc.dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH or DDSD_PIXELFORMAT or DDSD_LINEARSIZE;
    if HDR.NumMipMap > 1 then
      DDS.SurfaceDesc.dwFlags := DDS.SurfaceDesc.dwFlags or DDSD_MIPMAPCOUNT;
    DDS.SurfaceDesc.dwHeight := HDR.Height;
    DDS.SurfaceDesc.dwWidth := HDR.Width;
    DDS.SurfaceDesc.dwPitchOrLinearSize := fsize;
    DDS.SurfaceDesc.dwMipMapCount := HDR.NumMipMap;
    DDS.SurfaceDesc.ddpfPixelFormat.dwSize := 32;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFlags := DDPF_FOURCC;
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[0] := 'D';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[1] := 'X';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[2] := 'T';
    DDS.SurfaceDesc.ddpfPixelFormat.dwFourCC[3] := lstTEX.Selected.SubItems.Strings[1][4];
    DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDSCAPS_TEXTURE;
    if HDR.NumMipMap > 1 then
      DDS.SurfaceDesc.ddsCaps.dwCaps1 := DDS.SurfaceDesc.ddsCaps.dwCaps1 or DDSCAPS_COMPLEX or DDSCAPS_MIPMAP;
    outFile.Write(DDS,SizeOf(DDSHeader));
    setStatusMessage('DXT'+dxtchar+'->DDS: [3/3] Writing Main Image Data...');
    outFile.CopyFrom(texFile,fsize);
    for x := 2 to HDR.NumMipMap do
    begin
      setStatusMessage('DXT'+dxtchar+'->DDS: [3/3] Writing MipMap level '+inttostr(x)+' Image Data...');
      texFile.Read(fsize,4);
      outFile.CopyFrom(texFile,fsize);
    end;
{        if chkScript.Checked then
        begin
          setStatusMessage(lstTEX.Selected.SubItems.Strings[1]+'->DDS: Done! (Export successfull) [Writing .TPS information...]');
          scriptFile := IniFile.Create(changeFileExt(outsrc,'.tps'));
          try
            scriptFile.WriteInteger('TPS','Version',1);
            section := 'Inject-'+changeFileExt(extractFileName(txtSource.Text),'-')+inttostr(HDR.Index)+'-'+StringReplace(StringReplace(StringReplace(lstTex.Selected.SubItems.Strings[0],'\','_',[rfReplaceAll]),'/','_',[rfReplaceAll]),'.','_',[rfReplaceAll]);
            scriptFile.WriteString(section,'TexFile',extractFileName(txtSource.Text));
            scriptFile.WriteString(section,'SrcFile',outsrc);
            scriptFile.WriteString(section,'Texture',LstTEX.Selected.SubItems.Strings[0]);
            scriptFile.WriteInteger(section,'Size',HDR.Size);
            scriptFile.WriteInteger(section,'MainSize',MainSize);
            scriptFile.WriteInteger(section,'Index',HDR.Index);
            scriptFile.WriteInteger(section,'Width',HDR.Width);
            scriptFile.WriteInteger(section,'Height',HDR.Height);
            scriptFile.WriteInteger(section,'MipMapLevel',HDR.NumMipMap);
            if HDR.Type1 = 'AGBR' then
              scriptFile.WriteInteger(section,'Type',1)
            else if HDR.Type1 = '1TXD' then
              scriptFile.WriteInteger(section,'Type',2)
            else if HDR.Type1 = '3TXD' then
              scriptFile.WriteInteger(section,'Type',3)
            else if HDR.Type1 = 'NLAP' then
              scriptFile.WriteInteger(section,'Type',4);
            scriptFile.UpdateFile;
          finally
            scriptFile.Free;
          end;
        end;}
    setStatusMessage('DXT'+dxtchar+'->DDS: Done! (Export successfull)');
  except
    on e: exception do
    begin
      SetStatusMessage('Error: '+E.Message);
      MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
    end;
  end;
  outFile.Free;

end;

procedure TfrmTEXeditor.exportPALN(offset: integer; outname: string);
var x, y, W, H, fsize: integer;
    img8: TSaveImage;
    HDR: HMC_TEX_Entry;
    Buffer: PByteArray;
    xbox: TXBoxTexture;
begin

  setStatusMessage('PALN->TGA: [1/4] Reading PALN header & data in TEX file...');
  texFile.Seek(offset,soFromBeginning);
  texFile.Read(HDR,SizeOf(HMC_Tex_Entry));
  Get0(texFile);
  texFile.Read(fsize,4);

  if (HDR.Type1 <> 'NLAP') or (HDR.Type2 <> 'NLAP') then
    raise Exception.Create('Not an PALN texture!');

  img8 := TSaveImage.Create;
  GetMem(Buffer,fsize);
  try
    if chkXbox.Checked then
    begin
      setStatusMessage('PALN->TGA: [1/4] Reading PALN header & data in TEX file... Xbox unswizzle...');
      xbox := TXboxTexture.create;
      try
        xbox.intex.CopyFrom(texFile,fsize);
        xbox.unswizzle(HDR.Width,HDR.Height,1,1);
        xbox.outtex.Seek(0,soFromBeginning);
        xbox.outtex.Read(Buffer^,fsize);
      finally
        xbox.destroy;
      end;
    end
    else
      texFile.Read(Buffer^,fsize);
    texFile.Read(fsize,4);

    setStatusMessage('PALN->TGA: [2/4] Computing PALN data to TGA format...');
    img8.SetSizePal(HDR.Width, HDR.Height,fsize,true);

    W := HDR.Width;
    H := HDR.Height;

    for y := 0 to H-1 do
      for x := 0 to W-1 do
        img8.Pixels[x][y] := Buffer[(y*W)+x];

    setStatusMessage('PALN->TGA: [3/4] Reading PALN palette from TEX file ('+inttostr(fsize)+' colors)...');
    texFile.Read(Buffer^,fsize*4);

    for y := 0 to fsize-1 do
    begin
      img8.Palette[y].R := Buffer[(y*4)];
      img8.Palette[y].G := Buffer[(y*4)+1];
      img8.Palette[y].B := Buffer[(y*4)+2];
      img8.Palette[y].A := Buffer[(y*4)+3];
    end;

    setStatusMessage('PALN->TGA: [4/4] Saving TGA 32bpp (with '+inttostr(fsize)+' different colors)...');
    img8.SaveToTGA32(outname);
    setStatusMessage('PALN->TGA: Done! (Export successfull) [Output is TGA 32Bpp with '+inttostr(fsize)+' colors]');
  except
    on E: Exception do
    begin
      SetStatusMessage('Error: '+E.Message);
      MessageDlg('Error: '+E.Message, mtError, [mbOk], 0);
    end;
  end;
  FreeMem(Buffer);
  img8.free;

end;

procedure TfrmTEXeditor.FormDestroy(Sender: TObject);
begin

  ZipMaster.UnLoad_Zip_Dll;
  ZipMaster.Unload_Unz_Dll;

end;

procedure TfrmTEXeditor.butOptionsClick(Sender: TObject);
begin

  grpOptions.Visible := true;

//  popOptions.PopupComponent;

end;

procedure TfrmTEXeditor.butOptionsOkClick(Sender: TObject);
begin

  grpOptions.Visible := false;

end;

procedure TfrmTEXeditor.chkXboxClick(Sender: TObject);
begin

  IniFile.WriteBool('HMCEditor','XboxMode',chkXbox.Checked);

end;

end.
