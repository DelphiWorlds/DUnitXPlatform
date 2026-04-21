# DUnitXPlatform

A WebStencils based library for creating a [DUnitX](https://github.com/vsofttechnologies/dunitx) runner operated external to the device

# Description

Traditionally, unit tests can be executed via a GUI or console runner, however when performing unit tests on mobile, having a UI on the device to control which tests are run can be cumbersome, especially on smaller screens.

DUnitXPlatform embeds an Indy-based web server, and uses WebBroker and WebStencils to provide a UI accessed via a browser external to the device

# Dependencies

This library includes [DUnitX](https://github.com/vsofttechnologies/dunitx) and [Charon](https://github.com/DelphiWorlds/Charon) as git submodules. Charon is a library that leverages the WebBroker features of Delphi to create web applications in a convenient fashion.

# Cloning

To clone this repository with its dependencies, use:

```
git clone --recursive https://github.com/DelphiWorlds/DUnitXPlatform.git
```

This will automatically clone the required dependencies (DUnitX and Charon) as git submodules.

# Demos

There are demos for FMX, VCL and Console apps in the `Demos` folder, which use the tests from `DUnitX.Examples.General` in DUnitX.

# Creating a DUnitXPlatform runner application

To create a runner application, follow these steps -

## In Delphi

1. Create a new multi-device application using File|New|Multi-Device Application
2. Leave Blank Application selected, and click OK
3. Once the application is created, right-click `Unit1.pas` in Project Manager
4. Click Remove From Project
5. Click Yes
6. In Project Manager, right-click the project
7. Click Add...
8. Select the `DUnitXP.GUI.FMX.pas` file in the FMX folder of DUnitXPlatform, and click Open
9. Right-click the project again
10. Click Add..
11. Select the `Data.rc` file in the root folder of DUnitXPlatform, and click Open
12. Use `Ctrl-V`, or right-click the project in Project Manager and click View Source
13. In the `uses` clause, just after `System.StartUpCopy`, add:
    1. DUnitXP
    2. The units containing your unit tests, e.g.:
       
       ```
       uses
         System.StartUpCopy,
         FMX.Forms,
         DUnitXP,
         DUnitX.Examples.General,
         DUnitXP.GUI.FMX in 'DUnitXP.GUI.FMX.pas' {GUI};
       ```
14. In the main program block, before `Application.Initialize`, add:
    ```
    DUnitXPApp.Run(8080); // Replace 8080 with a different port number, if you require
    ```

In the Project Options of your project:

1. Select Building > Delphi Compiler
2. In the Target combo, select the config/platform you wish to target
3. In the Search path edit, include:
   ```
   libs/DUnitX/Source;libs/Charon
   ```
   
   For **iOS Device 64-bit platform ONLY**, include:
   ```
   $(BDS)\source\Indy10\protocols;$(BDS)\source\Internet
   ```
   This is required as Delphi does not ship a compiled `IdHTTPWebBrokerBridge` unit (required by Charon) for iOS.

## Resources

Copy `resources.zip` from the root folder of DUnitXPlatform to the root folder of your project

This contains the file necessary for the WebStencils features of DUnitXPlatform to operate. The zip file is extracted by the DUnitXPlatform code to:

* On iOS/Android: The folder represented by `TPath.GetDocumentsPath`
* On macOS/Windows: The folder represented by `TPath.GetSharedDocumentsPath`, with a folder appended using the name of the app

## SSL Support

As per Charon, SSL support is via TaurusTLS. To use SSL:

1. Include a conditional define of `USESSL` in the project options
2. Include a path to [TaurusTLS](https://github.com/TaurusTLS-Developers/TaurusTLS) in the project Search path value.
3. Create a file called `ssl.json`, that looks like this:
   ```json
   {
     "KeysPath": "C:\\Certs",
     "PublicKey": "pubkey.pem",
     "PrivateKey": "privkey.pem",
     "RootKey": "rootkey.pem",
     "PassPhrase": "secret"
   }
   ```
   Replacing the relevant _values_ to suit your configuration. On Android/iOS `KeysPath` value can be omitted if you're deploying the files to the root of the default documents folder (see the next item)
4. For mobile:
   1. Add `ssl.json` to the deployment using a Remote Path value relevant to the platform, i.e. for Android: `.\assets\internal`, for iOS: `.\StartUp\Documents`
   2. Add the key files to the deployment
5. For Desktop: 
   1. Set the `KeysPath` value in `ssl.json` to the folder containing the key files
   2. Replacing [appname] with the name of your app:
      
      Windows: Put `ssl.json` in `C:\ProgramData\[appname]`

      macOS:  Put `ssl.json` in `/Users/[username]/Public/[appname]` (replacing [username] with the relevant value)