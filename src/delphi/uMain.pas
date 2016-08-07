unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.Menus, System.Actions, Vcl.StdActns, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.DBCGrids, System.ImageList, Vcl.ImgList, Data.DB, Vcl.DBActns, Vcl.Buttons,
  Data.DBXCommon, Data.SqlExpr, Vcl.DBCtrls, Vcl.Mask, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors,
  Data.Bind.Components, Vcl.Grids, Vcl.DBGrids, Generics.Collections;

type
  TfmMain = class(TForm)
    pnFilter: TPanel;
    alMain: TActionList;
    aExit: TFileExit;
    tbMain: TToolBar;
    bnExit: TToolButton;
    ilMain: TImageList;
    lbDateFrom: TLabel;
    lbDateTo: TLabel;
    dtpDateTo: TDateTimePicker;
    aRefresh: TAction;
    bnRefresh: TBitBtn;
    BindingsList1: TBindingsList;
    pnBottom: TPanel;
    dbgIssues: TDBGrid;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    DBNavigator1: TDBNavigator;
    ToolButton1: TToolButton;
    dsNextStatuses: TDataSource;
    dtpDateFrom: TDateTimePicker;
    dbgIssueMovements: TDBGrid;
    dsIssues: TDataSource;
    pnRecord: TPanel;
    dbtId: TDBText;
    lbNo: TLabel;
    lbPlanned: TLabel;
    lbHours: TLabel;
    lbActual: TLabel;
    lbStatus: TLabel;
    dbtStatus: TDBText;
    dbtActualTime: TDBText;
    dbmDescription: TDBMemo;
    dbePlannetTime: TDBEdit;
    pnMove: TPanel;
    Label1: TLabel;
    procedure aRefreshExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dsIssuesStateChange(Sender: TObject);
    procedure dsNextStatusesDataChange(Sender: TObject; Field: TField);
  private
    FButtons: TDictionary<Integer, TButton>;
    FUpdateButtons: Boolean;
    procedure CreateButtons;
    procedure SetupButtons;
    procedure StatusButtonClick(Sender: TObject);
  public
    procedure UpdateActions; override;
  end;

const
  STATUS_BUTTON_WIDTH = 120;
var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses uData;

procedure TfmMain.aRefreshExecute(Sender: TObject);
begin
  dmData.RefreshIssues(dtpDateFrom.DateTime, dtpDateTo.DateTime);
end;

procedure TfmMain.CreateButtons;
  function CreateButton(AParent: TCustomControl; AId: Integer; ACaption: String;
    var ALeft: Integer): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Caption := ACaption;
    Result.Left := ALeft;
    Result.Width := STATUS_BUTTON_WIDTH;
    Result.Height := pnMove.ClientHeight;
    Result.Parent := AParent;
    Result.Tag := AId;
    Result.Visible := False;
    Result.OnClick := StatusButtonClick;
    ALeft := ALeft + STATUS_BUTTON_WIDTH;
  end;
var
  L, I: Integer;
begin
  L := 0;
  with dmData.spStatusButtons do
  begin
    Open;
    FButtons := TDictionary<Integer,TButton>.Create(RecordCount);
    I := 0;
    while not Eof do
    begin
      FButtons.Add(I, CreateButton(pnMove,
        FieldByName('id').AsInteger, FieldByName('name').AsString, L));
      Inc(I);
      Next;
    end;
    Close;
  end;
end;

procedure TfmMain.dsIssuesStateChange(Sender: TObject);
begin
  if dsIssues.DataSet.State = dsInsert then
    dbePlannetTime.SetFocus;
end;

procedure TfmMain.dsNextStatusesDataChange(Sender: TObject; Field: TField);
begin
  FUpdateButtons := True;
end;

procedure TfmMain.FormShow(Sender: TObject);
var
  Y, M, D: Word;
begin
  DecodeDate(Now, Y, M, D);
  dtpDateFrom.DateTime := EncodeDate(Y, M, 1);
  dtpDateTo.DateTime := Now;
  CreateButtons;
  FUpdateButtons := False;
end;

procedure TfmMain.SetupButtons;
var
  I: Integer;
  Active, BV: Boolean;
  W: Integer;
begin
  Active := dsNextStatuses.DataSet.Active;
  W := 0;
  for I := 0 to FButtons.Count - 1 do
  begin
    BV := Active and dsNextStatuses.DataSet.Locate('id', FButtons[I].Tag, []);
    FButtons[I].Visible := BV;
    if BV then
    begin
      FButtons[I].Left := W;
      Inc(W, STATUS_BUTTON_WIDTH);
    end;
  end;
  pnMove.Width := W;
  FUpdateButtons := False;
end;

procedure TfmMain.StatusButtonClick(Sender: TObject);
begin
  dmData.SetStatus(TButton(Sender).Tag);
end;

procedure TfmMain.UpdateActions;
var
  ro: Boolean;
begin
 inherited UpdateActions;
  ro := dmData.spIssues.State <> dsInsert;
  dbmDescription.ReadOnly := ro;
  dbePlannetTime.ReadOnly := ro;
  if FUpdateButtons then
    SetupButtons;
end;

end.
