import { Controller } from "@hotwired/stimulus";

export default class SearchController extends Controller {
  static targets = ["form", "results"];

  submit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, 300);
  }
}
