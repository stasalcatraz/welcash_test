program welcash;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fmMain},
  uData in 'uData.pas' {dmData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TdmData, dmData);
  Application.Run;
end.
