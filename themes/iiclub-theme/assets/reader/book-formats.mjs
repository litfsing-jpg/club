/**
 * book-formats.mjs — Клиентский парсер и рендерер форматов MD, FB2, EPUB
 */

export class BookFormatsParser {
  static parseMarkdown(rawText) {
    const lines = rawText.split("\n");
    let html = "";
    let blockIndex = 0;

    lines.forEach(line => {
      const trimmed = line.trim();
      if (!trimmed) return;

      blockIndex++;
      if (trimmed.startsWith("# ")) {
        html += `<h1 data-block-index="${blockIndex}">${trimmed.slice(2)}</h1>`;
      } else if (trimmed.startsWith("## ")) {
        html += `<h2 data-block-index="${blockIndex}">${trimmed.slice(3)}</h2>`;
      } else if (trimmed.startsWith("### ")) {
        html += `<h3 data-block-index="${blockIndex}">${trimmed.slice(4)}</h3>`;
      } else {
        html += `<p data-block-index="${blockIndex}">${trimmed}</p>`;
      }
    });

    return { html, totalBlocks: blockIndex };
  }

  static parseFB2(xmlString) {
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xmlString, "text/xml");
    const paragraphs = xmlDoc.querySelectorAll("body p");
    let html = "";
    let blockIndex = 0;

    paragraphs.forEach(p => {
      blockIndex++;
      html += `<p data-block-index="${blockIndex}">${p.textContent}</p>`;
    });

    return { html, totalBlocks: blockIndex };
  }
}

