unit DUnitXP.WebStencilsController.Tests;

interface

uses
  Charon.Types,
  Charon.WebStencils.Controller;

type
  TTestsWebStencilsController = class(TWebStencilsController)
  private
    procedure ChildrenHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
    procedure ListHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
    procedure RunHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
    procedure RunStatusHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
  public
    constructor Create;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.Classes, System.StrUtils,
  DUnitXP.Model.Tests,
  DUnitXP.WebController.Tests,
  DUnitXP.Session,
  DUnitXP.Runner;

{ TTestsWebStencilsController }

constructor TTestsWebStencilsController.Create;
begin
  inherited;
  TemplatePath := 'layouts/tests';
  AddRoute(TMethodType.mtGet, '/', ListHandler);
  AddRoute(TMethodType.mtGet, '/tests', ListHandler);
  AddRoute(TMethodType.mtGet, '/tests/children', ChildrenHandler);
  AddRoute(TMethodType.mtPost, '/tests/run', RunHandler);
  AddRoute(TMethodType.mtGet, '/tests/run/status', RunStatusHandler);
end;

procedure TTestsWebStencilsController.ListHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LFixtures: TFixtures;
begin
  // Log.d('TFixturesWebStencilsController.ListHandler > fixturenames: %s', [string.Join(';', LCheckedFixtureNames)]);
  LFixtures := TSession.GetFixtures(ARequest.Session);
  AResponse.Content := RenderTemplate('list', LFixtures, False);
end;

procedure TTestsWebStencilsController.ChildrenHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LItems: TFixtureList;
begin
  LItems := TTestsWebController.GetList(ARequest);
  // Log.d('TFixturesWebStencilsController.ChildrenHandler > LItems.Count: %d', [LItems.Count]);
  AResponse.Content := RenderTemplate('item', LItems, False, 'Items');
//  Log.d('TFixturesWebStencilsController.ChildrenHandler > AResponse.Content: %s', [AResponse.Content]);
end;

procedure TTestsWebStencilsController.RunHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LRunner: TRunner;
  LRunCheck: TRunCheck;
begin
  LRunCheck := TSession.GetRunCheck(ARequest.Session);
  LRunCheck.NeedsStatus := True;
  AddVar(LRunCheck.Clone, 'RunCheck'); // Not sure if Clone is needed now?
  LRunner := TSession.GetRunner(ARequest.Session);
  if not LRunner.IsRunning then
    TThread.CreateAnonymousThread(LRunner.Run).Start;
  AResponse.Content := RenderTemplate('run', LRunner, False);
end;

procedure TTestsWebStencilsController.RunStatusHandler(const ARequest: TWebRequest; const AResponse: TWebResponse);
var
  LRunner: TRunner;
  LRunCheck: TRunCheck;
begin
  LRunner := TSession.GetRunner(ARequest.Session);
  LRunCheck := TSession.GetRunCheck(ARequest.Session);
  if LRunner.IsComplete then
  begin
    LRunCheck.NeedsStatus := False;
    // Log.d('Should be the last status request as the tests have completed');
  end;
//  else
//    Log.d('Incomplete');
  AddVar(LRunCheck.Clone, 'RunCheck');
  AResponse.Content := RenderTemplate('run-status', LRunner, False);
end;

end.
