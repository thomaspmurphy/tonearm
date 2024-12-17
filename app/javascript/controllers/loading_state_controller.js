import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "loadingState"];

  connect() {
    this.element.addEventListener(
      "turbo:submit-start",
      this.showLoading.bind(this),
    );
    this.element.addEventListener(
      "turbo:submit-end",
      this.hideLoading.bind(this),
    );
  }

  disconnect() {
    this.element.removeEventListener(
      "turbo:submit-start",
      this.showLoading.bind(this),
    );
    this.element.removeEventListener(
      "turbo:submit-end",
      this.hideLoading.bind(this),
    );
  }

  showLoading() {
    this.buttonTarget.classList.add("hidden");
    this.loadingStateTarget.classList.remove("hidden");
    this.loadingStateTarget.classList.add("flex");
  }

  hideLoading() {
    this.buttonTarget.classList.remove("hidden");
    this.loadingStateTarget.classList.add("hidden");
    this.loadingStateTarget.classList.remove("flex");
  }
}
