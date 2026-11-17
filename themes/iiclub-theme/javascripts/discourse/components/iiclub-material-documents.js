import Component from "@ember/component";
import { action } from "@ember/object";

export default class IiclubMaterialDocuments extends Component {
  uploads = [];

  get categorizedDocuments() {
    const list = this.uploads || [];
    return list.map((item) => {
      const name = item.original_filename || "";
      const ext = name.split(".").pop().toLowerCase();

      let kind = "document";
      let isReadable = ["md", "pdf", "epub", "fb2"].includes(ext);

      if (/расшифров|транскрип|transcript/i.test(name) || /\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}/.test(name)) {
        kind = "transcript";
      } else if (/методичк/i.test(name)) {
        kind = "handbook";
      }

      return {
        ...item,
        kind,
        isReadable,
        label: kind === "transcript" ? "Расшифровка эфира" : (kind === "handbook" ? "Методичка" : "Материал"),
        readerUrl: `/club/reader?upload_id=${item.id}&format=${ext}`
      };
    });
  }

  @action
  openReader(doc) {
    window.open(doc.readerUrl, "_blank");
  }
}

