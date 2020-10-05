mkdir build
cd build

set CURRENT_PATH=%~dp0
set LIBRARY_PATH=%CURRENT_PATH%build\root
set PATH=%LIBRARY_PATH%\mingw-w64\bin;%LIBRARY_PREFIX%\usr\bin;%LIBRARY_BIN%;%PATH%
set _CL_=/utf-8

cmake .. -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PATH% -DSPM_ENABLE_SHARED=OFF
cmake --build . --config Release --target install || goto :error

cd %SRC_DIR%\python
%PYTHON% setup.py build
%PYTHON% setup.py install

IF %ERRORLEVEL% NEQ 0 exit 1
