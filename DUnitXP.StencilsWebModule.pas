unit DUnitXP.StencilsWebModule;

interface

uses
  System.Classes,
  System.Masks,
  Web.HTTPApp, Web.Stencils,
  Charon.WebStencils.Controller;

type
(*
  TWebFileDispatcher = class(Web.HTTPApp.TWebFileDispatcher, IWebDispatch)
  private
    FMaskEx: TMask;
  public
    { IWebDispatch }
    function DispatchMask: TMask;
  public
    constructor Create(AOwner: TComponent); override;
  end;
*)

  TStencilsWebModule = class(TWebModule)
    WebStencilsEngine: TWebStencilsEngine;
    WebFileDispatcher: TWebFileDispatcher;
    WebSessionManager: TWebSessionManager;
    WebStencilsProcessor: TWebStencilsProcessor;
    procedure WebStencilsEngineValue(Sender: TObject; const AObjectName, APropName: string; var AReplaceText: string; var AHandled: Boolean);
    procedure WebStencilsEngineError(Sender: TObject; const AMessage: string);
    procedure WebStencilsEngineFileNotFound(Sender: TObject; const ARequest: TWebPostProcessorRequest; var ANotFoundPagePath: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  WebModuleClass: TComponentClass = TStencilsWebModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  System.SysUtils, System.IOUtils,
  Charon, Charon.WebStencils.Environment, Charon.WebDispatcherController, Charon.WebModule.Helper,
  DUnitXP,
  DUnitXP.Logger;

// TODO: Refactor to another unit?
type
  TDUnitXPEnvironment = class(TEnvironment)
  public
    constructor Create;
  end;

(*
{ TWebFileDispatcher }

constructor TWebFileDispatcher.Create(AOwner: TComponent);
begin
  inherited;
  // REALLY allow all paths. The original requires at least "/" to be present
  FMaskEx := TMask.Create('*');
end;

function TWebFileDispatcher.DispatchMask: TMask;
begin
  Result := FMaskEx;
end;
*)

{ TDUnitXPEnvironment }

constructor TDUnitXPEnvironment.Create;
begin
  inherited;
  FAppName := 'DUnitXPlatform v0.0.1';
  FCompanyName := 'Delphi Worlds';
  FHTMLPath := TPath.Combine(DUnitXPApp.GetResourcesPath, 'html');
end;

{ TStencilsWebModule }

constructor TStencilsWebModule.Create(AOwner: TComponent);
var
  LEnvironment: TDUnitXPEnvironment;
begin
  inherited;
  LEnvironment := TDUnitXPEnvironment.Create;
  WebStencilsEngine.RootDirectory := LEnvironment.HTMLPath;
  WebFileDispatcher.RootDirectory := LEnvironment.HTMLPath;
  WebStencilsEngine.AddVar('env', LEnvironment);
  WebModuleCreated;
end;

procedure TStencilsWebModule.WebStencilsEngineError(Sender: TObject; const AMessage: string);
begin
  Logger.Log(TLogLevel.Error,'WebStencilsEngineError: %s', [AMessage]);
end;

procedure TStencilsWebModule.WebStencilsEngineFileNotFound(Sender: TObject; const ARequest: TWebPostProcessorRequest; var ANotFoundPagePath: string);
begin
  Logger.Log(TLogLevel.Error,'WebStencilsEngineFileNotFound: %s', [ANotFoundPagePath]);
end;

procedure TStencilsWebModule.WebStencilsEngineValue(Sender: TObject; const AObjectName, APropName: string; var AReplaceText: string;
  var AHandled: Boolean);
begin
  if SameText(AObjectName, 'system') then
  begin
    if SameText(APropName, 'timestamp') then
      AReplaceText := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)
    else if SameText(APropName, 'year') then
      AReplaceText := FormatDateTime('yyyy', Now)
    else
      AReplaceText := Format('SYSTEM_%s_NOT_FOUND', [APropName.ToUpper]);
    AHandled := True;
  end;
end;

end.
