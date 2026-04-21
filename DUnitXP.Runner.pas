unit DUnitXP.Runner;

interface

uses
  System.Generics.Collections,
  DUnitX.TestFramework, DUnitX.Extensibility;

type
  TRunnerMessage = class
  private
    FMessage: string;
  public
    constructor Create(const ALogMessage: TLogMessage); overload;
    constructor Create(const AErrorMessage: string); overload;
    property Message: string read FMessage;
  end;

  TRunner = class(TNoRefCountObject, ITestLogger)
  private
    FCurrentTest: string;
    FEnabledTests: TArray<string>;
    FFailCount: Integer;
    FFixtures: ITestFixtureList;
    FIsRunning: Boolean;
    FMessages: TList<TRunnerMessage>;
    FTestsCompletedCount: Integer;
    FTestCount: Integer;
    procedure EnableTests(const AFixture: ITestFixture);
    function GetIsComplete: Boolean;
    function GetIsSuccess: Boolean;
    function GetWasFailure: Boolean;
    function GetWasSuccess: Boolean;
  public
    { ITestLogger }
    procedure OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal);
    procedure OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
    procedure OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
    procedure OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
    procedure OnBeginTest(const threadId: TThreadID; const Test: ITestInfo);
    procedure OnSetupTest(const threadId: TThreadID; const Test: ITestInfo);
    procedure OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo);
    procedure OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo);
    procedure OnTestSuccess(const threadId: TThreadID; const Test: ITestResult);
    procedure OnTestError(const threadId: TThreadID; const Error: ITestError);
    procedure OnTestFailure(const threadId: TThreadID; const Failure: ITestError);
    procedure OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult);
    procedure OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult);
    procedure OnLog(const logType: TLogLevel; const msg: string);
    procedure OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
    procedure OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
    procedure OnEndTest(const threadId: TThreadID; const Test: ITestResult);
    procedure OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
    procedure OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
    procedure OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult);
    procedure OnTestingEnds(const RunResults: IRunResults);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
    procedure SetEnabledTests(const AValue: TArray<string>);
    property CurrentTest: string read FCurrentTest;
    property FailCount: Integer read FFailCount;
    property IsComplete: Boolean read GetIsComplete;
    property IsRunning: Boolean read FIsRunning;
    property IsSuccess: Boolean read GetIsSuccess;
    property Messages: TList<TRunnerMessage> read FMessages;
    property TestCount: Integer read FTestCount;
    property WasFailure: Boolean read GetWasFailure;
    property WasSuccess: Boolean read GetWasSuccess;
  end;

implementation

uses
  System.SysUtils, System.StrUtils,
  DUnitXP.Logger;

type
  TLogLevel = DUnitX.TestFramework.TLogLevel;

{ TRunnerMessage }

constructor TRunnerMessage.Create(const ALogMessage: TLogMessage);
begin
  inherited Create;
  FMessage := Format('[%s] %s', [TLogLevelDesc[ALogMessage.Level], ALogMessage.Msg]);
end;

constructor TRunnerMessage.Create(const AErrorMessage: string);
begin
  inherited Create;
  FMessage := Format('[%s] %s', [TLogLevelDesc[TLogLevel.Error], AErrorMessage]);
end;

{ TRunner }

constructor TRunner.Create;
begin
  inherited Create;
  FMessages := TList<TRunnerMessage>.Create;
end;

destructor TRunner.Destroy;
begin
  FMessages.Free;
  inherited;
end;

procedure TRunner.EnableTests(const AFixture: ITestFixture);
var
  LTest: ITest;
  LChild: ITestFixture;
begin
  // AFixture.Enabled := MatchStr(AFixture.FullName, FEnabledTests);
  for LTest in AFixture.Tests do
  begin
    LTest.Enabled := MatchStr(LTest.FullName, FEnabledTests);
    if LTest.Enabled then
      Inc(FTestCount);
  end;
  for LChild in AFixture.Children do
    EnableTests(LChild);
end;

function TRunner.GetIsComplete: Boolean;
begin
  Result := FTestsCompletedCount = FTestCount;
end;

function TRunner.GetIsSuccess: Boolean;
begin
  Result := FFailCount = 0;
end;

function TRunner.GetWasFailure: Boolean;
begin
  Result := IsComplete and not IsSuccess;
end;

function TRunner.GetWasSuccess: Boolean;
begin
  Result := IsComplete and IsSuccess;
end;

procedure TRunner.Run;
var
  LTestRunner: ITestRunner;
  LResults: IRunResults;
  LTestFixture: ITestFixture;
begin
  FMessages.Clear;
  LTestRunner := TDUnitX.CreateRunner;
  LTestRunner.AddLogger(Self);
  FTestCount := 0;
  FTestsCompletedCount := 0;
  FFailCount := 0;
  FFixtures := LTestRunner.BuildFixtures as ITestFixtureList;
  for LTestFixture in FFixtures do
    EnableTests(LTestFixture);
  FIsRunning := True;
  Logger.Log(TLogLevel.Information, 'Running %d enabled tests..', [FTestCount]);
  LResults := LTestRunner.Execute;
  if IsSuccess then
    Logger.Log(TLogLevel.Information, Format('PASS: All %d enabled tests passed', [FTestCount]))
  else
    Logger.Log(TLogLevel.Information, Format('FAIL: %d of %d enabled tests failed', [FFailCount, FTestCount]));
  FIsRunning := False;
end;

procedure TRunner.SetEnabledTests(const AValue: TArray<string>);
begin
  FEnabledTests := AValue;
end;

procedure TRunner.OnBeginTest(const threadId: TThreadID; const Test: ITestInfo);
begin
  FCurrentTest := Test.Name;
end;

procedure TRunner.OnEndTest(const threadId: TThreadID; const Test: ITestResult);
var
  LMessage: TLogMessage;
  LErrorMessage: string;
begin
  if FTestsCompletedCount < FTestCount then
    Inc(FTestsCompletedCount);
  for LMessage in Test.LogMessages do
  begin
    Logger.Log(LMessage.Level, LMessage.Msg);
    FMessages.Add(TRunnerMessage.Create(LMessage));
  end;
  if Test.ResultType <> TTestResultType.Pass then
  begin
    Inc(FFailCount);
    LErrorMessage := Format('%s: %s', [Test.Test.Name, Test.Message]);
    Logger.Log(TLogLevel.Error, LErrorMessage);
    FMessages.Add(TRunnerMessage.Create(LErrorMessage));
  end;
end;

procedure TRunner.OnEndSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TRunner.OnEndSetupTest(const threadId: TThreadID; const Test: ITestInfo);
begin

end;

procedure TRunner.OnEndTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TRunner.OnEndTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
begin

end;

procedure TRunner.OnEndTestFixture(const threadId: TThreadID; const results: IFixtureResult);
begin

end;

procedure TRunner.OnExecuteTest(const threadId: TThreadID; const Test: ITestInfo);
begin

end;

procedure TRunner.OnLog(const logType: DUnitX.TestFramework.TLogLevel; const msg: string);
begin

end;

procedure TRunner.OnSetupFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TRunner.OnSetupTest(const threadId: TThreadID; const Test: ITestInfo);
begin

end;

procedure TRunner.OnStartTestFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TRunner.OnTearDownFixture(const threadId: TThreadID; const fixture: ITestFixtureInfo);
begin

end;

procedure TRunner.OnTeardownTest(const threadId: TThreadID; const Test: ITestInfo);
begin

end;

procedure TRunner.OnTestError(const threadId: TThreadID; const Error: ITestError);
begin

end;

procedure TRunner.OnTestFailure(const threadId: TThreadID; const Failure: ITestError);
begin

end;

procedure TRunner.OnTestIgnored(const threadId: TThreadID; const AIgnored: ITestResult);
begin

end;

procedure TRunner.OnTestingEnds(const RunResults: IRunResults);
begin

end;

procedure TRunner.OnTestingStarts(const threadId: TThreadID; testCount, testActiveCount: Cardinal);
begin

end;

procedure TRunner.OnTestMemoryLeak(const threadId: TThreadID; const Test: ITestResult);
begin

end;

procedure TRunner.OnTestSuccess(const threadId: TThreadID; const Test: ITestResult);
begin

end;

end.
