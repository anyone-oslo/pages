import { Controller } from "@hotwired/stimulus";

export default class PageOptionsController extends Controller {
  static get targets() {
    return ["advancedOptions", "autoPublishNotice", "published", "publishedDate"];
  }

  connect() {
    this.checkAutoPublish();
    this.checkPublishedDate();
  }

  checkAutoPublish() {
    if (this.publishedDate() > new Date()) {
      this.show(this.autoPublishNoticeTarget);
    } else {
      this.hide(this.autoPublishNoticeTarget);
    }
  }

  checkPublishedDate() {
    if (this.publishedTarget.value == 2) {
      this.show(this.publishedDateTarget);
    } else {
      this.hide(this.publishedDateTarget);
    }
  }

  publishedDate() {
    const lookup = (name) => {
      return this.publishedDateTarget.getElementsByClassName(name)[0].value;
    };
    return new Date(
      lookup("year"),
      (lookup("month") - 1),
      lookup("day"),
      lookup("hour"),
      lookup("minute")
    );
  }

  show(elem) {
    elem.classList.add("show");
  }

  hide(elem) {
    elem.classList.remove("show");
  }

  toggle(elem) {
    if (elem.classList.contains("show")) {
      this.hide(elem);
    } else {
      this.show(elem);
    }
  }

  toggleAdvancedOptions(evt) {
    evt.preventDefault();
    this.toggle(this.advancedOptionsTarget);
  }
}
