import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ["query", "results"];

  connect() {
    this.debounceTimer = null;
  }

  search() {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      const query = this.queryTarget.value.trim();
      if (query.length < 2) {
        this.resultsTarget.innerHTML = "";
        return;
      }

      fetch(`/records/search?query=${encodeURIComponent(query)}`, {
        headers: {
          Accept: "text/vnd.turbo-stream.html",
        },
      })
        .then((response) => response.text())
        .then((html) => {
          Turbo.renderStreamMessage(html);
        })
        .catch((error) => {
          console.error("Search error:", error);
          this.resultsTarget.innerHTML = `
          <div class="p-4 text-red-500">
            Error searching for albums. Please try again.
          </div>
        `;
        });
    }, 300); // Debounce delay
  }

  selectRelease(event) {
    event.preventDefault();
    const link = event.currentTarget;
    const data = {
      title: link.dataset.title,
      artist: link.dataset.artist,
      year: link.dataset.year,
      coverUrl: link.dataset.coverUrl,
    };

    // Fill in form fields
    this.element.querySelector('[name="record[title]"]').value = data.title;
    this.element.querySelector('[name="record[artist_name]"]').value =
      data.artist;
    this.element.querySelector('[name="record[release_year]"]').value =
      data.year;
    this.element.querySelector('[name="record[cover_art_url]"]').value =
      data.coverUrl;

    // Update the image preview
    const previewImage = this.element.querySelector(
      '[data-image-preview-target="preview"]',
    );
    const placeholder = this.element.querySelector(
      '[data-image-preview-target="placeholder"]',
    );
    if (previewImage && placeholder && data.coverUrl) {
      previewImage.src = data.coverUrl;
      previewImage.classList.remove("hidden");
      placeholder.classList.add("hidden");
    }

    // Clear results
    this.resultsTarget.innerHTML = "";
    this.queryTarget.value = "";
  }
}
