import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Sort controller connected to:", this.element);
  }

  execute(event) {
    console.log("Sort execute called", event.target.value);
    console.log("Event:", event);

    const sortValue = event.target.value;
    if (!sortValue) return;

    const [field, direction] = sortValue.split("_");
    const url = new URL(window.location);
    url.searchParams.set("sort", field);
    url.searchParams.set("direction", direction);

    console.log("Fetching URL:", url.toString());

    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "Turbo-Frame": "records",
      },
    })
      .then((response) => {
        if (!response.ok) throw new Error("Network response was not ok");
        return response.text();
      })
      .then((html) => {
        console.log("Received response:", html);
        Turbo.renderStreamMessage(html);
      })
      .catch((error) => {
        console.error("Sort error:", error);
      });
  }
}
