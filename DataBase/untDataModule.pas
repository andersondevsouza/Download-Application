unit untDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDataM = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FQryAux : TFDQuery;
    function GetId: Integer;
  public
    { Public declarations }
    function InsertRecord(url: String) : Integer;
    procedure SetEndDownload(id: integer);
    function GetLogDownloads: TDataSet;
  end;

var
  DataM: TDataM;

implementation

uses
  Vcl.Forms;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDataM }

procedure TDataM.DataModuleCreate(Sender: TObject);
begin
  FDConnection.Connected := False;
  FDConnection.Params.Database := ExtractFilePath(Application.ExeName) + 'Database\bd.db';
  FDConnection.Connected := True;

  FQryAux := TFDQuery.Create(nil);
  FQryAux.Connection := FDConnection;
end;

procedure TDataM.DataModuleDestroy(Sender: TObject);
begin
  FDConnection.Connected := False;
  FreeAndNil(FQryAux);
end;

function TDataM.GetId: Integer;
begin
  FQryAux.Close;
  FQryAux.Open('SELECT COALESCE(MAX(CODIGO),0) + 1 as ID FROM LOGDOWNLOAD');

  Result := FQryAux.FieldByName('ID').AsInteger;
end;

function TDataM.GetLogDownloads: TDataSet;
begin
  FQryAux.Close;
  FQryAux.SQL.Clear;
  FQryAux.Open('SELECT CODIGO, URL, DATAINICIO, DATAFIM '+
                      '  FROM LOGDOWNLOAD ');
  Result := FQryAux;
end;

function TDataM.InsertRecord(url: String): Integer;
var
  Id: Integer;
begin
  Id := GetId;

  FQryAux.Close;
  FQryAux.SQL.Clear;
  FQryAux.SQL.Add('INSERT INTO LOGDOWNLOAD(CODIGO,');
  FQryAux.SQL.Add('                        URL,');
  FQryAux.SQL.Add('                        DATAINICIO)');
  FQryAux.SQL.Add('                 VALUES(:CODIGO,');
  FQryAux.SQL.Add('                        :URL,');
  FQryAux.SQL.Add('                        :DATAINICIO)');
  FQryAux.ParamByName('codigo').AsInteger := Id;
  FQryAux.ParamByName('url').AsString := url;
  FQryAux.ParamByName('datainicio').AsDateTime := Now;
  FQryAux.ExecSQL;

  Result := Id;
end;

procedure TDataM.SetEndDownload(id: integer);
begin
  FQryAux.Close;
  FQryAux.SQL.Clear;
  FQryAux.SQL.Add('UPDATE LOGDOWNLOAD SET DATAFIM = :DATAFIM WHERE CODIGO = :ID');
  FQryAux.ParamByName('datafim').AsDateTime := now;
  FQryAux.ParamByName('id').AsInteger := id;
  FQryAux.ExecSQL;
end;

end.
