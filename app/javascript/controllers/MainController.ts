import { Controller } from "@hotwired/stimulus";

interface WindowState {
  tabId: string;
}

export default class MainController extends Controller {
  declare readonly linkTargets: HTMLLinkElement[];
  declare readonly tabTargets: HTMLDivElement[];

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

  stateHandler = (evt: PopStateEvent) => {
    if (evt.state && "tabId" in evt.state) {
      const { tabId } = evt.state as WindowState;
      this.showTab(tabId);
    }
  };

  changeTab(evt: Event) {
    evt.preventDefault();
    const link = evt.target as HTMLAnchorElement;
    if ("tab" in link.dataset) {
      const tab = link.dataset.tab;
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
