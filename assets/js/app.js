// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { hooks as colocatedHooks } from "phoenix-colocated/personal_site";
import { VegaChart } from "./hooks/vega_chart";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let Hooks = { VegaChart };

Hooks.TrackClientCursor = {
  mounted() {
    document.addEventListener("mousemove", (e) => {
      // Do as a percentage as people's windows will be different sizes.
      //
      // Small offset, relative to the cursor.
      const x = ((e.pageX - 8) / window.innerWidth) * 100; // in %
      const y = ((e.pageY - 11) / window.innerHeight) * 100; // in %

      this.pushEvent("cursor-move", { x, y });
    });
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...Hooks, ...colocatedHooks },
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Copy button for code blocks
let copyScrollHandlers = [];

function addCopyButtons() {
  document.querySelectorAll("pre").forEach((pre) => {
    if (pre.querySelector(".copy-button")) return;

    const button = document.createElement("button");
    button.className = "copy-button";
    button.textContent = "Copy";

    // Handle the actual copying
    button.addEventListener("click", () => {
      const code = pre.querySelector("code") ?? pre;
      navigator.clipboard.writeText(code.innerText).then(() => {
        button.textContent = "Copied!";
        setTimeout(() => {
          button.textContent = "Copy";
        }, 2000);
      });
    });

    // Attach it to the code block
    pre.appendChild(button);

    // Float the button at the top when scrolling past the `pre`'s top
    // edge.
    const onScroll = () => {
      const rect = pre.getBoundingClientRect();
      if (rect.top < 0 && rect.bottom > 32) {
        // The magic number at the end was tweaked via testing
        const rightPx = Math.max(0, window.innerWidth - rect.right) + 5;
        button.style.cssText = `position:fixed;top:0.25rem;right:${rightPx}px;opacity:1;`;
      } else {
        button.style.cssText = "";
      }
    };

    window.addEventListener("scroll", onScroll, { passive: true });
    copyScrollHandlers.push(onScroll);
  });
}

function removeCopyButtons() {
  copyScrollHandlers.forEach((h) => window.removeEventListener("scroll", h));
  copyScrollHandlers = [];
}

// Setup and teardown copy buttons
document.addEventListener("DOMContentLoaded", addCopyButtons);
window.addEventListener("phx:page-loading-start", removeCopyButtons);
window.addEventListener("phx:page-loading-stop", addCopyButtons);

// Dark mode from Tailwind [1]
//
// [1] https://tailwindcss.com/docs/dark-mode

// On page load or when changing themes, best to add inline in `head` to avoid FOUC
if (
  localStorage.theme === "dark" ||
  (!("theme" in localStorage) &&
    window.matchMedia("(prefers-color-scheme: dark)").matches)
) {
  document.documentElement.classList.add("dark");
} else {
  document.documentElement.classList.remove("dark");
}

// Whenever the user explicitly chooses light mode
localStorage.theme = "light";

// Whenever the user explicitly chooses dark mode
localStorage.theme = "dark";

// Whenever the user explicitly chooses to respect the OS preference
localStorage.removeItem("theme");
