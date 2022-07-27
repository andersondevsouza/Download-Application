unit untResponseHttp;

interface

type
  TStatus = (stDownloadRunning, stDownloadFinalize, stDownloadSuccess);

  TDownloadResponse = record
    MaxProgress: Int64;
    PercProgress: Real;
    CountProgress: Int64;
    KbProgress: Real;
    Status: TStatus;
    ErrorMessage: String;
  end;

implementation

end.
