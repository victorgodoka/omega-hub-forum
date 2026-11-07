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
      ["Topics", fmt(s.topic_count)],
      ["Posts", fmt(s.post_count)],
      ["Members", fmt(s.user_count)],
      ["Active · 30 days", fmt(s.active_users_30_days), true],
    ];
  }

  <template>
    {{#if this.show}}
      <section class="oh-hero">
        <div class="oh-hero__main">
          <div class="oh-eyebrow">Duelists Unite · Community forum</div>
          <h1>A hub for duelists that play card games.</h1>
          <p>A place where Duelists from all different trading card games gather to duel. Home of YGO Omega, a free online automatic Yu-Gi-Oh simulator.</p>
          {{#unless this.currentUser}}
            <div class="oh-hero__cta">
              <a class="btn btn-primary" href="/signup">Sign Up</a>
              <a class="btn btn-default" href="https://discord.gg/" target="_blank" rel="noopener noreferrer">Discord</a>
            </div>
          {{/unless}}
        </div>
        <aside class="oh-hero__stats" aria-label="Forum at a glance">
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
