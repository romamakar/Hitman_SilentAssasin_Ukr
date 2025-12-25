unit class_Xbox;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is unswizzle.cpp, released May 07, 2004.
//
// The Initial Developer of the Original Code is aman.
// (http://aman.webhop.org/xbox).
//
// Original code was translated to Delphi by Alexandre Devilliers.
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

interface

uses classes;

type TXboxTexture = class(TObject)
  constructor create;
  destructor destroy; override;
  private
    cH: cardinal;
    cW: cardinal;
    cPx: cardinal;
    function blocproc(tx, ty, blockwidth, blockheight: cardinal): cardinal;
    function blocprocSw(tx, ty, blockwidth, blockheight: cardinal): cardinal;
    procedure pixelproc(sidelen, x, y: cardinal);
    procedure pixelprocSw(sidelen, x, y: cardinal);
  public
    intex: TMemoryStream;
    outtex: TMemoryStream;
    function unswizzle(width, height, pxSize, nMipmap: cardinal): cardinal;
    function reswizzle(width, height, pxSize, nMipmap: cardinal): cardinal;
  end;

implementation


{ TXboxTexture }

function TXboxTexture.blocproc(tx, ty, blockwidth, blockheight: cardinal): cardinal;
var sidelen: cardinal;
begin

  sidelen := 1 shl 16;

  while ((sidelen > blockwidth) or (sidelen > blockheight)) do
    sidelen := sidelen shr 1;

   result := 0;

	if (sidelen>0) then
  begin
		pixelproc(sidelen, tx, ty);
		result := sidelen * sidelen * cPx;
		if (sidelen<blockwidth ) then
      inc(result,blocproc(tx+sidelen, ty, blockwidth - sidelen, sidelen));
		if (sidelen<blockheight) then
      inc(result,blocproc(tx, ty+sidelen, blockwidth, blockheight - sidelen));
	end;

end;

function TXboxTexture.blocprocSw(tx, ty, blockwidth,
  blockheight: cardinal): cardinal;
var sidelen: cardinal;
begin

  sidelen := 1 shl 16;

  while ((sidelen > blockwidth) or (sidelen > blockheight)) do
    sidelen := sidelen shr 1;

   result := 0;

	if (sidelen>0) then
  begin
		pixelprocSw(sidelen, tx, ty);
		result := sidelen * sidelen * cPx;
		if (sidelen<blockwidth ) then
      inc(result,blocprocSw(tx+sidelen, ty, blockwidth - sidelen, sidelen));
		if (sidelen<blockheight) then
      inc(result,blocprocSw(tx, ty+sidelen, blockwidth, blockheight - sidelen));
	end;

end;

constructor TXboxTexture.create;
begin
  inherited Create;
  intex := TMemoryStream.Create;
  outtex := TMemoryStream.Create;
end;

destructor TXboxTexture.Destroy;
begin
  intex.Free;
  outtex.Free;
  inherited Destroy;
end;

procedure TXboxTexture.pixelproc(sidelen, x, y: cardinal);
begin

	if (sidelen>2) then
  begin
    sidelen := sidelen div 2;
		pixelproc(sidelen, X+0,       Y+0);
		pixelproc(sidelen, X+sidelen, Y+0);
		pixelproc(sidelen, X+0,       Y+sidelen);
		pixelproc(sidelen, X+sidelen, Y+sidelen);
  end
	else if (sidelen=2) then
  begin
    outtex.Seek((Y * cW + X) * cPx,soFromBeginning);
    outtex.CopyFrom(intex,2*cPx);
    inc(Y);
    outtex.Seek((Y * cW + X) * cPx,soFromBeginning);
    outtex.CopyFrom(intex,2*cPx);
  end
	else
  begin
    outtex.Seek((Y * cW + X) * cPx,soFromBeginning);
    outtex.CopyFrom(intex,cPx);
	end;

end;

procedure TXboxTexture.pixelprocSw(sidelen, x, y: cardinal);
begin

	if (sidelen>2) then
  begin
    sidelen := sidelen div 2;
		pixelprocSw(sidelen, X+0,       Y+0);
		pixelprocSw(sidelen, X+sidelen, Y+0);
		pixelprocSw(sidelen, X+0,       Y+sidelen);
		pixelprocSw(sidelen, X+sidelen, Y+sidelen);
  end
	else if (sidelen=2) then
  begin
    intex.Seek((Y * cW + X) * cPx,soFromBeginning);
    outtex.CopyFrom(intex,2*cPx);
    inc(Y);
    intex.Seek((Y * cW + X) * cPx,soFromBeginning);
    outtex.CopyFrom(intex,2*cPx);
  end
	else
  begin
    intex.Seek((Y * cW + X) * cPx,soFromBeginning);
    outtex.CopyFrom(intex,cPx);
	end;

end;

function TXboxTexture.reswizzle(width, height, pxSize,
  nMipmap: cardinal): cardinal;
var i: cardinal;
begin

  result := 0;
  cW := width;
  cH := height;
  cPx := pxSize;

  intex.Seek(0,soFromBeginning);
  outtex.Seek(0,soFromBeginning);
  outtex.CopyFrom(intex,intex.Size);
  intex.Seek(0,soFromBeginning);
  outtex.Seek(0,soFromBeginning);

  for i := 0 to nMipmap-1 do
  begin
		inc(result,blocprocSw(0,0, cW, cH));
    cW := cW div 2;
    if cW < 2 then
      cW := 2;
    cH := cH div 2;
    if cH < 2 then
      cH := 2;
  end;

end;

function TXboxTexture.unswizzle(width, height, pxSize,
  nMipmap: cardinal): cardinal;
var i: cardinal;
begin

  result := 0;
  cW := width;
  cH := height;
  cPx := pxSize;

  intex.Seek(0,soFromBeginning);
  outtex.Seek(0,soFromBeginning);
  outtex.CopyFrom(intex,intex.Size);
  intex.Seek(0,soFromBeginning);
  outtex.Seek(0,soFromBeginning);

  for i := 0 to nMipmap-1 do
  begin
		inc(result,blocproc(0,0, cW, cH));
    cW := cW div 2;
    if cW < 2 then
      cW := 2;
    cH := cH div 2;
    if cH < 2 then
      cH := 2;
  end;

end;

end.
