object dmData: TdmData
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 397
  Width = 414
  object spIssues: TFDStoredProc
    AfterOpen = spIssuesAfterOpen
    AfterPost = spIssuesAfterPost
    Connection = fdcConnection
    FetchOptions.AssignedValues = [evItems, evCache, evCursorKind]
    UpdateObject = updIssues
    SchemaName = 'bugtracker'
    StoredProcName = 'sp_issues'
    Left = 48
    Top = 168
    ParamData = <
      item
        Position = 1
        Name = 'DATE_FROM'
        DataType = ftDateTime
        FDDataType = dtDateTime
        NumericScale = 1000
        ParamType = ptInput
      end
      item
        Position = 2
        Name = 'DATE_TO'
        DataType = ftDateTime
        FDDataType = dtDateTime
        NumericScale = 1000
        ParamType = ptInput
      end
      item
        Position = 3
        Name = 'RES'
        DataType = ftCursor
        FDDataType = dtCursorRef
        ParamType = ptOutput
      end>
    object spIssuesID: TFMTBCDField
      DisplayLabel = '#'
      FieldName = 'ID'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object spIssuesDESCRIPTION: TWideStringField
      DisplayLabel = #1054#1087#1080#1089
      FieldName = 'DESCRIPTION'
      Required = True
      Size = 1000
    end
    object spIssuesSTATUS_ID: TFMTBCDField
      FieldName = 'STATUS_ID'
      Visible = False
    end
    object spIssuesSTATUS: TWideStringField
      DisplayLabel = #1057#1090#1072#1090#1091#1089
      FieldName = 'STATUS'
      Size = 64
    end
    object spIssuesPLANNED_TIME: TFloatField
      DisplayLabel = #1047#1072#1087#1083#1072#1085#1086#1074#1072#1085#1086', '#1075#1086#1076'.'
      FieldName = 'PLANNED_TIME'
      Required = True
      DisplayFormat = '0.##'
    end
    object spIssuesACTUAL_TIME: TFMTBCDField
      DisplayLabel = #1060#1072#1082#1090#1080#1095#1085#1086', '#1075#1086#1076'.'
      FieldName = 'ACTUAL_TIME'
      DisplayFormat = '0.##'
    end
  end
  object fdcConnection: TFDConnection
    Params.Strings = (
      'CharacterSet=UTF8'
      'DriverID=Ora'
      'MonitorBy=FlatFile')
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
    InsertSQL.Strings = (
      'call sp_issues_ins(:description, :planned_time)')
    FetchRowSQL.Strings = (
      'sf_issues_fetch_row')
    Left = 48
    Top = 280
  end
  object spIssueMovements: TFDStoredProc
    MasterSource = dsIssues
    MasterFields = 'id'
    DetailFields = 'issue_id'
    Connection = fdcConnection
    SchemaName = 'bugtracker'
    StoredProcName = 'SP_ISSUE_MOVEMENTS'
    Left = 128
    Top = 168
    ParamData = <
      item
        Position = 1
        Name = 'ID'
        DataType = ftFMTBcd
        FDDataType = dtFmtBCD
        Precision = 38
        NumericScale = 38
        ParamType = ptInput
      end
      item
        Position = 2
        Name = 'RES'
        DataType = ftCursor
        FDDataType = dtCursorRef
        ParamType = ptOutput
      end>
    object spIssueMovementsid: TFMTBCDField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Visible = False
    end
    object spIssueMovementsissue_id: TFMTBCDField
      FieldName = 'issue_id'
      Origin = 'issue_id'
      Required = True
      Visible = False
    end
    object spIssueMovementsmovement_date: TDateTimeField
      DisplayLabel = #1044#1072#1090#1072
      FieldName = 'movement_date'
      Origin = 'movement_date'
    end
    object spIssueMovementsstatus: TWideStringField
      DisplayLabel = #1057#1090#1072#1090#1091#1089
      FieldName = 'status'
      Origin = 'status'
      Required = True
      Size = 32767
    end
    object spIssueMovementsactual_time: TFMTBCDField
      DisplayLabel = #1063#1072#1089', '#1075#1086#1076'.'
      FieldName = 'actual_time'
      Origin = 'actual_time'
      DisplayFormat = '0.##'
    end
  end
  object dsIssues: TDataSource
    DataSet = spIssues
    Left = 48
    Top = 227
  end
  object dsIssueMovements: TDataSource
    DataSet = spIssueMovements
    Left = 128
    Top = 228
  end
  object spNextStatuses: TFDStoredProc
    MasterSource = dsIssues
    MasterFields = 'status_id'
    DetailFields = 'status_id'
    Connection = fdcConnection
    SchemaName = 'bugtracker'
    StoredProcName = 'sp_next_statuses'
    Left = 216
    Top = 168
    ParamData = <
      item
        Position = 1
        Name = 'STATUS_ID'
        DataType = ftFMTBcd
        FDDataType = dtFmtBCD
        Precision = 38
        NumericScale = 38
        ParamType = ptInput
      end
      item
        Position = 2
        Name = 'RES'
        DataType = ftCursor
        FDDataType = dtCursorRef
        ParamType = ptOutput
      end>
    object spNextStatusesID: TFMTBCDField
      FieldName = 'ID'
      Origin = 'ID'
      Required = True
      Precision = 19
      Size = 0
    end
    object spNextStatusesSTATUS_ID: TFMTBCDField
      FieldName = 'STATUS_ID'
      Origin = 'STATUS_ID'
      Required = True
      Precision = 19
      Size = 0
    end
    object spNextStatusesNAME: TWideStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      Required = True
      Size = 64
    end
  end
  object spStatusButtons: TFDStoredProc
    Connection = fdcConnection
    SchemaName = 'bugtracker'
    StoredProcName = 'sp_status_buttons'
    Left = 312
    Top = 168
    ParamData = <
      item
        Position = 1
        Name = 'RES'
        DataType = ftCursor
        FDDataType = dtCursorRef
        ParamType = ptOutput
      end>
  end
  object spSetStatus: TFDStoredProc
    Connection = fdcConnection
    SchemaName = 'bugtracker'
    StoredProcName = 'sp_issue_movements_ins'
    Left = 312
    Top = 232
    ParamData = <
      item
        Position = 1
        Name = 'ISSUE_ID'
        DataType = ftFMTBcd
        FDDataType = dtFmtBCD
        Precision = 38
        NumericScale = 38
        ParamType = ptInput
      end
      item
        Position = 2
        Name = 'STATUS_ID'
        DataType = ftFMTBcd
        FDDataType = dtFmtBCD
        Precision = 38
        NumericScale = 38
        ParamType = ptInput
      end>
  end
end
