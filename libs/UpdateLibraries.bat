@Echo Off
CD /D "%~dp0"
Set GitBinary=%ProgramFiles(x86)%\Git\bin\git.exe
If Not Exist "%GitBinary%" Goto End

Call :GitUpdate LibApolloFixes https://github.com/wildstarnasa/LibApolloFixes.git
Call :GitUpdate GeminiLogging https://github.com/wildstarnasa/GeminiLogging.git
Call :GitUpdate GeminiAddon https://github.com/wildstarnasa/GeminiAddon.git
Call :GitUpdate CallbackHandler https://github.com/wildstarnasa/CallbackHandler.git
Call :GitUpdate GeminiEvent https://github.com/wildstarnasa/GeminiEvent.git
Call :GitUpdate GeminiHook https://github.com/wildstarnasa/GeminiHook.git
Call :GitUpdate LibError https://github.com/wildstarnasa/LibError.git

:: Done... :)
Goto End



:GitUpdate
If Not Exist "%1" (
:: Clone
echo Downloading %1...
"%GitBinary%" clone "%2"
Echo.
EndLocal && Goto :EOF
)
:: Pull
echo Updating %1...
CD "%1"
"%GitBinary%" pull
Echo.
CD ..
EndLocal && Goto :EOF


:End
Pause
