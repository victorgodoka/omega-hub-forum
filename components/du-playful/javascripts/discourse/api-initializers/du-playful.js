import { apiInitializer } from "discourse/lib/api";

// Duelists Unite: playful sections (small helpers for the CSS)
// 1. A quick fade on every page change (restarts a 0.2s CSS animation).
// 2. Category pages: shows the category's own logo as an emblem in the
//    banner. The logo is already on the page (hidden), so nothing extra loads.

export default apiInitializer((api) => {
  const fadeIn = () => {
    const outlet = document.getElementById("main-outlet");
    if (!outlet) {
      return;
    }
    outlet.classList.remove("du-enter");
    requestAnimationFrame(() => outlet.classList.add("du-enter"));
  };

  const addEmblem = () => {
    const main = document.querySelector(".oh-cat__main");
    if (!main || main.querySelector(".du-emblem")) {
      return;
    }
    const logo = document.querySelector(".category-heading__logo img");
    if (!logo || !logo.getAttribute("src")) {
      return;
    }
    const wrap = document.createElement("span");
    wrap.className = "du-emblem";
    wrap.setAttribute("aria-hidden", "true");
    const img = document.createElement("img");
    img.alt = "";
    img.src = logo.getAttribute("src");
    img.decoding = "async";
    wrap.append(img);
    main.prepend(wrap);
  };

  let first = true;
  api.onPageChange(() => {
    if (!first) {
      fadeIn(); // not on the very first load: nothing to transition from
    }
    first = false;
    addEmblem();
  });

  new MutationObserver(addEmblem).observe(document.body, { childList: true, subtree: true });
});
