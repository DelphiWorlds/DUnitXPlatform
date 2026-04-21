unit DUnitXP.Model.Tests;

interface

uses
  System.Generics.Collections,
  DUnitX.Extensibility, DUnitX.TestFramework;

type
(*
  ITest = interface
    ['{0CCCE0C7-9AD1-4C3A-86EF-E882D3A839AB}']
    function GetName : string;
    function GetFullName : string;
    function GetMethodName : string;
    function GetCategories : TList<string>;
    function GetTestMethod : TTestMethod;
    function GetTestFixture : ITestFixture;
    function GetTestStartTime : TDateTime;
    function GetTestEndTime : TDateTime;
    function GetTestDuration : TTimeSpan;
    function GetEnabled : boolean;
    procedure SetEnabled(const value : boolean);
    function GetIgnored : boolean;
    function GetIgnoreReason : string;
    function GetIgnoreMemoryLeaks() : Boolean;
    procedure SetIgnoreMemoryLeaks(const AValue : Boolean);
    function GetMaxTime: cardinal;
    procedure SetMaxTime(const AValue: cardinal);
    function GetTimedOut: Boolean;
    procedure SetTimedOut(const AValue: Boolean);
    function GetIsTestCase : boolean;

    property Name : string read GetName;
    property FullName : string read GetFullName;
    property MethodName : string read GetMethodName;
    property Categories : TList<string> read GetCategories;
    property Enabled : boolean read GetEnabled write SetEnabled;
    property Fixture : ITestFixture read GetTestFixture;
    property Ignored : boolean read GetIgnored;
    property IgnoreReason : string read GetIgnoreReason;
    property IsTestCase : boolean read GetIsTestCase;
    property TestMethod : TTestMethod read GetTestMethod;
    property IgnoreMemoryLeaks : Boolean read GetIgnoreMemoryLeaks write SetIgnoreMemoryLeaks;
    property MaxTime: cardinal read GetMaxTime write SetMaxTime;
    property TimedOut: Boolean read GetTimedOut write SetTimedOut;
  end;
*)

  TFixtureTest = class
  private
    FTest: ITest;
    function GetFullName: string;
    function GetIsChecked: Boolean;
    function GetMethodName : string;
    function GetName: string;
    procedure SetIsChecked(const Value: Boolean);
  public
    constructor Create(const ATest: ITest);
    property IsChecked: Boolean read GetIsChecked write SetIsChecked;
    property FullName: string read GetFullName;
    property TestMethodName: string read GetMethodName;
    property Name: string read GetName;
    property Test: ITest read FTest;
  end;

  TFixtureTestList = class(TObjectList<TFixtureTest>)
  // private
  //   FTests: TFixtureTestList;
  public
    constructor Create(const ATests: ITestList);
    procedure SetChecked(const AFullNames: TArray<string>);
  end;

  TFixtureList = class;

  TFixture = class
  private
    FChildren: TFixtureList;
    FTestFixture: ITestFixture;
    FTests: TFixtureTestList;
    function GetFullName: string;
    function GetHasChildren: Boolean;
    function GetIsChecked: Boolean;
    function GetName: string;
  protected
    // property TestFixture: ITestFixture read FTestFixture;
  public
    constructor Create(const ATestFixture: ITestFixture);
    destructor Destroy; override;
    procedure SetChecked(const AFullNames: TArray<string>);
    procedure SetIsChecked(const Value: Boolean);
    property Children: TFixtureList read FChildren;
    property HasChildren: Boolean read GetHasChildren;
    property FullName: string read GetFullName;
    property IsChecked: Boolean read GetIsChecked write SetIsChecked;
    property Name: string read GetName;
    property TestFixture: ITestFixture read FTestFixture;
    property Tests: TFixtureTestList read FTests;
  end;

  TFixtureList = class(TObjectList<TFixture>)
  private
    FFixtures: ITestFixtureList;
  protected
    property Fixtures: ITestFixtureList read FFixtures;
  public
    constructor Create(const AFixtures: ITestFixtureList);
    function ChildrenOf(const AFullName: string): TFixtureList;
  end;

  TFixtures = class
  private
    FItems: TFixtureList;
    FTestRunner: ITestRunner;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetChecked(const AFullNames: TArray<string>);
    property Items: TFixtureList read FItems;
    property TestRunner: ITestRunner read FTestRunner;
  end;

implementation

uses
  System.SysUtils, System.StrUtils;

{ TFixtureTest }

constructor TFixtureTest.Create(const ATest: ITest);
begin
  inherited Create;
  FTest := ATest;
end;

function TFixtureTest.GetFullName: string;
begin
  Result := FTest.FullName;
end;

function TFixtureTest.GetIsChecked: Boolean;
begin
  Result := FTest.Enabled;
end;

function TFixtureTest.GetMethodName: string;
begin
  Result := FTest.MethodName;
end;

function TFixtureTest.GetName: string;
begin
  Result := FTest.Name;
end;

procedure TFixtureTest.SetIsChecked(const Value: Boolean);
begin
  FTest.Enabled := Value;
end;

{ TFixtureTestList }

constructor TFixtureTestList.Create(const ATests: ITestList);
var
  LTest: ITest;
begin
  inherited Create;
  for LTest in ATests do
    Add(TFixtureTest.Create(LTest));
end;

procedure TFixtureTestList.SetChecked(const AFullNames: TArray<string>);
var
  LTest: TFixtureTest;
begin
  for LTest in Self do
    LTest.IsChecked := MatchStr(LTest.FullName, AFullNames);
end;

{ TFixture }

constructor TFixture.Create(const ATestFixture: ITestFixture);
begin
  inherited Create;
  FTestFixture := ATestFixture;
  // FTestFixture.OnMethodExecuted()
  FChildren := TFixtureList.Create(ATestFixture.Children);
  FTests := TFixtureTestList.Create(FTestFixture.Tests);
end;

destructor TFixture.Destroy;
begin
  FChildren.Free;
  FTests.Free;
  inherited;
end;

function TFixture.GetFullName: string;
begin
  Result := FTestFixture.FullName;
end;

function TFixture.GetHasChildren: Boolean;
begin
  Result := FChildren.Count > 0;
end;

function TFixture.GetIsChecked: Boolean;
begin
  Result := FTestFixture.Enabled;
end;

function TFixture.GetName: string;
begin
  Result := FTestFixture.Name;
end;

procedure TFixture.SetChecked(const AFullNames: TArray<string>);
var
  LChild: TFixture;
  LTest: TFixtureTest;
begin
  IsChecked := MatchStr(FullName, AFullNames);
  for LChild in Children do
    LChild.SetChecked(AFullNames);
  for LTest in Tests do
    LTest.IsChecked := MatchStr(LTest.FullName, AFullNames);
end;

procedure TFixture.SetIsChecked(const Value: Boolean);
begin
  FTestFixture.Enabled := Value;
end;

{ TFixtureList }

constructor TFixtureList.Create(const AFixtures: ITestFixtureList);
var
  LTestFixture: ITestFixture;
begin
  inherited Create;
  FFixtures := AFixtures;
  for LTestFixture in FFixtures do
    Add(TFixture.Create(LTestFixture));
end;

function TFixtureList.ChildrenOf(const AFullName: string): TFixtureList;
var
  LFixture: TFixture;
begin
  Result := nil;
  for LFixture in Self do
  begin
    if LFixture.FullName.Equals(AFullName) then
      Result := LFixture.Children
    else
      Result := LFixture.Children.ChildrenOf(AFullName);
    if Result <> nil then
      Break;
  end;
end;

{ TFixtures }

constructor TFixtures.Create;
var
  LFixtureList: ITestFixtureList;
begin
  inherited;
  LFixtureList := TDUnitX.CreateRunner.BuildFixtures as ITestFixtureList;
  FItems := TFixtureList.Create(LFixtureList);
end;

destructor TFixtures.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TFixtures.SetChecked(const AFullNames: TArray<string>);
var
  LChild: TFixture;
begin
  for LChild in FItems do
    LChild.SetChecked(AFullNames);
end;

end.
