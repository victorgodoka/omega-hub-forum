import { apiInitializer } from "discourse/lib/api";

// Header nav from the "Header states" artboard.
// ponytail: URLs are placeholders ("#"): fill in the real forum links.
const LINKS = [
  { label: "News", href: "#" },
  { label: "Downloads", href: "#" },
  {
    label: "Leaderboards",
    items: [{ label: "TCG & OCG Rankings", desc: "TCG Leaderboard", href: "#" }],
  },
  { label: "Statistics", href: "#" },
  {
    label: "Tournaments",
    items: [
      { label: "Live Tournament", desc: "Live Tournament", href: "#", live: true },
      { label: "Past Tournaments", desc: "Past Tournaments", href: "#" },
    ],
  },
  {
    label: "Tools",
    items: [
      { label: "Probability Calculator", desc: "Hypergeometric Calculator for YGO", href: "#" },
      { label: "Custom Banlist Creator", desc: "Create your own banlist", href: "#" },
    ],
  },
];

const Nav = <template>
  <li class="oh-nav">
    <ul>
      {{#each LINKS as |l|}}
        <li class="oh-nav__item">
          {{#if l.items}}
            <button type="button" class="oh-nav__link" aria-haspopup="menu">{{l.label}}<span class="oh-nav__caret" aria-hidden="true"></span></button>
            <div class="oh-nav__menu" role="menu">
              {{#each l.items as |i|}}
                <a href={{i.href}} role="menuitem">
                  <b>{{#if i.live}}<span class="oh-nav__live" role="img" aria-label="Live"></span>{{/if}}{{i.label}}</b>
                  <span>{{i.desc}}</span>
                </a>
              {{/each}}
            </div>
          {{else}}
            <a href={{l.href}} class="oh-nav__link">{{l.label}}</a>
          {{/if}}
        </li>
      {{/each}}
    </ul>
  </li>
</template>;

const Social = <template>
  <li class="oh-social">
    <a href="https://discord.gg/duelistsunite" target="_blank" rel="noopener noreferrer">Discord</a>
    <a href="https://www.twitch.tv/duelists_unite" target="_blank" rel="noopener noreferrer">Twitch</a>
  </li>
</template>;

export default apiInitializer((api) => {
  api.headerIcons?.add("oh-nav", Nav, { before: "search" });
  api.headerIcons?.add("oh-social", Social, { before: "search" });
  // Core hides the footer on lists that can load more; our design wants it on every page
  api.container.lookup("service:footer")._showFooterOverride = true;
});
