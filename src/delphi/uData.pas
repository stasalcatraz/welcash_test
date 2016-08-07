unit uData;

interface

uses
  System.SysUtils, System.Classes, Data.DbxSqlite, Data.DB, Data.SqlExpr,
  Data.FMTBcd, Datasnap.Provider, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Moni.Base,
  FireDAC.Moni.FlatFile, FireDAC.Phys.Oracle, FireDAC.Phys.OracleDef;

type
  TdmData = class(TDataModule)
    spIssues: TFDStoredProc;
    spIssuesID: TFMTBCDField;
    spIssuesDESCRIPTION: TWideStringField;
    spIssuesSTATUS_ID: TFMTBCDField;
    spIssuesSTATUS: TWideStringField;
    spIssuesPLANNED_TIME: TFloatField;
    spIssuesACTUAL_TIME: TFMTBCDField;
    updIssues: TFDUpdateSQL;
    spIssueMovements: TFDStoredProc;
    spIssueMovementsid: TFMTBCDField;
    spIssueMovementsissue_id: TFMTBCDField;
    spIssueMovementsactual_time: TFMTBCDField;
    dsIssues: TDataSource;
    dsIssueMovements: TDataSource;
    spIssueMovementsmovement_date: TDateTimeField;
    spIssueMovementsstatus: TWideStringField;
    spNextStatuses: TFDStoredProc;
    spStatusButtons: TFDStoredProc;
    spSetStatus: TFDStoredProc;
    fdcConnection: TFDConnection;
    spNextStatusesSTATUS_ID: TFMTBCDField;
    spNextStatusesID: TFMTBCDField;
    spNextStatusesNAME: TWideStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure spIssuesAfterOpen(DataSet: TDataSet);
    procedure spIssuesAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    procedure RefreshIssues(ADateFrom, ADateTo: TDateTime);
    procedure SetStatus(AStatus: Integer);
  end;

var
  dmData: TdmData;

implementation

uses
  Data.SqlTimSt, Vcl.Forms;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmData.DataModuleCreate(Sender: TObject);
begin
  updIssues.Commands[arFetchRow].SchemaName := 'bugtracker';
  updIssues.Commands[arFetchRow].CommandKind := skStoredProcWithCrs;
  updIssues.Commands[arFetchRow].Params.CreateParam(ftCursor, 'Result', ptResult);
  updIssues.Commands[arFetchRow].Params.CreateParam(ftFMTBcd, 'ID', ptInput);
  fdcConnection.Params.LoadFromFile(ExtractFilePath(Application.ExeName) + 'connection.ini');
  fdcConnection.Connected := True;
end;

procedure TdmData.spIssuesAfterOpen(DataSet: TDataSet);
begin
  spNextStatuses.Open;
  spIssueMovements.Open;
end;

procedure TdmData.spIssuesAfterPost(DataSet: TDataSet);
begin
  spIssues.Refresh;
end;

procedure TdmData.RefreshIssues(ADateFrom, ADateTo: TDateTime);
begin
  with spIssues do
  begin
    Close;
    Params.ParamByName('date_from').AsDateTime := ADateFrom;
    Params.ParamByName('date_to').AsDateTime := ADateTo;
    Open;
  end;
end;

procedure TdmData.SetStatus(AStatus: Integer);
begin
  spSetStatus.ParamByName('issue_id').Value := spIssues.FieldByName('id').AsVariant;
  spSetStatus.ParamByName('status_id').Value := AStatus;
  spSetStatus.ExecProc;
  spIssues.RefreshRecord;
  spIssueMovements.Refresh;
  spNextStatuses.Refresh;
end;

end.
