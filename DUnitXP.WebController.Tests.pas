unit DUnitXP.WebController.Tests;

interface

uses
  System.JSON,
  Charon.Types, Charon.WebController,
  DUnitXP.Model.Tests;

type
  TTestsWebController = class(TWebController)
  private
    class procedure AddFixture(const AArray: TJSONArray; const AFixture: TFixture; const ARecursive: Boolean = False);
  private
    procedure CheckHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
    procedure ListHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
  public
    class function GetList(const ARequest: TWebRequest): TFixtureList;
  public
    constructor Create;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.Classes,
  DUnitXP.Session;

{ TTestsWebController }

constructor TTestsWebController.Create;
begin
  inherited;
  AddRoute(TMethodType.mtGet, '/api/tests/list', ListHandler);
  AddRoute(TMethodType.mtPost, '/api/tests/check', CheckHandler);
end;

procedure TTestsWebController.CheckHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LCheckedTestNames: TArray<string>;
  LName: string;
  LIsChecked: Boolean;
  LIndex: Integer;
  LFields: TStrings;
  LFixtures: TFixtures;
begin
  if ARequest.Session <> nil then
  begin
    LCheckedTestNames := TSession.GetCheckedTests(ARequest.Session);
    if ARequest.MethodType = TMethodType.mtGet then
      LFields := ARequest.QueryFields
    else
      LFields := ARequest.ContentFields;
    // Logger.Log(TLogLevel.Information, 'Fields: %s', [LFields.DelimitedText]);
    LName := LFields.Values['name'];
    LIsChecked := LFields.Values['checked'] = '1';
    LIndex := IndexStr(LName, LCheckedTestNames);
    if LIsChecked and (LIndex = -1) then
      LCheckedTestNames := LCheckedTestNames + [LName]
    else if not LIsChecked and (LIndex > -1) then
      Delete(LCheckedTestNames, LIndex, 1);
    TSession.SetCheckedTests(ARequest.Session, LCheckedTestNames);
    LFixtures := TSession.GetFixtures(ARequest.Session);
    LFixtures.SetChecked(LCheckedTestNames);
  end
  else
    AResponse.StatusCode := 400;
end;

class procedure TTestsWebController.AddFixture(const AArray: TJSONArray; const AFixture: TFixture; const ARecursive: Boolean = False);
var
  LJSON: TJSONObject;
  LChildren: TJSONArray;
  LFixture: TFixture;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Name', AFixture.Name);
  LJSON.AddPair('FullName', AFixture.FullName);
  LJSON.AddPair('HasChildren', Ord(AFixture.HasChildren));
  LChildren := TJSONArray.Create;
  if ARecursive then
  begin
    for LFixture in AFixture.Children do
      AddFixture(LChildren, LFixture);
  end;
  LJSON.AddPair('Children', LChildren);
  AArray.AddElement(LJSON);
end;

class function TTestsWebController.GetList(const ARequest: TWebRequest): TFixtureList;
var
  LParentName: string;
  LFixtures: TFixtures;
begin
  LFixtures := TSession.GetFixtures(ARequest.Session);
  Result := LFixtures.Items;
  LParentName := ARequest.QueryFields.Values['parent'];
  if not LParentName.IsEmpty then
  begin
    if not LParentName.Equals('.') then
      Result := LFixtures.Items.ChildrenOf(LParentName);
  end;
end;

procedure TTestsWebController.ListHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LItems: TFixtureList;
  LFixture: TFixture;
  LResponse: TJSONArray;
  LParentName: string;
begin
  LResponse := TJSONArray.Create;
  try
    LItems := GetList(ARequest);
    if LItems <> nil then
    begin
      for LFixture in LItems do
        AddFixture(LResponse, LFixture, LParentName.IsEmpty);
    end;
    AResponse.Content := LResponse.ToJSON;
  finally
    LResponse.Free;
  end;
end;

end.
