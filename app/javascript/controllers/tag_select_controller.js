import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  static values = {
    maxItems: Number,
  };

  connect() {
    this.tomSelect = new TomSelect(this.element, {
      plugins: ["remove_button"],
      persist: false,
      createOnBlur: true,
      create: true,
      maxItems: this.maxItemsValue || 3,
      valueField: "id",
      labelField: "name",
      searchField: "name",
      placeholder: "Add genres...",
      load: (query, callback) => {
        const url = `/genres/search?query=${encodeURIComponent(query)}`;
        fetch(url)
          .then((response) => response.json())
          .then((json) => {
            callback(json);
          })
          .catch(() => {
            callback();
          });
      },
      render: {
        item: function (data, escape) {
          return `<div class="record-tag flex items-center">
            ${escape(data.text || data.name)}
            <span class="remove ml-2 cursor-pointer">×</span>
          </div>`;
        },
        option: function (data, escape) {
          return `<div class="px-3 py-2 hover:bg-dark-600">
            ${escape(data.text || data.name)}
          </div>`;
        },
        option_create: function (data, escape) {
          return (
            '<div class="create px-3 py-2 text-yellow-500">Add <strong>' +
            escape(data.input) +
            "</strong>&hellip;</div>"
          );
        },
        no_results: function (_data, _escape) {
          return '<div class="px-3 py-2 text-gray-400">Start typing to create a new genre...</div>';
        },
      },
      // Styling
      controlClass:
        "block w-full rounded-lg bg-dark-700 border-dark-600 min-h-[42px] p-2",
      dropdownClass:
        "ts-dropdown bg-dark-700 border border-dark-600 rounded-lg mt-1",
      dropdownContentClass: "text-white",
      inputClass:
        "text-white bg-transparent border-0 p-1.5 min-w-[180px] placeholder-gray-400",
      itemClass: "inline-flex mr-1",
      removeButtonClass: "hover:text-red-500 ml-1",
    });
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy();
    }
  }
}
