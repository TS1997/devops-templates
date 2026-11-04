import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [tailwindcss()],
  build: {
    assetsDir: ".",
    copyPublicDir: false,
    cssCodeSplit: true,
    emptyOutDir: true,
    manifest: false,
    minify: true,
    outDir: "resources/assets/dist",
    rollupOptions: {
      input: {
        "{{package_slug}}": "resources/assets/css/{{package_slug}}.css",
      },
      output: {
        assetFileNames: "[name][extname]",
        entryFileNames: "[name].js",
      },
    },
  },
});
