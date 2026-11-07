import { apiInitializer } from "discourse/lib/api";

// Header nav comes from the "header_links" theme setting (flat list; "parent" nests an item).
// Icon value: an image URL, or inline <svg ...> markup pasted in the setting
const iconSrc = (v) => {
  v = (v || "").trim();
  return v.startsWith("<svg") ? `data:image/svg+xml,${encodeURIComponent(v)}` : v;
};

function tree() {
  const all = (settings.header_links || []).map((l) => ({ ...l, icon: l.icon_upload || iconSrc(l.icon) }));
  return all
    .filter((l) => !l.parent)
    .map((l) => ({ ...l, items: all.filter((c) => c.parent && c.parent === l.label) }));
}

const Nav = <template>
  <li class="oh-nav">
    <ul>
      {{#each (tree) as |l|}}
        <li class="oh-nav__item">
          {{#if l.items.length}}
            <button type="button" class="oh-nav__link" aria-haspopup="menu">{{#if l.icon}}<img class="oh-nav__icon" src={{l.icon}} alt="" />{{/if}}{{l.label}}<span class="oh-nav__caret" aria-hidden="true"></span></button>
            <div class="oh-nav__menu" role="menu">
              {{#each l.items as |i|}}
                <a href={{i.url}} target={{if i.new_tab "_blank"}} rel={{if i.new_tab "noopener noreferrer"}} role="menuitem">
                  <b>{{#if i.icon}}<img class="oh-nav__icon" src={{i.icon}} alt="" />{{/if}}{{#if i.live}}<span class="oh-nav__live" role="img" aria-label="Live"></span>{{/if}}{{i.label}}</b>
                  {{#if i.description}}<span>{{i.description}}</span>{{/if}}
                </a>
              {{/each}}
            </div>
          {{else}}
            <a href={{l.url}} target={{if l.new_tab "_blank"}} rel={{if l.new_tab "noopener noreferrer"}} class="oh-nav__link">{{#if l.icon}}<img class="oh-nav__icon" src={{l.icon}} alt="" />{{/if}}{{l.label}}</a>
          {{/if}}
        </li>
      {{/each}}
    </ul>
  </li>
</template>;

export default apiInitializer((api) => {
  // Optional icon overrides from theme settings (CSS mask, see common.scss)
  ["search", "chat", "menu"].forEach((k) => {
    const url = settings[`icon_${k}_upload`] || iconSrc(settings[`icon_${k}`]);
    if (url) {
      document.documentElement.classList.add(`oh-ico-${k}`);
      document.documentElement.style.setProperty(`--oh-icon-${k}`, `url("${url}")`);
    }
  });
  api.headerIcons?.add("oh-nav", Nav, { before: "search" });
  // Core hides the footer on lists that can load more; our design wants it on every page
  api.container.lookup("service:footer")._showFooterOverride = true;
});
