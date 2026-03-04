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
        processed\      <- Originals are moved here after processing
    PDF_COMPRIMIDO\     <- Compressed output files are saved here
```

These folders are created automatically the first time the script runs. You do not need to create them manually.

---

## How to Use

1. **Run the script** by double-clicking `compressor.bat` or opening it from a Command Prompt window.

2. **Select a compression level** when prompted:

   ```
    ============================================================
     PDF Compressor
    ============================================================

     Input  : C:\COMPRIMIR_PDF\ORIGINAL
     Output : C:\COMPRIMIR_PDF\PDF_COMPRIMIDO

     Select compression level:
     1 - Normal  (/ebook,  150 DPI)  | Best balance
     2 - High    (/screen, 100 DPI)  | Smaller size
     3 - Ultra   (/screen,  50 DPI)  | Maximum compression

     Option [1-3]:
   ```

   Type `1`, `2`, or `3` and press Enter.

3. **Drop PDF files** into `C:\COMPRIMIR_PDF\ORIGINAL\`. The script monitors that folder continuously and processes any `.pdf` file it finds.

4. **Retrieve the compressed files** from `C:\COMPRIMIR_PDF\PDF_COMPRIMIDO\`. Each output file is named `<original_name>_compressed.pdf`.

5. **Stop the script** by pressing `Ctrl+C` in the Command Prompt window.

> The script checks the watch folder every 5 seconds. There may be a short delay between dropping a file and seeing it processed.

---

## Output Example

```
  [10:00:52.51] document.pdf  (5497 KB)
  Compressing... done.
  [OK]   5497 KB --> 1280 KB  (76% saved)

  [10:00:58.14] report.pdf  (2100 KB)
  Compressing... done.
  [WARN] Compressed file is larger -- keeping original copy.
```

The `[WARN]` message appears when Ghostscript cannot reduce the file further (e.g. already compressed or text-only PDFs). In that case, the original is copied to the output folder unchanged so you always get a file in the output.

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
- Displays the input/output paths and presents the compression level menu.

### Processing Loop

After the level is selected, the script enters an infinite loop:

1. It scans `C:\COMPRIMIR_PDF\ORIGINAL\` for any file matching `*.pdf`.
2. For each file found, it prints the filename, original size in KB, and calls `gswin64c` with the following Ghostscript parameters:

   | Parameter | Value | Purpose |
   |-----------|-------|---------|
   | `-sDEVICE` | `pdfwrite` | Write output as a PDF file |
   | `-dCompatibilityLevel` | `1.5` | Output compatible with Acrobat 6 and later |
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

3. After compression, the script compares the output file size to the original:
   - If the compressed file is **smaller**, it reports the size reduction percentage.
   - If the compressed file is **larger or equal**, the original is copied to the output folder instead, and a `[WARN]` message is shown.
4. The original file is moved to `C:\COMPRIMIR_PDF\ORIGINAL\processed\` to prevent it from being processed again.
5. The script waits 5 seconds and then repeats from step 1.

### Archiving

Moving the original to `processed\` serves two purposes: it keeps the watch folder clean, and it preserves the original file in case you need to compare results or reprocess at a different quality level.

---

## Notes and Limitations

- The compression level is fixed for the entire session. To change levels, stop and restart the script.
- Only files placed directly inside `C:\COMPRIMIR_PDF\ORIGINAL\` are processed. Subfolders (including `processed\`) are not scanned.
- Very small PDFs (text-only documents with no images) may not be reduced significantly, as the main gains come from downsampling embedded images. These will trigger the `[WARN]` message and the original will be copied to the output as-is.
- Ensure `gswin64c` is in your system `PATH` before starting. The script does not check for Ghostscript at startup.
- The folder paths (`C:\COMPRIMIR_PDF\ORIGINAL` and `C:\COMPRIMIR_PDF\PDF_COMPRIMIDO`) are hardcoded. To change them, open `compressor.bat` in a text editor and update the `INPUT_FOLDER` and `OUTPUT_FOLDER` variables near the top of the file.
