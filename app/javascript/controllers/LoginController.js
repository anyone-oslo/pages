import { Controller } from "stimulus";

export default class LoginController extends Controller {
  static get targets() {
    return ["tab"];
  }

  connect() {
    if (this.tabTargets.length > 0) {
      this.showTab(this.tabTargets[0].dataset.tab);
    }
  }


  changeTab(evt) {
    evt.preventDefault();
    this.showTab(evt.target.dataset.tab);
  }

  showTab(tab) {
    this.tabTargets.forEach((t) => {
      if (t.dataset.tab == tab) {
        t.classList.remove("hidden");
      } else {
        t.classList.add("hidden");
      }
    });
  }
}
