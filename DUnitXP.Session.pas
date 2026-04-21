unit DUnitXP.Session;

interface

uses
  Web.HTTPApp,
  DUnitXP.Model.Tests,
  DUnitXP.Runner;

type
  TRunCheck = class
  private
    FNeedsStatus: Boolean;
  public
    function Clone: TRunCheck;
    property NeedsStatus: Boolean read FNeedsStatus write FNeedsStatus;
  end;

  TSession = class
  public
    class function GetCheckedTests(const ASession: TWebSession): TArray<string>;
    class function GetFixtures(const ASession: TWebSession): TFixtures;
    class function GetRunner(const ASession: TWebSession): TRunner;
    class function GetRunCheck(const ASession: TWebSession): TRunCheck;
    class procedure SetCheckedTests(const ASession: TWebSession; const AValue: TArray<string>);
  end;

implementation

uses
  System.SysUtils;

const
  cSessionVarTestsChecked = 'testschecked';

{ TRunCheck }

function TRunCheck.Clone: TRunCheck;
begin
  Result := TRunCheck.Create;
  Result.NeedsStatus := NeedsStatus;
end;

{ TSession }

class function TSession.GetCheckedTests(const ASession: TWebSession): TArray<string>;
begin
  Result := ASession.DataVars.Values[cSessionVarTestsChecked].Split([';']);
end;

class function TSession.GetFixtures(const ASession: TWebSession): TFixtures;
const
  cSessionKey = 'Fixtures';
var
  LIndex: Integer;
begin
  LIndex := ASession.DataVars.IndexOf(cSessionKey);
  if LIndex < 0 then
  begin
    Result := TFixtures.Create;
    ASession.DataVars.AddObject(cSessionKey, Result);
  end
  else
    Result := TFixtures(ASession.DataVars.Objects[LIndex]);
  Result.SetChecked(GetCheckedTests(ASession));
end;

class function TSession.GetRunCheck(const ASession: TWebSession): TRunCheck;
const
  cSessionKey = 'RunCheck';
var
  LIndex: Integer;
begin
  LIndex := ASession.DataVars.IndexOf(cSessionKey);
  if LIndex < 0 then
  begin
    Result := TRunCheck.Create;
    ASession.DataVars.AddObject(cSessionKey, Result);
  end
  else
    Result := TRunCheck(ASession.DataVars.Objects[LIndex]);
end;

class function TSession.GetRunner(const ASession: TWebSession): TRunner;
const
  cSessionKey = 'Runner';
var
  LIndex: Integer;
begin
  LIndex := ASession.DataVars.IndexOf(cSessionKey);
  if LIndex < 0 then
  begin
    Result := TRunner.Create;
    ASession.DataVars.AddObject(cSessionKey, Result);
  end
  else
    Result := TRunner(ASession.DataVars.Objects[LIndex]);
  Result.SetEnabledTests(GetCheckedTests(ASession));
end;

class procedure TSession.SetCheckedTests(const ASession: TWebSession; const AValue: TArray<string>);
begin
  ASession.DataVars.Values[cSessionVarTestsChecked] := string.Join(';', AValue);
end;

end.
