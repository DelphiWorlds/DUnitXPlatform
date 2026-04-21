unit DUnitXP.GUI.VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  DUnitX.TestFramework,
  DUnitXP.Logger;

type
  TGUI = class(TForm, IDXPLogListener)
    Memo: TMemo;
    BottomPanel: TPanel;
    ClearMemoButton: TButton;
    procedure FormActivate(Sender: TObject);
    procedure BottomPanelResize(Sender: TObject);
  private
    FShown: Boolean;
    procedure DoLog(const ALevel: TLogLevel; const AMessage: string);
    procedure LogServerInfo;
  public
    { IDXPLogListener }
    procedure Log(const ALevel: TLogLevel; const AMessage: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  GUI: TGUI;

implementation

{$R *.dfm}

uses
  Charon,
  DUnitXP;

constructor TGUI.Create(AOwner: TComponent);
begin
  inherited;
  Logger.AddListener(Self);
end;

procedure TGUI.FormActivate(Sender: TObject);
begin
  if not FShown then
    LogServerInfo;
  FShown := True;
end;

procedure TGUI.DoLog(const ALevel: TLogLevel; const AMessage: string);
begin
  Memo.Lines.Add(Format('%s [%s]: %s', [FormatDateTime('hh:nn:ss.zzz', Now), ALevel.AsString, AMessage]));
end;

procedure TGUI.Log(const ALevel: TLogLevel; const AMessage: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      DoLog(ALevel, AMessage);
    end
  );
end;

procedure TGUI.LogServerInfo;
var
  LAddresses: TArray<string>;
  LAddress: string;
begin
  if WebApplication.Server.IsActive then
  begin
    DoLog(TLogLevel.Information, Format('Server active on port: %d', [WebApplication.Server.Port]));
    LAddresses := WebApplication.Server.GetBoundAddresses;
    if Length(LAddresses) > 0 then
    begin
      DoLog(TLogLevel.Information, 'Listening on:');
      for LAddress in LAddresses do
        DoLog(TLogLevel.Information, LAddress);
    end;
  end
  else
    DoLog(TLogLevel.Error, Format('Server could not be started on port: %d', [WebApplication.Server.Port]));
end;

procedure TGUI.BottomPanelResize(Sender: TObject);
begin
  ClearMemoButton.Top := (BottomPanel.Height div 2) - (ClearMemoButton.Height div 2);
  ClearMemoButton.Left := (BottomPanel.Width div 2) - (ClearMemoButton.Width div 2);
end;

end.
