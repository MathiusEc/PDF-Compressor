@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  PDF Compressor
:: ============================================================

set "INPUT_FOLDER=C:\COMPRIMIR_PDF\ORIGINAL"
set "OUTPUT_FOLDER=C:\COMPRIMIR_PDF\PDF_COMPRIMIDO"

:: Create folders if they do not exist
if not exist "%INPUT_FOLDER%"           mkdir "%INPUT_FOLDER%"
if not exist "%OUTPUT_FOLDER%"          mkdir "%OUTPUT_FOLDER%"
if not exist "%INPUT_FOLDER%\processed" mkdir "%INPUT_FOLDER%\processed"

echo.
echo  ============================================================
echo   PDF Compressor
echo  ============================================================
echo.
echo   Input  : %INPUT_FOLDER%
echo   Output : %OUTPUT_FOLDER%
echo.
echo   Select compression level:
echo   1 - Normal  (/ebook,  150 DPI)  ^| Best balance
echo   2 - High    (/screen, 100 DPI)  ^| Smaller size
echo   3 - Ultra   (/screen,  50 DPI)  ^| Maximum compression
echo.
set /p LEVEL=  Option [1-3]: 

if "%LEVEL%"=="1" (
    set "PDFSETTINGS=/ebook"
    set "RES=150"
    set "LEVELNAME=Normal"
) else if "%LEVEL%"=="2" (
    set "PDFSETTINGS=/screen"
    set "RES=100"
    set "LEVELNAME=High"
) else (
    set "PDFSETTINGS=/screen"
    set "RES=50"
    set "LEVELNAME=Ultra"
)

echo.
echo   Profile : !LEVELNAME! ^(!PDFSETTINGS!, !RES! DPI^)
echo   Watching folder for PDF files... Press Ctrl+C to stop.
echo  ------------------------------------------------------------

:: Infinite loop to monitor the folder
:loop
for %%f in ("%INPUT_FOLDER%\*.pdf") do (
    :: Get original size
    for %%s in ("%%f") do set "ORIG_SIZE=%%~zs"
    set /a "ORIG_KB=ORIG_SIZE/1024"

    echo.
    echo   [%time%] %%~nxf  ^(!ORIG_KB! KB^)
    <nul set /p "=  Compressing..."

    :: Compress -- parameters kept identical to the original fast script
    gswin64c -sDEVICE=pdfwrite ^
    -dCompatibilityLevel=1.5 ^
    -dPDFSETTINGS=!PDFSETTINGS! ^
    -dEmbedAllFonts=true ^
    -dSubsetFonts=true ^
    -dColorImageDownsampleType=/Bicubic ^
    -dColorImageResolution=!RES! ^
    -dGrayImageDownsampleType=/Bicubic ^
    -dGrayImageResolution=!RES! ^
    -dMonoImageDownsampleType=/Subsample ^
    -dMonoImageResolution=!RES! ^
    -dDetectDuplicateImages=true ^
    -dCompressFonts=true ^
    -dAutoRotatePages=/None ^
    -dFastWebView=false ^
    -dNOPAUSE -dQUIET -dBATCH ^
    -sOutputFile="%OUTPUT_FOLDER%\%%~nf_compressed.pdf" "%%f"

    :: Compare sizes
    for %%s in ("%OUTPUT_FOLDER%\%%~nf_compressed.pdf") do set "COMP_SIZE=%%~zs"
    set /a "COMP_KB=COMP_SIZE/1024"

    if !COMP_SIZE! GEQ !ORIG_SIZE! (
        echo  done.
        echo   [WARN] Compressed file is larger -- keeping original copy.
        copy "%%f" "%OUTPUT_FOLDER%\%%~nf_compressed.pdf" >nul
    ) else (
        set /a "SAVED=(ORIG_SIZE-COMP_SIZE)*100/ORIG_SIZE"
        echo  done.
        echo   [OK]   !ORIG_KB! KB --^> !COMP_KB! KB  ^(!SAVED!%% saved^)
    )

    move "%%f" "%INPUT_FOLDER%\processed\" >nul
)

timeout /t 5 >nul
goto loop

