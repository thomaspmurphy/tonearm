import { fontFamily as _fontFamily } from "tailwindcss/defaultTheme";

export const content = [
  "./public/*.html",
  "./app/helpers/**/*.rb",
  "./app/javascript/**/*.js",
  "./app/views/**/*.{erb,haml,html,slim}",
  "./app/components/**/*.{erb,haml,html,slim,rb}",
];
export const theme = {
  extend: {
    fontFamily: {
      sans: ["Inter var", ..._fontFamily.sans],
    },
    colors: {
      dark: {
        50: "#f8f9fa",
        100: "#e9ecef",
        200: "#dee2e6",
        300: "#ced4da",
        400: "#adb5bd",
        500: "#6c757d",
        600: "#495057",
        700: "#343a40",
        800: "#212529",
        900: "#1a1e21",
      },
    },
  },
};
export const plugins = [
  require("@tailwindcss/forms")({
    strategy: "class",
  }),
  require("@tailwindcss/typography"),
  require("@tailwindcss/container-queries"),
];
export const darkMode = "class";
