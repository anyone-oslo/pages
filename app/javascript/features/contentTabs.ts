import readyHandler from "../lib/readyHandler";

type WindowState = {
  tabId: string;
};

function applyTabs() {
  const tabLinks: HTMLAnchorElement[] = Array.from(
    document.querySelectorAll(".content-tabs li a")
  );
  const tabs: HTMLDivElement[] = Array.from(
    document.querySelectorAll(".content-tab")
  );

  const showTab = (tab: string | null) => {
    tabLinks.forEach((l) => {
      const parent = l.parentNode as HTMLUListElement | null;
      if (parent) {
        if (l.dataset.tab == tab) {
          parent.classList.add("current");
        } else {
          parent.classList.remove("current");
        }
      }
    });

    tabs.forEach((t) => {
      if (t.dataset.tab == tab) {
        t.classList.remove("hidden");
      } else {
        t.classList.add("hidden");
      }
    });
  };

  const changeTab = (evt: MouseEvent) => {
    evt.preventDefault();
    const link = evt.target as HTMLAnchorElement;
    if ("tab" in link.dataset) {
      const tab = link.dataset.tab;
      showTab(tab);
      history.pushState(
        { tabId: tab },
        "",
        `${window.location.pathname}#${tab}`
      );
    }
  };

  const stateHandler = (evt: PopStateEvent) => {
    if (evt.state && "tabId" in evt.state) {
      const { tabId } = evt.state as WindowState;
      showTab(tabId);
    }
  };

  if (tabLinks.length > 0 && tabs.length > 0) {
    const tabNames = tabs.map((t) => t.dataset.tab);

    tabLinks.forEach((l) => l.addEventListener("click", changeTab));

    let initTab: string = null;
    const tabExpression = /#(.*)$/;

    if (document.location.toString().match(tabExpression)) {
      const id = document.location.toString().match(tabExpression)[1];
      if (tabNames.indexOf(id) !== -1) {
        initTab = id;
      }
    }

    showTab(initTab || tabs[0].dataset.tab);
    window.addEventListener("popstate", stateHandler);
  }
}

export default function contentTabs() {
  readyHandler.ready(applyTabs);
}
