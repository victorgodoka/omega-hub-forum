import { apiInitializer } from "discourse/lib/api";

// Header nav comes from the "header_links" theme setting (flat list; "parent" nests an item).
function tree() {
  const all = settings.header_links || [];
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
                <a href={{i.url}} role="menuitem">
                  <b>{{#if i.icon}}<img class="oh-nav__icon" src={{i.icon}} alt="" />{{/if}}{{#if i.live}}<span class="oh-nav__live" role="img" aria-label="Live"></span>{{/if}}{{i.label}}</b>
                  {{#if i.description}}<span>{{i.description}}</span>{{/if}}
                </a>
              {{/each}}
            </div>
          {{else}}
            <a href={{l.url}} class="oh-nav__link">{{#if l.icon}}<img class="oh-nav__icon" src={{l.icon}} alt="" />{{/if}}{{l.label}}</a>
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
