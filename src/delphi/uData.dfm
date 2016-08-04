object dmData: TdmData
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 300
  Width = 376
  object fdqIssues: TFDQuery
    AfterOpen = fdqIssuesAfterOpen
    AfterPost = fdqIssuesAfterPost
    Connection = fdcConnection
    UpdateOptions.AssignedValues = [uvEDelete, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableUpdate = False
    UpdateObject = updIssues
    SQL.Strings = (
      'select'
      '  id,'
      '  description,'
      '  status_id,'
      '  status,'
      '  planned_time,'
      '  actual_time'
      'from'
      '  vw_issues i'
      'where'
      '  exists('
      '    select 1 from tbl_issue_movements im'
      '    where'
      '      issue_id = i.id'
      '      and im.movement_date >= :date_from'
      '      and im.movement_date < date( :date_to, '#39'1 days'#39')'
      '  ) or (select status_id from tbl_issue_movements'
      '    where issue_id = i.id and movement_date ='
      
        '      (select max(movement_date) from tbl_issue_movements where ' +
        'issue_id = i.id'
      '         and movement_date < :date_from) limit 1'
      '     ) < 5')
    Left = 48
    Top = 96
    ParamData = <
      item
        Name = 'DATE_FROM'
        DataType = ftDate
        ParamType = ptInput
        Value = 42491d
      end
      item
        Name = 'DATE_TO'
        DataType = ftDate
        ParamType = ptInput
        Value = 42512d
      end>
    object fdqIssuesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
      Visible = False
    end
    object fdqIssuesdescription: TStringField
      DisplayLabel = #1054#1087#1080#1089
      FieldName = 'description'
      Origin = 'description'
      Required = True
      Size = 32767
    end
    object fdqIssuesistatus_id: TIntegerField
      FieldName = 'status_id'
      Origin = '"i.status_id"'
      Visible = False
    end
    object fdqIssuesstatus: TStringField
      DisplayLabel = #1057#1090#1072#1090#1091#1089
      FieldName = 'status'
      Origin = 'status'
      ProviderFlags = [pfInWhere]
      Size = 32767
    end
    object fdqIssuesplanned_time: TFloatField
      DisplayLabel = #1047#1072#1087#1083#1072#1085#1086#1074#1072#1085#1086', '#1075#1086#1076'.'
      FieldName = 'planned_time'
      Origin = 'planned_time'
      Required = True
      DisplayFormat = '0.##'
    end
    object fdqIssuesactual_time: TFloatField
      DisplayLabel = #1060#1072#1082#1090#1080#1095#1085#1086', '#1075#1086#1076'.'
      FieldName = 'actual_time'
      Origin = 'actual_time'
      ProviderFlags = [pfInWhere]
      DisplayFormat = '0.##'
    end
  end
  object fdcConnection: TFDConnection
    Params.Strings = (
      'Database=./welcash.db'
      'DriverID=SQLite'
      'StringFormat=ANSI'
      'MonitorBy=FlatFile'
      'LockingMode=Normal')
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <
      item
        SourceDataType = dtMemo
        TargetDataType = dtAnsiString
      end
      item
        SourceDataType = dtWideMemo
        TargetDataType = dtWideString
      end
      item
        NameMask = 'movement_date'
        SourceDataType = dtAnsiString
        TargetDataType = dtDateTime
      end>
    LoginPrompt = False
    Left = 52
    Top = 32
  end
  object updIssues: TFDUpdateSQL
    Connection = fdcConnection
    InsertSQL.Strings = (
      'insert into tbl_issues(description, planned_time) '
      'values (:description, :planned_time)')
    FetchRowSQL.Strings = (
      'select'
      '  id,'
      '  description,'
      '  status_id,'
      '  status,'
      '  planned_time,'
      '  actual_time'
      'from'
      '  vw_issues'
      'where'
      '  id = :id')
    Left = 48
    Top = 208
  end
  object fdqIssueMovements: TFDQuery
    MasterSource = dsIssues
    MasterFields = 'id'
    DetailFields = 'issue_id'
    Connection = fdcConnection
    SQL.Strings = (
      'select'
      '  id,'
      '  issue_id,'
      '  datetime(movement_date) as movement_date,'
      '  status,'
      '  actual_time'
      'from'
      '  vw_issue_movements'
      'where'
      '  issue_id = :id')
    Left = 128
    Top = 96
    ParamData = <
      item
        Name = 'ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object fdqIssueMovementsid: TIntegerField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Visible = False
    end
    object fdqIssueMovementsissue_id: TIntegerField
      FieldName = 'issue_id'
      Origin = 'issue_id'
      Required = True
      Visible = False
    end
    object fdqIssueMovementsmovement_date: TDateTimeField
      DisplayLabel = #1044#1072#1090#1072
      FieldName = 'movement_date'
      Origin = 'movement_date'
    end
    object fdqIssueMovementsstatus: TStringField
      DisplayLabel = #1057#1090#1072#1090#1091#1089
      FieldName = 'status'
      Origin = 'status'
      Required = True
      Size = 32767
    end
    object fdqIssueMovementsactual_time: TFloatField
      DisplayLabel = #1063#1072#1089', '#1075#1086#1076'.'
      FieldName = 'actual_time'
      Origin = 'actual_time'
      DisplayFormat = '0.##'
    end
  end
  object dsIssues: TDataSource
    DataSet = fdqIssues
    Left = 48
    Top = 155
  end
  object dsIssueMovements: TDataSource
    DataSet = fdqIssueMovements
    Left = 128
    Top = 156
  end
  object fdqNextStatuses: TFDQuery
    MasterSource = dsIssues
    MasterFields = 'status_id'
    DetailFields = 'status_id'
    Connection = fdcConnection
    SQL.Strings = (
      'select'
      '  sm.status_from as status_id,'
      '  s.id,'
      '  s.name'
      'from'
      '  tbl_statuses s'
      '  inner join tbl_status_movements sm on sm.status_to = s.id'
      'where'
      '  sm.status_from = :status_id'
      'order by '
      '  s.id')
    Left = 224
    Top = 96
    ParamData = <
      item
        Name = 'STATUS_ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object fdqNextStatusesid: TIntegerField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object fdqNextStatusesname: TStringField
      FieldName = 'name'
      Origin = 'name'
      Required = True
      Size = 64
    end
  end
  object fdqSatusButtons: TFDQuery
    Connection = fdcConnection
    SQL.Strings = (
      'select distinct'
      '  s.id,'
      '  s.name'
      'from'
      '  tbl_statuses s'
      '  inner join tbl_status_movements sm on s.id = sm.status_to'
      'order by'
      '  s.id')
    Left = 312
    Top = 96
  end
  object fdqSetStatus: TFDQuery
    Connection = fdcConnection
    SQL.Strings = (
      'insert into tbl_issue_movements ('
      '  issue_id,'
      '  status_id'
      ') values ('
      '  :issue_id,'
      '  :status_id'
      ')')
    Left = 224
    Top = 192
    ParamData = <
      item
        Name = 'ISSUE_ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end
      item
        Name = 'STATUS_ID'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
  end
end
