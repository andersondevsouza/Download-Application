program DownloadTest;

uses
  Vcl.Forms,
  untInterfaces in 'Interface\untInterfaces.pas',
  untRequestHttp in 'Core\untRequestHttp.pas',
  untResponseHttp in 'Core\untResponseHttp.pas',
  untDataModule in 'DataBase\untDataModule.pas' {DataM: TDataModule},
  untMain in 'View\untMain.pas' {frmMain};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDataM, DataM);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
