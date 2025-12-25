program TEXEditor;

// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The Original Code is HMCEditor.dpr, released May 29, 2004.
//
// The Initial Developer of the Original Code is Alexandre Devilliers
// (elbereth@users.sourceforge.net, http://www.elberethzone.net).

uses
  Forms,
  Main in 'Main.pas' {frmTEXeditor},
  class_Images in 'class_Images.pas',
  spec_HMC in 'spec_HMC.pas',
  spec_DDS in 'spec_DDS.pas',
  resample in 'resample.pas',
  class_Xbox in 'class_Xbox.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Glacier TEX Editor v3.9 Beta 3';
  Application.CreateForm(TfrmTEXeditor, frmTEXeditor);
  Application.Run;
end.
