/**
 * reading.mjs — Двухуровневая система закладок и трекинг дочитывания
 */

export class ClubReadingTracker {
  constructor({ userId, issueKey, uploadId, csrfToken }) {
    this.userId = userId;
    this.issueKey = issueKey;
    this.uploadId = uploadId;
    this.csrfToken = csrfToken;
    this.storageKey = `club-journal-reading:${userId}:${issueKey}`;
    this.bookmarks = [];
    this.progress = 0;
    this._loadLocalState();
  }

  _loadLocalState() {
    try {
      const data = JSON.parse(localStorage.getItem(this.storageKey) || "{}");
      this.bookmarks = data.bookmarks || [];
      this.progress = data.progress || 0;
    } catch (e) {
      this.bookmarks = [];
      this.progress = 0;
    }
  }

  saveBookmark({ page, chapter, block, offset, progress, zoom, anchor, textSnippet }) {
    const bookmark = {
      id: "bm_" + Date.now(),
      page: Number(page) || 1,
      chapter: chapter || "",
      block: block || 0,
      offset: offset || 0,
      progress: Math.min(100, Math.max(0, Math.round(progress || 0))),
      zoom: zoom || 1.0,
      anchor: anchor || "",
      textSnippet: (textSnippet || "").slice(0, 150),
      createdAt: new Date().toISOString()
    };

    this.bookmarks.push(bookmark);
    this._persistLocally();
    this._syncToServer(bookmark);
    return bookmark;
  }

  removeBookmark(bookmarkId) {
    this.bookmarks = this.bookmarks.filter(b => b.id !== bookmarkId);
    this._persistLocally();
  }

  updateProgress(percent) {
    this.progress = Math.min(100, Math.max(0, Math.round(percent)));
    this._persistLocally();
  }

  _persistLocally() {
    const payload = {
      progress: this.progress,
      bookmarks: this.bookmarks,
      updatedAt: Date.now()
    };
    localStorage.setItem(this.storageKey, JSON.stringify(payload));
  }

  async _syncToServer(bookmark) {
    if (!this.uploadId) return;

    try {
      await fetch(`/forum/club/reading/${this.uploadId}.json`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken || ""
        },
        body: JSON.stringify({
          bookmark,
          progress: this.progress
        })
      });
    } catch (err) {
      console.warn("[ClubReading] Sync to server deferred:", err);
    }
  }

  observeReading(containerElement) {
    if (!containerElement) return;

    let dwellTimer = null;
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && document.hasFocus() && document.visibilityState === "visible") {
          clearTimeout(dwellTimer);
          dwellTimer = setTimeout(() => {
            const blockIndex = Number(entry.target.dataset.blockIndex || 0);
            const totalBlocks = Number(containerElement.dataset.totalBlocks || 1);
            const calcPercent = (blockIndex / totalBlocks) * 100;
            if (calcPercent > this.progress) {
              this.updateProgress(calcPercent);
            }
          }, 1000); // Dwell time 1 сек
        }
      });
    }, { threshold: 0.5 });

    containerElement.querySelectorAll("[data-block-index]").forEach(el => observer.observe(el));
  }
}
