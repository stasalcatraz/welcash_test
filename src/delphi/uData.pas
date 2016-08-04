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
  FireDAC.Moni.FlatFile;

type
  TdmData = class(TDataModule)
    fdqIssues: TFDQuery;
    fdcConnection: TFDConnection;
    updIssues: TFDUpdateSQL;
    fdqIssueMovements: TFDQuery;
    fdqIssueMovementsid: TIntegerField;
    fdqIssueMovementsissue_id: TIntegerField;
    fdqIssueMovementsactual_time: TFloatField;
    dsIssues: TDataSource;
    dsIssueMovements: TDataSource;
    fdqIssueMovementsmovement_date: TDateTimeField;
    fdqIssueMovementsstatus: TStringField;
    fdqIssuesid: TFDAutoIncField;
    fdqIssuesdescription: TStringField;
    fdqIssuesstatus: TStringField;
    fdqIssuesplanned_time: TFloatField;
    fdqIssuesactual_time: TFloatField;
    fdqNextStatuses: TFDQuery;
    fdqNextStatusesid: TIntegerField;
    fdqNextStatusesname: TStringField;
    fdqSatusButtons: TFDQuery;
    fdqIssuesistatus_id: TIntegerField;
    fdqSetStatus: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure fdqIssuesAfterOpen(DataSet: TDataSet);
    procedure fdqIssuesAfterPost(DataSet: TDataSet);
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
  fdcConnection.Params.Values['Database'] := ExtractFilePath(Application.ExeName) + 'welcash.db';
  fdcConnection.Connected := True;
end;

procedure TdmData.fdqIssuesAfterOpen(DataSet: TDataSet);
begin
  fdqNextStatuses.Open;
  fdqIssueMovements.Open;
end;

procedure TdmData.fdqIssuesAfterPost(DataSet: TDataSet);
begin
  fdqIssues.Refresh;
end;

procedure TdmData.RefreshIssues(ADateFrom, ADateTo: TDateTime);
begin
  with fdqIssues do
  begin
    Close;
    Params.ParamByName('date_from').AsDate := ADateFrom;
    Params.ParamByName('date_to').AsDate := ADateTo;
    Open;
  end;
end;

procedure TdmData.SetStatus(AStatus: Integer);
begin
  fdqSetStatus.ParamByName('issue_id').Value := fdqIssues.FieldByName('id').AsVariant;
  fdqSetStatus.ParamByName('status_id').AsInteger := AStatus;
  fdqSetStatus.ExecSQL;
  fdqIssues.RefreshRecord;
  fdqIssueMovements.Refresh;
  fdqNextStatuses.Refresh;
end;

end.
