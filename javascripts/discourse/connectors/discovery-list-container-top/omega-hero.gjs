import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { get } from "@ember/helper";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export default class OmegaHero extends Component {
  @service router;
  @service currentUser;

  @tracked stats;

  constructor() {
    super(...arguments);
    ajax("/about.json").then((r) => (this.stats = r.about.stats));
  }

  get show() {
    return this.router.currentRouteName === "discovery.categories";
  }

  get cells() {
    const s = this.stats || {};
    const fmt = (n) => (n == null ? "–" : n.toLocaleString("en-US"));
    return [
      ["Topics", fmt(s.topics_count)],
      ["Posts", fmt(s.posts_count)],
      ["Members", fmt(s.users_count)],
      ["Active · 30 days", fmt(s.active_users_30_days), true],
    ];
  }

  <template>
    {{#if this.show}}
      <section class="oh-hero">
        <div class="oh-hero__main">
          <div class="oh-eyebrow"><i class="oh-eyebrow__sq"></i>Duelists Unite · YGO Omega community forum</div>
          <h1>YGO Omega forum: a hub for card game duelists</h1>
          <p>Home of YGO Omega, the free online automatic Yu-Gi-Oh simulator. Report bugs, share decks, get rulings, join tournaments and duel with players from every trading card game.</p>
          {{#unless this.currentUser}}
            <div class="oh-hero__cta">
              <a class="btn btn-primary" href="/signup">Sign Up<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M4 11h11.2l-4.6-4.6L12 5l7 7-7 7-1.4-1.4 4.6-4.6H4z"></path></svg></a>
              <a class="btn btn-default" href="https://discord.gg/duelistsunite" target="_blank" rel="noopener noreferrer">Discord</a>
            </div>
          {{/unless}}
        </div>
        <aside class="oh-hero__stats" aria-label="Forum statistics">
          <div class="oh-signal">At a glance</div>
          <div class="oh-stats">
            {{#each this.cells as |c|}}
              <div class="oh-stat {{if (get c 2) 'oh-stat--live'}}">
                <span class="oh-signal">{{get c 0}}</span>
                <span class="oh-stat__n">{{get c 1}}</span>
              </div>
            {{/each}}
          </div>
        </aside>
      </section>
    {{/if}}
  </template>
}
