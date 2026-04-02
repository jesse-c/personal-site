// Vega, Vega-Lite, and Vega-Embed are loaded lazily from CDN the first time a
// `VegaChart` hook mounts, then shared across all chart instances on the page.
const VEGA_SCRIPTS = [
  "https://cdn.jsdelivr.net/npm/vega@5/build/vega.min.js",
  "https://cdn.jsdelivr.net/npm/vega-lite@5/build/vega-lite.min.js", // v5
  "https://cdn.jsdelivr.net/npm/vega-embed@6/build/vega-embed.min.js",
];

// vega-embed uses vega-tooltip for hover tooltips. The JS is bundled inside
// vega-embed, but the stylesheet must be loaded separately or tooltips are
// invisible (the div is in the DOM but has no styles).
const VEGA_CSS = "https://cdn.jsdelivr.net/npm/vega-tooltip@0/build/vega-tooltip.min.css";

function loadVegaCSS() {
  if (document.querySelector(`link[href="${VEGA_CSS}"]`)) return;
  const link = document.createElement("link");
  link.rel = "stylesheet";
  link.href = VEGA_CSS;
  document.head.appendChild(link);
}

// Inject the three Vega scripts sequentially (each depends on the
// previous) and return a promise that resolves once all three are
// ready.
//
// Concurrent mount calls share the same in-flight promise so
// scripts are only fetched once.
function loadVega() {
  if (window.vegaEmbed) return Promise.resolve();
  if (window.__vegaLoading) return window.__vegaLoading;

  window.__vegaLoading = VEGA_SCRIPTS.reduce(
    (chain, src) =>
      chain.then(
        () =>
          new Promise((resolve, reject) => {
            const s = document.createElement("script");
            s.src = src;
            s.onload = resolve;
            s.onerror = reject;
            document.head.appendChild(s);
          }),
      ),
    Promise.resolve(),
  )
    .then(() => {
      window.__vegaLoading = null;
    })
    .catch((err) => {
      // Clear the cached promise so a retry is possible after a transient failure.
      window.__vegaLoading = null;
      throw err;
    });

  return window.__vegaLoading;
}

// Phoenix LiveView hook — attached to any element with phx-hook="VegaChart".
// The element must carry a data-spec attribute containing the Vega-Lite JSON spec
// (set by MDExVl at compile time).
export const VegaChart = {
  mounted() {
    this._destroyed = false;
    loadVegaCSS();
    const spec = JSON.parse(this.el.dataset.spec);
    loadVega()
      .then(() => {
        // Guard: hook may have been destroyed while Vega was loading.
        if (this._destroyed) return;
        this.render(spec);
        // Re-render whenever the <html> class changes (e.g. dark mode toggle)
        // so the chart theme stays in sync.
        this.observer = new MutationObserver(() => this.render(spec));
        this.observer.observe(document.documentElement, {
          attributes: true,
          attributeFilter: ["class"],
        });
      })
      .catch((err) => console.error("[VegaChart] failed to load Vega:", err));
  },
  destroyed() {
    this._destroyed = true;
    this.observer?.disconnect();
  },
  render(spec) {
    // Build a Vega config that matches the current colour scheme. In dark mode
    // explicit colours are needed because Vega's defaults assume a white background.
    const dark = document.documentElement.classList.contains("dark");
    const config = dark
      ? {
          background: "transparent",
          axis: {
            labelColor: "#d1d5db",
            titleColor: "#d1d5db",
            gridColor: "#374151",
            domainColor: "#4b5563",
            tickColor: "#4b5563",
          },
          legend: { labelColor: "#d1d5db", titleColor: "#d1d5db" },
          title: { color: "#d1d5db" },
          view: { stroke: "#374151" },
        }
      : {
          background: "transparent",
        };
    window
      .vegaEmbed(this.el, spec, { config, actions: false })
      .catch((err) => console.error("[VegaChart] embed error:", err));
  },
};
