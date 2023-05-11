import { Controller } from "@hotwired/stimulus";

export default class MainController extends Controller {
  readonly linkTargets: HTMLLinkElement[];
  readonly tabTargets: HTMLDivElement[];

  static get targets() {
    return ["tab", "link"];
  }

  connect() {
    const tabs = this.tabNames();
    if (tabs.length > 0) {
      let initTab: string = null;
      const tabExpression = /#(.*)$/;

      if (document.location.toString().match(tabExpression)) {
        const id = document.location.toString().match(tabExpression)[1];
        if (tabs.indexOf(id) !== -1) {
          initTab = id;
        }
      }

      this.showTab(initTab || tabs[0]);
    }

    window.addEventListener("popstate", this.stateHandler);
  }

  disconnect() {
    window.removeEventListener("popstate", this.stateHandler);
  }

  stateHandler = (evt: Event) => {
    if ("state" in evt && "tabId" in evt.state) {
      this.showTab(evt.state.tabId);
    }
  };

  changeTab(evt: Event) {
    evt.preventDefault();
    if ("dataset" in evt.target && "tab" in evt.target.dataset) {
      const tab = evt.target.dataset.tab as string;
      this.showTab(tab);
      history.pushState(
        { tabId: tab },
        "",
        `${window.location.pathname}#${tab}`
      );
    }
  }

  showTab(tab: string | null) {
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

  tabNames(): string[] {
    return this.linkTargets.map((l) => l.dataset.tab);
  }
}
