program DXPFMX;



{$R 'Data.res' '..\..\Data.rc'}

uses
  System.StartUpCopy,
  FMX.Forms,
  DUnitX.Examples.General,
  DUnitXP,
  DUnitXP.GUI.FMX in '..\..\FMX\DUnitXP.GUI.FMX.pas' {GUI};

{$R *.res}

begin
  DUnitXPApp.Run(8082);
  Application.Initialize;
  Application.CreateForm(TGUI, GUI);
  Application.Run;
end.
