@ECHO OFF
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND
REM Anton Klarén (anton@klaren.it)

REM Make sure we have JAVA_HOME
IF NOT DEFINED JAVA_HOME (FOR /F "tokens=2*" %%i IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit" /s ^| FIND "JavaHome"') DO (
	SET "_javaProbe=%%j"
))
IF DEFINED _javaProbe (
	ECHO Newest jdk found to be %_javaProbe%
	SET "JAVA_HOME=%_javaProbe%"
	SETX JAVA_HOME "%_javaProbe%"
	SET "_javaPath=%_javaProbe%\bin"
) ELSE (
	SET "_javaPath=%JAVA_HOME%\bin"
)

REM Save old path
FOR /F "tokens=2*" %%i IN ('REG QUERY "HKCU\Environment" /v "Path" ^| FIND /I "Path"') DO (SET "_oldPath=%%j")

REM Add to path if not already there
ECHO."%PATH%" | FIND /I "%_javaPath%">NUL && ( 
	ECHO Nothing changed. Path already includes %_javaPath%
) || ( 
	ECHO Setting up path
	SET "PATH=%PATH%;%_javaPath%"
	
	REM Persist to registry, unable to use SETX since max length is 1024 and PATH might be longer
	IF DEFINED _oldPath (
		ECHO Saving old path %_oldPath%
		REG ADD "HKCU\Environment" /f /v Path /t REG_EXPAND_SZ /d "%_oldPath%;%_javaPath%"
	) ELSE (
		ECHO Registering new Path
		REG ADD "HKCU\Environment" /f /v Path /t REG_EXPAND_SZ /d "%_javaPath%"
	)
	
	REM SETX will broadcast WM_SETTINGCHANGE message to the dispatcher so user environment will be updated accordingly
	SETX DUMMY ""
	REG DELETE "HKCU\Environment" /v DUMMY /f
)

REM Cleanup
SET _javaProbe=
SET _javaPath=
SET _oldPath=