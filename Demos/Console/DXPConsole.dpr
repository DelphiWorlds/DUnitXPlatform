program DXPConsole;

{$APPTYPE CONSOLE}

{$R *.res}



{$R 'Data.res' '..\..\Data.rc'}

uses
  DUnitX.Examples.General,
  DUnitXP;

begin
  DUnitXPApp.Run(8082);
end.
