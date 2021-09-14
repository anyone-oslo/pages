import { Controller } from "stimulus";

export default class MainController extends Controller {
  static get targets() {
    return ["tab", "link"];
  }

  connect() {
    let tabs = this.tabNames();
    if (tabs.length > 0) {
      let initTab = null;
      const tabExpression = /#(.*)$/;

      if (document.location.toString().match(tabExpression)) {
        let id = document.location.toString().match(tabExpression)[1];
        if (tabs.indexOf(id) !== -1) {
          initTab = id;
        }
      }

      this.showTab(initTab || tabs[0]);
    }

    window.addEventListener("popstate", this.stateHandler.bind(this));
  }

  disconnect() {
    window.removeEventListener("popstate", this.stateHandler.bind(this));
  }

  stateHandler(evt) {
    if (evt.state && evt.state.tabId) {
      this.showTab(evt.state.tabId);
    }
  }

  changeTab(evt) {
    evt.preventDefault();
    const tab = evt.target.dataset.tab;
    this.showTab(tab);
    history.pushState({ tabId: tab }, "", `${window.location.pathname}#${tab}`);
  }

  showTab(tab) {
    this.linkTargets.forEach((l) => {
      if (l.dataset.tab == tab) {
        l.classList.add("current");
      } else {
        l.classList.remove("current");
      }
    });

    this.tabTargets.forEach((t) => {
      if (t.dataset.tab == tab) {
        t.classList.remove("hidden");
      } else {
        t.classList.add("hidden");
      }
    });
  }

  tabNames () {
    return this.linkTargets.map((l) => l.dataset.tab);
  }
}
