object GUI: TGUI
  Left = 0
  Top = 0
  Caption = 'DXP'
  ClientHeight = 1149
  ClientWidth = 732
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 6
  Padding.Top = 6
  Padding.Right = 6
  Padding.Bottom = 6
  OnActivate = FormActivate
  TextHeight = 15
  object Memo: TMemo
    Left = 6
    Top = 6
    Width = 720
    Height = 1078
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 272
    ExplicitTop = 176
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object BottomPanel: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 1092
    Width = 720
    Height = 51
    Margins.Left = 0
    Margins.Top = 8
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    OnResize = BottomPanelResize
    object ClearMemoButton: TButton
      Left = 288
      Top = 4
      Width = 121
      Height = 36
      Caption = 'Clear Messages'
      TabOrder = 0
    end
  end
end
