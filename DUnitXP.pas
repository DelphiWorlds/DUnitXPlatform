unit DUnitXP;

interface

type
  IDUnitXPApp = interface
    ['{15C73B82-36D0-4150-845A-502EEAF8CCD4}']
    function GetResourcesPath: string;
    procedure Run(const APort: Integer);
  end;

var
  DUnitXPApp: IDUnitXPApp;

implementation

uses
  System.Classes, System.JSON, System.IOUtils, System.SysUtils, System.Zip, System.Types,

  Charon, Charon.Types,
  {$IF Defined(USESSL)}
  Charon.TaurusTLS,
  {$ENDIF}
  Charon.WebServer.Indy, Charon.WebServer.IndyWebDispatch,
  DUnitXP.StencilsWebModule, DUnitXP.WebController.Tests, DUnitXP.WebStencilsController.Tests;

type
  TDUnitXPApp = class(TInterfacedObject, IDUnitXPApp)
  private
    function GetDataPath: string;
    procedure ExtractResources;
  public
    { IDUnitXPApp }
    function GetResourcesPath: string;
    procedure Run(const APort: Integer);
  public
    constructor Create;
  end;

{$IF Defined(USESSL)}
  TTLSOptionsHelper = record helper for TTLSOptions
    procedure LoadFromFile(const AFileName: string);
    function UpdateKeyFileName(const AFileName, AKeysPath: string): string;
  end;

{ TTLSOptionsHelper }

procedure TTLSOptionsHelper.LoadFromFile(const AFileName: string);
var
  LJSON: TJSONValue;
  LKeysPath: string;
begin
  if TFile.Exists(AFileName) then
  begin
    LKeysPath := '';
    LJSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(AFileName));
    if LJSON <> nil then
    try
      LJSON.TryGetValue('KeysPath', LKeysPath);
      LJSON.TryGetValue('Passphrase', Passphrase);
      LJSON.TryGetValue('PublicKey', PublicKey);
      LJSON.TryGetValue('PrivateKey', PrivateKey);
      LJSON.TryGetValue('RootKey', RootKey);
    finally
      LJSON.Free;
    end;
    if not LKeysPath.IsEmpty and TDirectory.Exists(LKeysPath) then
    begin
      PublicKey := UpdateKeyFileName(PublicKey, LKeysPath);
      PrivateKey := UpdateKeyFileName(PrivateKey, LKeysPath);
      RootKey := UpdateKeyFileName(RootKey, LKeysPath);
    end;
  end;
end;

function TTLSOptionsHelper.UpdateKeyFileName(const AFileName, AKeysPath: string): string;
var
  LDirName: string;
begin
  LDirName := TPath.GetDirectoryName(AFileName);
  if LDirName.IsEmpty or not TDirectory.Exists(LDirName) then
    Result := TPath.Combine(AKeysPath, AFileName)
  else
    Result := AFileName;
end;
{$ENDIF}

{ TDUnitXPApp }

constructor TDUnitXPApp.Create;
begin
  inherited Create;
  ExtractResources;
end;

function TDUnitXPApp.GetDataPath: string;
begin
  Result := '';
  {$IF Defined(IOS) or Defined(ANDROID)}
  Result := TPath.GetDocumentsPath;
  {$ENDIF}
  {$IF Defined(MSWINDOWS) or Defined(OSX)}
  Result := TPath.Combine(TPath.GetPublicPath, TPath.GetFileNameWithoutExtension(TPath.GetFileName(ParamStr(0))));
  {$ENDIF}
end;

function TDUnitXPApp.GetResourcesPath: string;
begin
  Result := TPath.Combine(GetDataPath, 'resources');
end;

procedure TDUnitXPApp.ExtractResources;
const
  cResourcesName = 'Resources';
var
  LResStream: TResourceStream;
  LDocumentsPath, LZipFileName: string;
begin
  LDocumentsPath := GetDataPath;
  if not LDocumentsPath.IsEmpty and (TDirectory.Exists(LDocumentsPath) or ForceDirectories(LDocumentsPath)) then
  begin
    if FindResource(HInstance, PChar(cResourcesName), RT_RCDATA) > 0 then
    begin
      LResStream := TResourceStream.Create(HInstance, cResourcesName, RT_RCDATA);
      try
        LZipFileName := TPath.Combine(LDocumentsPath, 'resources.zip');
        LResStream.SaveToFile(LZipFileName);
        try
          TZipFile.ExtractZipFile(LZipFileName, LDocumentsPath);
        finally
          TFile.Delete(LZipFileName);
        end;
      finally
        LResStream.Free;
      end;
    end;
  end;
end;

procedure TDUnitXPApp.Run(const APort: Integer);
{$IF Defined(USESSL)}
var
  LOptions: TTLSOptions;
{$ENDIF}
begin
  {$IF Defined(USESSL)}
  LOptions.LoadFromFile(TPath.Combine(GetDataPath, 'ssl.json'));
  {$ENDIF}
  WebApplication.UseServer(TIndyWebDispatchServer.Create(TStencilsWebModule))
     // API
    .AddController(TTestsWebController.Create)
     // WebStencils
    .AddController(TTestsWebStencilsController.Create)
    {$IF Defined(USESSL)}
    .UseSSL(TCharonTaurusTLS.Create(LOptions))
    {$ENDIF}
    .Run(APort);
end;

initialization
  DUnitXPApp := TDUnitXPApp.Create;

end.
