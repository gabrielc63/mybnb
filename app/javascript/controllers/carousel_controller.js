import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "item"];
  static values = { index: Number };

  connect() {
    this.indexValue = 0;
    this.showCurrentItem();
  }

  next(event) {
    event.preventDefault();
    event.stopPropagation();
    this.indexValue = (this.indexValue + 1) % this.itemTargets.length;
    this.showCurrentItem();
  }

  previous(event) {
    event.preventDefault();
    event.stopPropagation();
    this.indexValue =
      (this.indexValue - 1 + this.itemTargets.length) % this.itemTargets.length;
    this.showCurrentItem();
  }

  showCurrentItem() {
    this.containerTarget.scrollTo({
      left: this.itemTargets[this.indexValue].offsetLeft,
      behavior: "smooth",
    });
  }
}
