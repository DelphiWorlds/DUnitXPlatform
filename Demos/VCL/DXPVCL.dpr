program DXPVCL;



{$R 'Data.res' '..\..\Data.rc'}

uses
  Vcl.Forms,
  DUnitX.Examples.General,
  DUnitXP,
  DUnitXP.GUI.VCL in '..\..\VCL\DUnitXP.GUI.VCL.pas' {GUI};

{$R *.res}

begin
  DUnitXPApp.Run(8082);
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGUI, GUI);
  Application.Run;
end.
