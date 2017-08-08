REM @echo off
pushd %~p0
cd ..\..
mkdir b
cd b
REM cd ..\..
IF "%1%"=="64" ECHO "BUILDING 64bit solution" 
IF "%1%"=="ARM" ECHO "BUILDING ARM solution"
IF "%1%"=="32" ECHO "BUILDING 32bit solution"

SET NETFX_CORE=""
IF "%3%"=="WindowsPhone81" SET NETFX_CORE="TRUE" 
IF "%3%"=="WindowsStore81" SET NETFX_CORE="TRUE"
IF "%3%"=="WindowsStore10" SET NETFX_CORE="TRUE"

SET OS_MODE=
IF "%1%"=="64" SET OS_MODE= Win64
IF "%1%"=="ARM" SET OS_MODE= ARM

SET PROGRAMFILES_DIR_X86=%programfiles(x86)%
if NOT EXIST "%PROGRAMFILES_DIR_X86%" SET PROGRAMFILES_DIR_X86=%programfiles%
SET PROGRAMFILES_DIR=%programfiles%

REM Find CMake  
SET CMAKE="cmake.exe"
IF EXIST "%PROGRAMFILES_DIR_X86%\CMake 2.8\bin\cmake.exe" SET CMAKE="%PROGRAMFILES_DIR_X86%\CMake 2.8\bin\cmake.exe"
IF EXIST "%PROGRAMFILES_DIR_X86%\CMake\bin\cmake.exe" SET CMAKE="%PROGRAMFILES_DIR_X86%\CMake\bin\cmake.exe"
IF EXIST "%PROGRAMFILES_DIR%\CMake\bin\cmake.exe" SET CMAKE="%PROGRAMFILES_DIR%\CMake\bin\cmake.exe"
IF EXIST "%PROGRAMW6432%\CMake\bin\cmake.exe" SET CMAKE="%PROGRAMW6432%\CMake\bin\cmake.exe"

IF EXIST "CMakeCache.txt" del CMakeCache.txt

REM Find Visual Studio or Msbuild
SET VS2005="%VS80COMNTOOLS%..\IDE\devenv.com"
SET VS2008="%VS90COMNTOOLS%..\IDE\devenv.com"
SET VS2010="%VS100COMNTOOLS%..\IDE\devenv.com"
SET VS2012="%VS110COMNTOOLS%..\IDE\devenv.com"
SET VS2013="%VS120COMNTOOLS%..\IDE\devenv.com"
SET VS2015="%VS140COMNTOOLS%..\IDE\devenv.com"
SET VS2017="%PROGRAMFILES_DIR_X86%\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.com"

IF EXIST "%windir%\Microsoft.NET\Framework\v3.5\MSBuild.exe" SET MSBUILD35=%windir%\Microsoft.NET\Framework\v3.5\MSBuild.exe
IF EXIST "%windir%\Microsoft.NET\Framework64\v3.5\MSBuild.exe" SET MSBUILD35=%windir%\Microsoft.NET\Framework64\v3.5\MSBuild.exe
IF EXIST "%windir%\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" SET MSBUILD40=%windir%\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe

IF EXIST "%MSBUILD35%" SET DEVENV="%MSBUILD35%"
IF EXIST "%MSBUILD40%" SET DEVENV="%MSBUILD40%"
IF EXIST %VS2005% SET DEVENV=%VS2005% 
IF EXIST %VS2008% SET DEVENV=%VS2008%
IF EXIST %VS2010% SET DEVENV=%VS2010%
IF "%4%"=="openni" GOTO SET_BUILD_TYPE
IF EXIST %VS2012% SET DEVENV=%VS2012%

IF EXIST %VS2013% SET DEVENV=%VS2013%
IF EXIST %VS2015% SET DEVENV=%VS2015%

REM IF NOT "%3%"=="WindowsStore10" GOTO SET_BUILD_TYPE
REM IF EXIST %VS2017% SET DEVENV=%VS2017%

REM IF "%2%"=="gpu" GOTO SET_BUILD_TYPE



:SET_BUILD_TYPE
IF %DEVENV%=="%MSBUILD35%" SET BUILD_TYPE=/property:Configuration=Release
IF %DEVENV%=="%MSBUILD40%" SET BUILD_TYPE=/property:Configuration=Release
IF %DEVENV%==%VS2005% SET BUILD_TYPE=/Build Release
IF %DEVENV%==%VS2008% SET BUILD_TYPE=/Build Release
IF %DEVENV%==%VS2010% SET BUILD_TYPE=/Build Release
IF %DEVENV%==%VS2012% SET BUILD_TYPE=/Build Release
IF %DEVENV%==%VS2013% SET BUILD_TYPE=/Build Release
IF %DEVENV%==%VS2015% SET BUILD_TYPE=/Build Release

IF %DEVENV%=="%MSBUILD35%" SET CMAKE_CONF="Visual Studio 12 2005%OS_MODE%"
IF %DEVENV%=="%MSBUILD40%" SET CMAKE_CONF="Visual Studio 12 2005%OS_MODE%"
IF %DEVENV%==%VS2005% SET CMAKE_CONF="Visual Studio 8 2005%OS_MODE%"
IF %DEVENV%==%VS2008% SET CMAKE_CONF="Visual Studio 9 2008%OS_MODE%"
IF %DEVENV%==%VS2010% SET CMAKE_CONF="Visual Studio 10%OS_MODE%"
IF %DEVENV%==%VS2012% SET CMAKE_CONF="Visual Studio 11%OS_MODE%"
IF %DEVENV%==%VS2013% SET CMAKE_CONF="Visual Studio 12%OS_MODE%"
IF %DEVENV%==%VS2015% SET CMAKE_CONF="Visual Studio 14%OS_MODE%"
IF %DEVENV%==%VS2017% SET CMAKE_CONF="Visual Studio 15%OS_MODE%"

SET IPP_BUILD_FLAGS=-DWITH_IPP:BOOL=FALSE 

SET OPENCV_EXTRA_MODULES_DIR="%cd%\..\opencv_contrib\modules" 
REM Setup common flags
SET CMAKE_CONF_FLAGS= -G %CMAKE_CONF% ^
-DBUILD_opencv_dnn_modern:BOOL=OFF ^
-DBUILD_DOCS:BOOL=FALSE ^
-DBUILD_TESTS:BOOL=FALSE ^
-DBUILD_opencv_apps:BOOL=FALSE ^
-DBUILD_opencv_dpm:BOOL=TRUE ^
-DBUILD_opencv_bioinspired:BOOL=TRUE ^
-DBUILD_opencv_saliency:BOOL=TRUE ^
-DBUILD_opencv_python2:BOOL=FALSE ^
-DBUILD_opencv_hdf:BOOL=FALSE ^
-DBUILD_opencv_reg:BOOL=FALSE ^
-DEMGU_ENABLE_SSE:BOOL=TRUE ^
-DBUILD_WITH_DEBUG_INFO:BOOL=FALSE ^
-DBUILD_WITH_STATIC_CRT:BOOL=FALSE ^
-DWITH_OPENGL:BOOL=OFF ^
-DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=TRUE ^
-DOPENCV_EXTRA_MODULES_PATH:String="%OPENCV_EXTRA_MODULES_DIR:\=/%" 

REM GPU performance test on windows cause compilation error, skipping it now
IF "%2%"=="gpu" GOTO NO_PERFORMANCE_TEST

IF %NETFX_CORE%=="" GOTO WITH_PERFORMANCE_TEST

:NO_PERFORMANCE_TEST
REM BUILD WITHOUT PERFORMANCE TEST
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DBUILD_opencv_ts:BOOL=OFF ^
-DBUILD_PERF_TESTS:BOOL=OFF 
GOTO END_PERFORMANCE_TEST

:WITH_PERFORMANCE_TEST
REM BUDILD WITH PERFORMANCE TEST 
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DBUILD_opencv_ts:BOOL=ON ^
-DBUILD_PERF_TESTS:BOOL=ON 

:END_PERFORMANCE_TEST

IF NOT "%4%"=="openni" GOTO END_OF_OPENNI

:WITH_OPENNI
SET OPENNI_LIB_DIR=%OPEN_NI_LIB%
IF "%OS_MODE%"==" Win64" SET OPENNI_LIB_DIR=%OPEN_NI_LIB64%
SET OPENNI_PS_BIN_DIR=%OPENNI_LIB_DIR%\..\..\PrimeSense\Sensor\Bin
IF "%OS_MODE%"==" Win64" SET OPENNI_PS_BIN_DIR=%OPENNI_LIB_DIR%\..\..\PrimeSense\Sensor\Bin64

IF EXIST "%OPENNI_LIB_DIR%" SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DWITH_OPENNI:BOOL=TRUE ^
-DOPENNI_INCLUDE_DIR:String="%OPEN_NI_INCLUDE:\=/%" ^
-DOPENNI_LIB_DIR:String="%OPENNI_LIB_DIR:\=/%" ^
-DOPENNI_PRIME_SENSOR_MODULE_BIN_DIR:String="%OPENNI_PS_BIN_DIR:\=/%"
:END_OF_OPENNI


IF "%5%"=="doc" ^
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% -DEMGU_CV_DOCUMENTATION_BUILD:BOOL=TRUE 
IF "%5%"=="htmldoc" ^
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% -DEMGU_CV_DOCUMENTATION_BUILD:BOOL=TRUE 

IF NOT %NETFX_CORE%=="" GOTO END_OF_NONE_NETFX_CORE
:NONE_NETFX_CORE
SET CMAKE_CONF_FLAGS=^
-DVTK_DIR:String="%cd%\vtk" ^
-DVTK_RENDERING_BACKEND:String="OpenGL2" ^
-DBUILD_TESTING:BOOL=FALSE ^
%CMAKE_CONF_FLAGS%
:END_OF_NONE_NETFX_CORE


IF NOT "%2%"=="gpu" GOTO WITHOUT_GPU
REM IF %DEVENV%==%VS2012% GOTO END_OF_GPU
REM IF %DEVENV%==%VS2013% GOTO END_OF_GPU

:WITH_GPU
REM SET CUDA_HOST_COMPILER=%DEVENV%
IF %DEVENV%==%VS2008% SET CUDA_HOST_COMPILER=%VS90COMNTOOLS%..\..\VC\bin\cl.exe
IF %DEVENV%==%VS2010% SET CUDA_HOST_COMPILER=%VS100COMNTOOLS%..\..\VC\bin\cl.exe
IF %DEVENV%==%VS2012% SET CUDA_HOST_COMPILER=%VS110COMNTOOLS%..\..\VC\bin\cl.exe
IF %DEVENV%==%VS2013% SET CUDA_HOST_COMPILER=%VS120COMNTOOLS%..\..\VC\bin\cl.exe
IF %DEVENV%==%VS2015% SET CUDA_HOST_COMPILER=%VS140COMNTOOLS%..\..\VC\bin\cl.exe

REM Find cuda. Use latest Cuda release for 64 bit and Cuda 6.5 for 32bit
REM We cannot use latest Cuda release for 32 bit because the 32bit version of npp has been depreciated from Cuda 7
IF "%OS_MODE%"==" Win64" GOTO WITH_GPU_64

:WITH_GPU_32
SET CUDA_SDK_DIR=%CUDA_PATH_V6_5%
SET CUDA_64_MODE=-DCUDA_64_BIT_DEVICE_CODE:BOOL=FALSE
GOTO END_GPU_ARCH

:WITH_GPU_64
SET CUDA_SDK_DIR=%CUDA_PATH%
IF NOT EXIST "%CUDA_SDK_DIR%" SET CUDA_SDK_DIR=%CUDA_PATH_V8_0%
IF NOT EXIST "%CUDA_SDK_DIR%" SET CUDA_SDK_DIR=%CUDA_PATH_V7_5%
SET CUDA_64_MODE=-DCUDA_64_BIT_DEVICE_CODE:BOOL=TRUE
SET CUDA_NVCUVENC_DIR="%PROGRAMFILES_DIR%\NVIDIA GPU Computing Toolkit\CUDA\nvidia-video-sdk\nvidia_video_sdk_6.0.1"
IF EXIST %CUDA_NVCUVENC_DIR% SET CUDA_VIDEO_SDK=-DCUDA_nvcuvenc_LIBRARY:String=%CUDA_NVCUVENC_DIR% -DWITH_NVCUVID:BOOL=TRUE
:END_GPU_ARCH

IF NOT "%8%"=="" GOTO GPU_ARCH_BIN_SPECIFIED
SET CUDA_ARCH_BIN_OPTION=""
IF EXIST "%CUDA_SDK_DIR%" SET CUDA_ARCH_BIN_OPTION="2.0 2.1(2.0) 3.0 3.5 3.7 5.0 5.2"
IF "%CUDA_SDK_DIR%" == "%CUDA_PATH_V8_0%" SET CUDA_ARCH_BIN_OPTION="2.0 2.1(2.0) 3.0 3.5 3.7 5.0 5.2 6.0 6.1"
GOTO END_GPU_ARCH_BIN

:GPU_ARCH_BIN_SPECIFIED
SET CUDA_ARCH_BIN_OPTION="%8%" 

:END_GPU_ARCH_BIN

IF EXIST "%CUDA_SDK_DIR%" SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
%CUDA_64_MODE% ^
%CUDA_VIDEO_SDK% ^
-DWITH_CUDA:BOOL=TRUE ^
-DCUDA_VERBOSE_BUILD:BOOL=TRUE ^
-DCUDA_TOOLKIT_ROOT_DIR:String="%CUDA_SDK_DIR:\=/%" ^
-DCUDA_SDK_ROOT_DIR:String="%CUDA_SDK_DIR:\=/%" ^
-DWITH_CUBLAS:BOOL=TRUE ^
-DCUDA_HOST_COMPILER:String="%CUDA_HOST_COMPILER%" ^
-DBUILD_SHARED_LIBS:BOOL=TRUE ^
-DCUDA_ARCH_BIN:STRING=%CUDA_ARCH_BIN_OPTION%

GOTO END_OF_GPU

:WITHOUT_GPU
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DWITH_CUDA:BOOL=FALSE ^
-DBUILD_SHARED_LIBS:BOOL=FALSE 

:END_OF_GPU

SET BUILD_PROJECT=
IF "%6%"=="package" SET BUILD_PROJECT= /project PACKAGE 

IF "%3%"=="intel" GOTO INTEL_COMPILER

:NOT_INTEL_COMPILER
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% -DWITH_IPP:BOOL=FALSE -DWITH_LAPACK:BOOL=FALSE 
GOTO VISUAL_STUDIO

:INTEL_COMPILER
REM Find Intel Compiler 
SET INTEL_DIR=%ICPP_COMPILER17%bin
SET INTEL_ENV=%INTEL_DIR%\iclvars.bat
SET INTEL_ICL=%INTEL_DIR%\ia32\icl.exe
IF "%OS_MODE%"==" Win64" SET INTEL_ICL=%INTEL_DIR%\intel64\icl.exe
SET INTEL_TBB=%ICPP_COMPILER17%tbb\include

SET TBB_ARCH=ia32
IF "%OS_MODE%"==" Win64" SET TBB_ARCH=intel64
SET TBB_DEV_ENV=""
IF %DEVENV%==%VS2012% SET TBB_DEV_ENV=vs2012
IF %DEVENV%==%VS2013% SET TBB_DEV_ENV=vs2013
IF %DEVENV%==%VS2015% SET TBB_DEV_ENV=vs2015
call "%ICPP_COMPILER17%tbb\bin\tbbvars.bat" %TBB_ARCH% %TBB_DEV_ENV%

REM initiate the compiler enviroment
@echo on

IF EXIST "%INTEL_DIR%" SET IPP_BUILD_FLAGS=-DWITH_IPP:BOOL=TRUE
IF EXIST "%INTEL_DIR%" SET CMAKE_CONF_FLAGS=^
-DWITH_TBB:BOOL=TRUE ^
-DTBB_INCLUDE_DIR:String="%INTEL_TBB:\=/%" ^
-DCV_ICC:BOOL=TRUE ^
%CMAKE_CONF_FLAGS%

REM IF NOT "%2%"=="gpu" GOTO END_OF_INTEL_GPU
REM SET CUDA_HOST_COMPILER=%VS110COMNTOOLS%..\..\VC\bin
REM IF "%OS_MODE%"==" Win64" SET CUDA_HOST_COMPILER=%CUDA_HOST_COMPILER%\amd64
REM IF EXIST %VS2012% SET CMAKE_CONF_FLAGS=-DCUDA_HOST_COMPILER:String="%CUDA_HOST_COMPILER%" %CMAKE_CONF_FLAGS%
REM IF "%OS_MODE%"==" Win64" SET CMAKE_CONF_FLAGS=-DCUDA_64_BIT_DEVICE_CODE:BOOL=ON %CMAKE_CONF_FLAGS%
REM :END_OF_INTEL_GPU

SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DWITH_OPENCL:BOOL=TRUE ^
-DWITH_MSMF:BOOL=TRUE

SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% %IPP_BUILD_FLAGS% -DWITH_OPENCL:BOOL=TRUE 

GOTO RUN_CMAKE

:VISUAL_STUDIO

SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% %IPP_BUILD_FLAGS% 
 
IF "%3%"=="WindowsStore81" GOTO CONFIGURE_WINDOWS_STORE_81
IF "%3%"=="WindowsStore10" GOTO CONFIGURE_WINDOWS_STORE_10
IF "%3%"=="WindowsPhone81" GOTO CONFIGURE_WINDOWS_PHONE_81

REM Windows Desktop Build

SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DWITH_OPENCL:BOOL=TRUE ^
-DWITH_MSMF:BOOL=TRUE
GOTO RUN_CMAKE

:CONFIGURE_WINDOWS_STORE_81
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% -DCMAKE_SYSTEM_NAME:String="WindowsStore" -DCMAKE_SYSTEM_VERSION:String="8.1"
GOTO CONFIGURE_WINDOWS_STORE_OR_PHONE

:CONFIGURE_WINDOWS_STORE_10
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% -DCMAKE_SYSTEM_NAME:String="WindowsStore" -DCMAKE_SYSTEM_VERSION:String="10.0.14393.0"
GOTO CONFIGURE_WINDOWS_STORE_OR_PHONE

:CONFIGURE_WINDOWS_PHONE_81
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% -DCMAKE_SYSTEM_NAME:String="WindowsPhone"  -DCMAKE_SYSTEM_VERSION:String="8.1" 
GOTO CONFIGURE_WINDOWS_STORE_OR_PHONE

:CONFIGURE_WINDOWS_STORE_OR_PHONE
SET CMAKE_CONF_FLAGS=%CMAKE_CONF_FLAGS% ^
-DNETFX_CORE:BOOL=TRUE ^
-DWITH_DIRECTX:BOOL=FALSE ^
-DWITH_OPENEXR:BOOL=FALSE ^
-DWITH_TIFF:BOOL=TRUE ^
-DEMGU_CV_WITH_TIFF:BOOL=FALSE ^
-DWITH_PNG:BOOL=TRUE ^
-DWITH_WEBP:BOOL=TRUE ^
-DWITH_DSHOW:BOOL=FALSE ^
-DWITH_WIN32UI:BOOL=FALSE ^
-DWITH_VFW:BOOL=FALSE ^
-DWITH_MSMF:BOOL=FALSE ^
-DWITH_FFMPEG:BOOL=FALSE ^
-DWITH_OPENCL:BOOL=FALSE ^
-DEMGU_ENABLE_SSE:BOOL=FALSE 
GOTO RUN_CMAKE

@echo on
:RUN_CMAKE
%CMAKE% %CMAKE_CONF_FLAGS% ..\

:BUILD
IF NOT "%7%"=="build" GOTO END

call %DEVENV% %BUILD_TYPE% emgucv.sln %BUILD_PROJECT% 
IF "%5%"=="htmldoc" ^
call %DEVENV% %BUILD_TYPE% emgucv.sln /project Emgu.CV.Document.Html 

IF "%8%"=="nuget" ^
call %DEVENV% %BUILD_TYPE% emgucv.sln /project Emgu.CV.nuget 

:END
popd