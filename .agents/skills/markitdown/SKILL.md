---
name: markitdown
description: "Converts diverse file formats (PDF, DOCX, PPTX, XLSX, XLS, HTML, CSV, JSON, XML, ZIP, EPUB, IPYNB, Audio, Images/EXIF) into clean Markdown. Automatically invoke whenever the user or agent needs to extract, read, analyze, convert, or process content from non-markdown documents or office files."
---

# MarkItDown

A specialized skill for converting office documents, PDFs, presentations, spreadsheets, audio, and media files into clean, readable Markdown using Microsoft's MarkItDown engine.

## Supported Formats

- **Documents**: PDF (`.pdf`), Word (`.docx`)
- **Spreadsheets**: Excel (`.xlsx`, `.xls`), CSV (`.csv`), TSV (`.tsv`)
- **Presentations**: PowerPoint (`.pptx`)
- **Web & Feeds**: HTML (`.html`, `.htm`), RSS/Atom feeds, Wikipedia pages, Bing search results
- **Code & Notebooks**: Jupyter Notebooks (`.ipynb`), JSON (`.json`), XML (`.xml`)
- **Archives & E-Books**: ZIP files (`.zip`), EPUB (`.epub`)
- **Audio & Media**: Audio transcription (`.mp3`, `.wav`, etc.), Image metadata/EXIF

---

## When to Automatically Activate

1. **Extracting content from documents**: When user asks to read, analyze, summarize, or extract text/tables from PDF, DOCX, XLSX, PPTX, or other supported file formats.
2. **File Conversion**: When the user requests converting any file into Markdown.
3. **Data Ingestion**: When ingesting multi-modal documents into project documentation or agent context.

---

## Usage Instructions

### 1. Command Line Execution

To convert a file directly to markdown or save to an output file:

```bash
# Convert file and print to stdout
markitdown path/to/document.pdf

# Convert file and save to markdown file
markitdown path/to/document.docx -o output.md
```

### 2. Python API

To convert files programmatically within Python scripts:

```python
from markitdown import MarkItDown

md = MarkItDown()
result = md.convert("path/to/file.xlsx")
print(result.text_content)
```

### 3. Converting with Custom LLM / Vision Enhancements

```python
from markitdown import MarkItDown
# MarkItDown supports optional OpenAI or Azure OpenAI client for image description / captions
md = MarkItDown()
result = md.convert("path/to/file_with_images.pptx")
```

---

## Verification & Best Practices

1. Verify that `markitdown` is installed:
   ```bash
   pip3 show markitdown
   ```
2. When parsing tables from Excel or CSV, MarkItDown formats tables into GitHub Flavored Markdown (GFM) tables automatically.
3. For large PDFs or complex multi-sheet spreadsheets, verify the converted text output before presenting findings.
