# PDF Compressor

A Windows batch script that automatically monitors a folder and compresses PDF files using Ghostscript. Files are processed as they are dropped into the watch folder, and the originals are moved to an archive subfolder after compression.

---

## License

This project is released into the public domain. You are free to use, modify, and distribute it without restriction.

---

## Requirements

- **Operating System:** Windows 7 or later
- **Ghostscript:** The script relies on `gswin64c.exe` (the 64-bit command-line build of Ghostscript). It must be installed and available in the system `PATH`.

### Installing Ghostscript

1. Download the latest Ghostscript installer from [https://ghostscript.com/releases/gsdnld.html](https://ghostscript.com/releases/gsdnld.html).
2. Run the installer. The default installation path is `C:\Program Files\gs\gsXXX\bin\`.
3. Add that `bin` folder to your system `PATH` environment variable so that `gswin64c` can be called from any terminal.

To verify the installation, open a Command Prompt and run:

```
gswin64c --version
```

If a version number is printed, Ghostscript is correctly installed and available.

---

## Folder Structure

The script works with the following fixed folder layout on your system:

```
C:\COMPRIMIR_PDF\
    ORIGINAL\           <- Drop your PDF files here
        procesados\     <- Originals are moved here after processing
    PDF_COMPRIMIDO\     <- Compressed output files are saved here
```

These folders are created automatically the first time the script runs. You do not need to create them manually.

---

## How to Use

1. **Run the script** by double-clicking `compressor.bat` or opening it from a Command Prompt window.

2. **Select a compression level** when prompted:

   ```
   Selecciona el nivel de compresion:
   1 - Normal (/ebook, resolucion 150 DPI)
   2 - Alta   (/screen, resolucion 100 DPI)
   3 - Ultra  (/screen, resolucion 50 DPI)
   Opcion [1-3]:
   ```

   Type `1`, `2`, or `3` and press Enter.

3. **Drop PDF files** into `C:\COMPRIMIR_PDF\ORIGINAL\`. The script monitors that folder continuously and processes any `.pdf` file it finds.

4. **Retrieve the compressed files** from `C:\COMPRIMIR_PDF\PDF_COMPRIMIDO\`. Each output file is named `<original_name>_comprimido.pdf`.

5. **Stop the script** by pressing `Ctrl+C` in the Command Prompt window.

> The script checks the watch folder every 5 seconds. There may be a short delay between dropping a file and seeing it processed.

---

## Compression Levels

| Option | Ghostscript Setting | Image Resolution | Recommended Use |
|--------|--------------------|-----------------:|-----------------|
| 1 - Normal | `/ebook` | 150 DPI | General documents, readable on screen and printable |
| 2 - High | `/screen` | 100 DPI | Web sharing, email attachments |
| 3 - Ultra | `/screen` | 50 DPI | Maximum size reduction, reading only |

The `/ebook` profile applies moderate compression and is generally the best balance between file size and quality. The `/screen` profile applies aggressive compression intended for on-screen viewing.

---

## How It Works

### Startup

When the script launches, it:
- Defines the paths for the input folder, output folder, and archive subfolder.
- Creates those folders if they do not already exist.
- Presents the compression level menu and waits for user input.

### Processing Loop

After the level is selected, the script enters an infinite loop:

1. It scans `C:\COMPRIMIR_PDF\ORIGINAL\` for any file matching `*.pdf`.
2. For each file found, it calls `gswin64c` with the following Ghostscript parameters:

   | Parameter | Value | Purpose |
   |-----------|-------|---------|
   | `-sDEVICE` | `pdfwrite` | Write output as a PDF file |
   | `-dCompatibilityLevel` | `1.3` | Output compatible with Acrobat 4 and later |
   | `-dPDFSETTINGS` | `/ebook` or `/screen` | Overall quality profile |
   | `-dEmbedAllFonts` | `true` | Embed all fonts to ensure text renders correctly |
   | `-dSubsetFonts` | `true` | Embed only the characters used, reducing size |
   | `-dColorImageDownsampleType` | `/Bicubic` | Use bicubic resampling for color images |
   | `-dColorImageResolution` | 50 / 100 / 150 | Target DPI for color images |
   | `-dGrayImageDownsampleType` | `/Bicubic` | Use bicubic resampling for grayscale images |
   | `-dGrayImageResolution` | 50 / 100 / 150 | Target DPI for grayscale images |
   | `-dMonoImageDownsampleType` | `/Subsample` | Use subsampling for monochrome images |
   | `-dMonoImageResolution` | 50 / 100 / 150 | Target DPI for monochrome images |
   | `-dDetectDuplicateImages` | `true` | Deduplicate identical image resources |
   | `-dCompressFonts` | `true` | Compress embedded font data |
   | `-dAutoRotatePages` | `/None` | Do not auto-rotate pages |
   | `-dNOPAUSE -dQUIET -dBATCH` | — | Run non-interactively without prompts |

3. The compressed output is saved to `C:\COMPRIMIR_PDF\PDF_COMPRIMIDO\` as `<original_name>_comprimido.pdf`.
4. The original file is moved to `C:\COMPRIMIR_PDF\ORIGINAL\procesados\` to prevent it from being processed again.
5. The script waits 5 seconds and then repeats from step 1.

### Archiving

Moving the original to `procesados\` serves two purposes: it keeps the watch folder clean, and it preserves the original file in case you need to compare results or reprocess at a different quality level.

---

## Notes and Limitations

- The compression level is fixed for the entire session. To change levels, stop and restart the script.
- Only files placed directly inside `C:\COMPRIMIR_PDF\ORIGINAL\` are processed. Subfolders (including `procesados\`) are not scanned.
- Very small PDFs (text-only documents with no images) may not be reduced significantly, as the main gains come from downsampling embedded images.
- If Ghostscript is not found, the script will report an error for each file but will continue running. Ensure `gswin64c` is in your system `PATH` before starting.
- The folder paths (`C:\COMPRIMIR_PDF\ORIGINAL` and `C:\COMPRIMIR_PDF\PDF_COMPRIMIDO`) are hardcoded. To change them, open `compressor.bat` in a text editor and update the `CARPETA_ORIGINAL` and `CARPETA_COMPRIMIDA` variables near the top of the file.
