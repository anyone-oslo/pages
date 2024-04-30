function ready(callback: () => void) {
  if (document.readyState !== "loading") {
    callback();
  } else {
    document.addEventListener("DOMContentLoaded", callback);
  }
}

function applyGrid() {
  let showGrid = false;
  const gridOverlay = document.querySelector(".grid-overlay");

  const setState = (newState: boolean) => {
    showGrid = newState;

    if (newState) {
      window.localStorage.setItem("showGrid", "true");
      gridOverlay.classList.add("grid-overlay--active");
    } else {
      window.localStorage.removeItem("showGrid");
      gridOverlay.classList.remove("grid-overlay--active");
    }
  };

  if (gridOverlay) {
    setState(window.localStorage.getItem("showGrid") == "true");

    // Keyboard toggle
    document.addEventListener("keyup", (evt: KeyboardEvent) => {
      if (evt.ctrlKey && evt.which == 71) {
        setState(!showGrid);
      }
    });
  }
}

export default function gridOverlay() {
  ready(applyGrid);
}
