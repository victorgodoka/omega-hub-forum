import { apiInitializer } from "discourse/lib/api";

// Duelists Unite: polish
// - Phone bottom bar (shown by CSS only below 768px).
// - Footer copyright year kept current ("© 2020–2026").

const ITEMS = [
  { key: "home", label: "Home", href: "/", icon: "house" },
  { key: "latest", label: "Latest", href: "/latest", icon: "bolt" },
  {
    key: "download",
    label: "Download",
    href: "https://omega.duelistsunite.org/download",
    icon: "download",
    external: true,
  },
  // raw-link: the simulator is its own app, so the forum's router must not catch it
  { key: "sim", label: "Simulator", href: "/simulator/", icon: "puzzle-piece", raw: true },
  { key: "menu", label: "Menu", icon: "bars", menu: true },
];

export default apiInitializer((api) => {
  const buildBar = () => {
    if (document.querySelector(".du-tabbar")) {
      return;
    }
    const nav = document.createElement("nav");
    nav.className = "du-tabbar";
    nav.setAttribute("aria-label", "Quick links");
    for (const it of ITEMS) {
      const el = document.createElement(it.menu ? "button" : "a");
      el.className = `du-tabbar__item du-tabbar__item--${it.key}`;
      if (it.menu) {
        el.type = "button";
        el.addEventListener("click", () =>
          document.getElementById("toggle-hamburger-menu")?.click()
        );
      } else {
        el.href = it.href;
        if (it.external) {
          el.target = "_blank";
          el.rel = "noopener noreferrer";
        }
        if (it.raw) {
          el.classList.add("raw-link");
        }
      }
      el.innerHTML = `<svg class="fa d-icon svg-icon" aria-hidden="true"><use href="#${it.icon}"></use></svg><span>${it.label}</span>`;
      nav.append(el);
    }
    document.body.append(nav);
    document.body.classList.add("du-has-tabbar");
  };

  const markActive = () => {
    const p = location.pathname;
    let key = null;
    if (p === "/" || p.startsWith("/categories")) {
      key = "home";
    } else if (p.startsWith("/latest") || p.startsWith("/new") || p.startsWith("/top")) {
      key = "latest";
    }
    document.querySelectorAll(".du-tabbar__item").forEach((el) => {
      el.classList.toggle("is-active", el.classList.contains(`du-tabbar__item--${key}`));
    });
  };

  const footerYear = () => {
    const span = [...document.querySelectorAll(".oh-footer__bottom span")].find(
      (s) => !s.dataset.duYear && /©\s*20\d\d/.test(s.textContent)
    );
    if (!span) {
      return;
    }
    const year = new Date().getFullYear();
    span.textContent = span.textContent.replace(
      /©\s*(20\d\d)(?:\s*[–-]\s*20\d\d)?/,
      (m, start) => `© ${start}${Number(start) < year ? "–" + year : ""}`
    );
    span.dataset.duYear = "1";
  };

  api.onPageChange(() => {
    buildBar();
    markActive();
    footerYear();
  });

  new MutationObserver(footerYear).observe(document.body, { childList: true, subtree: true });
});
