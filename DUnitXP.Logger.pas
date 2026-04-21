unit DUnitXP.Logger;

interface

uses
  DUnitX.TestFramework;

type
  IDXPLogListener = interface
    ['{F7493F1E-81F6-4F2E-8FA1-E576422569E4}']
    procedure Log(const ALevel: TLogLevel; const AMessage: string);
  end;

  IDXPLogger = interface
    ['{B56E418E-C132-43E3-8FBF-AC5A03936E0E}']
    procedure AddListener(const AListener: IDXPLogListener);
    procedure Log(const ALevel: TLogLevel; const AFormat: string); overload;
    procedure Log(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
  end;

  TLogLevel = DUnitX.TestFramework.TLogLevel;

  TLogLevelHelper = record helper for TLogLevel
    function AsString: string;
  end;

var
  Logger: IDXPLogger;

implementation

uses
  System.SysUtils;

type
  TDXPLogger = class(TInterfacedObject, IDXPLogger)
  private
    FListeners: TArray<IDXPLogListener>;
  public
    { IDXPLogger }
    procedure AddListener(const AListener: IDXPLogListener);
    procedure Log(const ALevel: TLogLevel; const AFormat: string); overload;
    procedure Log(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
  end;

{ TLogLevelHelper }

function TLogLevelHelper.AsString: string;
begin
  Result := TLogLevelDesc[Self];
end;

{ TDXPLogger }

procedure TDXPLogger.AddListener(const AListener: IDXPLogListener);
begin
  FListeners := FListeners + [AListener];
end;

procedure TDXPLogger.Log(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const);
var
  LListener: IDXPLogListener;
  LMessage: string;
begin
  LMessage := Format(AFormat, AArgs);
  for LListener in FListeners do
    LListener.Log(ALevel, LMessage);
end;

procedure TDXPLogger.Log(const ALevel: TLogLevel; const AFormat: string);
begin
  Log(ALevel, AFormat, []);
end;

initialization
  Logger := TDXPLogger.Create;

end.
