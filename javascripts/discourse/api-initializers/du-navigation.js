import { apiInitializer } from "discourse/lib/api";

// Duelists Unite: navigation fixes
// 1. Adds a "Duelists Unite" section to the ☰ menu, so the site links
//    (Download, Web Simulator, Tournaments, Leaderboards, Statistics, tier lists) can be
//    reached on phones, tablets and narrow laptop windows, where the theme
//    hides the top menu.
// 2. Adds a "Download YGO Omega" button to the homepage hero.

const OMEGA = "https://omega.duelistsunite.org";
const DOWNLOAD_URL = `${OMEGA}/download`;

// [text, url, icon]. Icons must exist in the forum's icon set.
const SITE_LINKS = [
  ["Download YGO Omega", DOWNLOAD_URL, "download"],
  // Tools
  ["Web Simulator", "/simulator/", "puzzle-piece"],
  ["Combo Calculator", "https://duelistsunite.org/combo/", "chart-bar"],
  ["Banlist Creator", "/banlist-creator/", "table"],
  ["Card Creator", "/card-creator/", "wrench"],
  ["Live Tournaments", `${OMEGA}/tournament`, "trophy"],
  ["Tournaments Calendar", `${OMEGA}/calendar`, "calendar-days"],
  ["Leaderboards", `${OMEGA}/leaderboard`, "list-ol"],
  ["Ranked Statistics", `${OMEGA}/statistics`, "chart-line"],
  ["TCG Tier List", `${OMEGA}/wiki/yu-gi-oh-tcg-tier-list`, "layer-group"],
  ["Genesys Tier List", `${OMEGA}/wiki/yu-gi-oh-genesys-tier-list`, "layer-group"],
  ["Discord", "https://discord.gg/duelistsunite", "fab-discord"],
];

export default apiInitializer((api) => {
  api.addSidebarSection((BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
    const links = SITE_LINKS.map(
      ([text, href, icon], i) =>
        new (class extends BaseCustomSidebarSectionLink {
          name = `du-site-${i}`;
          // raw-link: stop Discourse's router from catching same-site links
          // such as /simulator/ (it would show its 404 page instead).
          classNames = "du-site-link raw-link";
          text = text;
          title = text;
          href = href;
          prefixType = "icon";
          prefixValue = icon;
        })()
    );

    return class extends BaseCustomSidebarSection {
      name = "du-site";
      text = "Duelists Unite";
      links = links;
    };
  });

  // Hero button. The hero belongs to the main theme, so add the button
  // whenever the hero appears (it re-renders on navigation).
  const addDownloadButton = () => {
    const cta = document.querySelector(".oh-hero__cta");
    if (!cta || cta.querySelector(".du-download-btn")) {
      return;
    }
    const a = document.createElement("a");
    a.className = "btn btn-primary du-download-btn";
    a.href = DOWNLOAD_URL;
    a.target = "_blank";
    a.rel = "noopener noreferrer";
    a.innerHTML =
      '<svg class="fa d-icon d-icon-download svg-icon" aria-hidden="true"><use href="#download"></use></svg>';
    a.append(" Download YGO Omega");
    cta.prepend(a);
  };

  new MutationObserver(addDownloadButton).observe(document.body, {
    childList: true,
    subtree: true,
  });
  api.onPageChange(addDownloadButton);
});
