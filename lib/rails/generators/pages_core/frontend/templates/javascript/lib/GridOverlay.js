class GridOverlay {
  constructor() {
    this.gridOverlay = null;
    this.showGrid = false;
    this.init = this.init.bind(this);
  }

  bindHotkey() {
    document.addEventListener("keyup", (evt) => {
      if (evt.ctrlKey && evt.which == 71) {
        this.toggle();
      }
    });
  }

  init() {
    this.gridOverlay = document.querySelector(".grid-overlay");
    if (this.gridOverlay) {
      this.restoreState();
      this.bindHotkey();
      this.updateDOM();
    }
  }

  ready(callback) {
    if (document.readyState === "complete" ||
        (document.readyState !== "loading" &&
         !document.documentElement.doScroll)) {
      callback();
    } else {
      document.addEventListener("DOMContentLoaded", callback);
    }
  }

  restoreState() {
    this.showGrid = window.localStorage.getItem("showGrid");
  }

  saveState() {
    if (this.showGrid) {
      window.localStorage.setItem("showGrid", "true");
    } else {
      window.localStorage.removeItem("showGrid");
    }
  }

  start() {
    this.ready(this.init);
  }

  toggle() {
    this.showGrid = !this.showGrid;
    this.saveState();
    this.updateDOM();
  }

  updateDOM() {
    if (this.showGrid) {
      this.gridOverlay.classList.add("grid-overlay--active");
    } else {
      this.gridOverlay.classList.remove("grid-overlay--active");
    }
  }
}

export default new GridOverlay();
