import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";

export default class IiclubMaterialLibrary extends Component {
  @service currentUser;

  postId = null;
  videoId = null;
  videoUrl = null;
  videoTitle = null;
  duration = 0;
  currentPosition = 0;
  iframeHeight = 480;

  init() {
    super.init(...arguments);
    this._loadSavedPosition();
    this._bindPostMessageListener();
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    if (this._onMessageBound) {
      window.removeEventListener("message", this._onMessageBound);
    }
  }

  get resumeButtonLabel() {
    if (this.currentPosition >= 5) {
      const minutes = Math.floor(this.currentPosition / 60);
      const seconds = Math.floor(this.currentPosition % 60);
      const mm = String(minutes).padStart(2, "0");
      const ss = String(seconds).padStart(2, "0");
      return `Продолжить с ${mm}:${ss}`;
    }
    return "Смотреть";
  }

  get embedUrl() {
    if (this.videoUrl) {
      // Поддержка внешних платформ
      if (this.videoUrl.includes("disk.yandex")) {
        return `https://disk.yandex.ru/i/${this.videoId || ""}?embed=1`;
      }
      if (this.videoUrl.includes("zoom.us")) {
        return this.videoUrl;
      }
    }
    return `/club/watch/${this.postId}/${this.videoId}?embed=1`;
  }

  _loadSavedPosition() {
    const key = `club-video-playback:${this.postId}:${this.videoId}`;
    const saved = localStorage.getItem(key);
    if (saved) {
      try {
        const data = JSON.parse(saved);
        this.set("currentPosition", data.position || 0);
        this.set("duration", data.duration || 0);
      } catch (e) {
        // ignore
      }
    }
  }

  _bindPostMessageListener() {
    this._onMessageBound = (event) => {
      if (!event.data || typeof event.data !== "object") return;

      // Обработка ресайза фрейма
      if (event.data.type === "club-video-resize" && event.data.height) {
        const h = Math.max(240, Math.min(1400, Number(event.data.height)));
        this.set("iframeHeight", h);
        window.dispatchEvent(new CustomEvent("iiclub:recording-player-resized", { detail: { height: h } }));
      }

      // Обработка сохранения таймкода
      if (event.data.type === "club-video-progress") {
        const pos = Number(event.data.position || 0);
        const dur = Number(event.data.duration || 0);
        this.set("currentPosition", pos);
        this.set("duration", dur);

        const key = `club-video-playback:${this.postId}:${this.videoId}`;
        localStorage.setItem(key, JSON.stringify({
          position: pos,
          duration: dur,
          updatedAt: Date.now()
        }));
      }
    };

    window.addEventListener("message", this._onMessageBound);
  }

  @action
  resumePlayback() {
    const iframe = this.element.querySelector("iframe");
    if (iframe && iframe.contentWindow) {
      iframe.contentWindow.postMessage({
        type: "seek-to",
        position: this.currentPosition
      }, "*");
    }
  }
}

