unit untInterfaces;

interface

uses
  untResponseHttp, Data.DB;

type
  IObserverDownload = interface
    ['{AFBBE04C-0A09-4868-AF9D-C6EFC7F5500B}']
    procedure RefreshProgress(DownloadProgressResponse:
     TDownloadResponse);
  end;

  ISubjectDownload = interface
    ['{5D11061D-62F0-491A-9D12-4AB4374C31DD}']
    procedure AddObserver(AObserver: IObserverDownload);
    procedure RemoveObserver(AObserver: IObserverDownload);
    procedure NotifyObserver(DownloadProgressResponse:
     TDownloadResponse);
  end;

  IRequestHTTP = interface
    ['{B7932500-4257-4FC8-8061-35122969D5E0}']
    procedure Download(url, savePath: String);
    procedure StopDownload;
    procedure AddObserver(ObserverDownload: IObserverDownload);
    function DownloadIsRunning: Boolean;
  end;

  ILogDownload = interface
    ['{318D76CD-18F2-4450-A575-FEA798428A27}']
    function ResponseLog: TDataSet;
  end;


implementation

end.
