import { Controller } from "@hotwired/stimulus";

export default class LoginController extends Controller {
  declare readonly tabTargets: HTMLDivElement[];

  static get targets() {
    return ["tab"];
  }

  connect() {
    if (this.tabTargets.length > 0) {
      this.showTab(this.tabTargets[0].dataset.tab);
    }
  }

  changeTab(evt: Event) {
    evt.preventDefault();
    if ("dataset" in evt.target && "tab" in evt.target.dataset) {
      this.showTab(evt.target.dataset.tab);
    }
  }

  showTab(tab: string) {
    this.tabTargets.forEach((t) => {
      if (t.dataset.tab == tab) {
        t.classList.remove("hidden");
      } else {
        t.classList.add("hidden");
      }
    });
  }
}
