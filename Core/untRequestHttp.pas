unit untRequestHttp;

interface

uses untInterfaces, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.IdAntiFreeze,
     IdSSLOpenSSL, System.Generics.Collections, System.Threading,
     System.Classes, System.Sysutils, Dialogs, IdComponent,
     untDataModule, untResponseHttp;

type
  TRequestHTTP = class(TInterfacedObject, IRequestHTTP, ISubjectDownload)
    private
      FIdHTTP: TIdHTTP;
      FIdSSHandler: TIdSSLIOHandlerSocketOpenSSL;
      FIdAntiFreeze: TIdAntiFreeze;
      FListObservers: TList<IObserverDownload>;
      FTask: iTask;
      FIdRecordLog: Integer;
      FDownloadNotify: TDownloadResponse;
      FDataM: TDataM;
      procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
        AWorkCount: Int64);
      procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
        AWorkCountMax: Int64);
      procedure HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
      function ProgressPerc(maxValue, currentValue: real): real;
      function ProgressKb(currentValue: real): real;

    public
      constructor Create;
      destructor Destroy; Override;
      class function New: IRequestHTTP;

      procedure Download(url, savePath: String);
      procedure StopDownload;

      function ResponseObserver: ISubjectDownload;
      function DownloadIsRunning: Boolean;

      procedure AddObserver(AObserver: IObserverDownload);
      procedure RemoveObserver(AObserver: IObserverDownload);
      procedure NotifyObserver(DownloadResponse: TDownloadResponse);
  end;

implementation

{ TMIdHTTP }

procedure TRequestHTTP.AddObserver(AObserver: IObserverDownload);
begin
  FListObservers.Add(AObserver);
end;

constructor TRequestHTTP.Create;
begin
  FIdHTTP := TIdHTTP.Create(nil);
  FIdSSHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FIdSSHandler.SSLOptions.Method := sslvSSLv23;
  FIdSSHandler.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_1, sslvTLSv1];
  FIdHTTP.IOHandler := FIdSSHandler;

  FIdHTTP.OnWork := HTTPWork;
  FIdHTTP.OnWorkBegin := HTTPWorkBegin;
  FIdHTTP.OnWorkEnd := HTTPWorkEnd;

  FDataM := TDataM.Create(nil);
  FIdRecordLog := 0;

  FDownloadNotify.KbProgress := 0;
  FDownloadNotify.PercProgress := 0;
  FDownloadNotify.MaxProgress := 0;

  FIdAntiFreeze := TIdAntiFreeze.Create(nil);
  FListObservers := TList<IObserverDownload>.Create;
end;

destructor TRequestHTTP.Destroy;
begin
  FreeAndNil(FListObservers);
  FreeAndNil(FIdSSHandler);
  FreeAndNil(FIdHTTP);
  FreeAndNil(FIdAntiFreeze);
  FreeAndNil(FDataM);
  inherited;
end;

procedure TRequestHTTP.Download(url, savePath: String);
begin
  FIdRecordLog := FDataM.InsertRecord(url);

  FTask := TTask.Create(
    procedure
    begin
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        var
          LFile: TFileStream;
        begin
          LFile := TFileStream.Create(savePath, fmCreate);
          try
            FIdHTTP.CleanupInstance;
            try
              FIdHTTP.Get(url, LFile);
            except
              on E:Exception do
              begin
                ShowMessage(e.Message);
                FDownloadNotify.Status := stDownloadFinalize;
                if Lowercase(e.Message) <> 'operation cancelled' then
                  FDownloadNotify.ErrorMessage := e.Message;
                NotifyObserver(FDownloadNotify);
              end;
            end;
          finally
            FreeAndNil(LFile);
          end;
        end
      );
    end
  );

  try
    FTask.Start;
  except
    on E:Exception do
    begin
      FDownloadNotify.ErrorMessage := 'Erro ao rodar thread: ' + e.Message;
      FDownloadNotify.Status := stDownloadFinalize;
      NotifyObserver(FDownloadNotify);
    end;
  end;
end;

function TRequestHTTP.DownloadIsRunning: Boolean;
begin
  Result := False;

  if Assigned(FTask) then
    result := (FTask.Status = TTaskStatus.Running);
end;

procedure TRequestHTTP.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  FTask.CheckCanceled;
  FDownloadNotify.Status := stDownloadRunning;
  FDownloadNotify.KbProgress := ProgressKb(AWorkCount);
  FDownloadNotify.PercProgress := ProgressPerc(FDownloadNotify.MaxProgress, AWorkCount);
  FDownloadNotify.CountProgress := AWorkCount;
  NotifyObserver(FDownloadNotify);
end;

procedure TRequestHTTP.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  FDownloadNotify.Status := stDownloadRunning;
  FDownloadNotify.MaxProgress := AWorkCountMax;
  NotifyObserver(FDownloadNotify);
end;

procedure TRequestHTTP.HTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  if not (FTask.Status = TTaskStatus.Canceled) then
  begin
    FDataM.SetEndDownload(FIdRecordLog);
    FDownloadNotify.PercProgress := 100;
    FDownloadNotify.MaxProgress := 0;
    FDownloadNotify.Status := stDownloadSuccess;
    NotifyObserver(FDownloadNotify);
  end;
end;

class function TRequestHTTP.New: IRequestHTTP;
begin
  Result := Self.Create;
end;

procedure TRequestHTTP.NotifyObserver(DownloadResponse: TDownloadResponse);
var
  Observer: IObserverDownload;
begin
  for Observer in FListObservers do
  begin
    Observer.RefreshProgress(DownloadResponse);
  end;
end;

function TRequestHTTP.ProgressKb(currentValue: real): real;
begin
  Result := ((currentValue / 1024) / 1024);
end;

function TRequestHTTP.ProgressPerc(maxValue, currentValue: real): real;
begin
  Result := ((currentValue * 100) / maxValue);
end;

procedure TRequestHTTP.RemoveObserver(AObserver: IObserverDownload);
begin
  FListObservers.Delete(FListObservers.IndexOf(AObserver));
end;

function TRequestHTTP.ResponseObserver: ISubjectDownload;
begin
  Result := Self;
end;

procedure TRequestHTTP.StopDownload;
begin
  FTask.Cancel;
end;

end.
