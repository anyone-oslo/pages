import { Controller } from "@hotwired/stimulus";

export default class EditPageController extends Controller {
  static get targets() {
    return ["form"];
  }

  preview() {
    const form = this.formTarget;
    const prevAction = form.action;
    const prevTarget = form.target;

    form.target = "_blank";
    form.action = form.dataset.previewUrl;
    form.submit();

    form.action = prevAction;
    form.target = prevTarget;
  }
}
