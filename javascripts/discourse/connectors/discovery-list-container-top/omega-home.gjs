import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";

const ICONS = {"team": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><path fill=\"#eef1f8\" d=\"M7.2 17.1A8.3 8.3 0 1 1 16.8 17.1V18H21v2.5h-6.8v-4.2a5.6 5.6 0 1 0-4.4 0v4.2H3V18h4.2z\"/></svg>", "website": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><mask id=\"m\"><rect width=\"24\" height=\"24\" fill=\"#fff\"></rect><g fill=\"none\" stroke=\"#000\" stroke-width=\"1.6\"><ellipse cx=\"12\" cy=\"12\" rx=\"4.2\" ry=\"10\"></ellipse><path d=\"M1 12h22M2.5 7.2h19M2.5 16.8h19\"></path></g></mask><circle cx=\"12\" cy=\"12\" r=\"10\" fill=\"#eef1f8\" mask=\"url(#m)\"></circle></svg>", "yu-gi-oh": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><mask id=\"m\"><rect width=\"24\" height=\"24\" fill=\"#fff\"></rect><rect x=\"6.6\" y=\"2.6\" width=\"15\" height=\"19.2\" rx=\"2\" fill=\"#000\"></rect></mask><g mask=\"url(#m)\"><rect x=\"2.5\" y=\"5\" width=\"11\" height=\"16\" rx=\"1.4\" transform=\"rotate(-15 8 13)\" fill=\"#eef1f8\"></rect></g><path fill=\"#eef1f8\" fill-rule=\"evenodd\" d=\"M9.6 4h9.3A1.6 1.6 0 0 1 20.5 5.6v12.8A1.6 1.6 0 0 1 18.9 20H9.6A1.6 1.6 0 0 1 8 18.4V5.6A1.6 1.6 0 0 1 9.6 4zm.6 2.2v6.6h8.1V6.2zm0 8.6v1.4h8.1v-1.4zm0 2.4v1h5.5v-1z\"></path></svg>", "ygo omega": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><path fill=\"#eef1f8\" d=\"M7.2 17.1A8.3 8.3 0 1 1 16.8 17.1V18H21v2.5h-6.8v-4.2a5.6 5.6 0 1 0-4.4 0v4.2H3V18h4.2z\"></path></svg>", "tournaments": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><g fill=\"#eef1f8\"><path d=\"M7 3h10v5.5a5 5 0 0 1-10 0z\"></path><path d=\"M3 4.5h4v1.9H4.9V7a2.5 2.5 0 0 0 2.4 2.5l.5 1.9A4.4 4.4 0 0 1 3 7z\"></path><path d=\"M21 4.5h-4v1.9h2.1V7a2.5 2.5 0 0 1-2.4 2.5l-.5 1.9A4.4 4.4 0 0 0 21 7z\"></path><rect x=\"11\" y=\"13\" width=\"2\" height=\"4\"></rect><path d=\"M8 16.6h8V19h1.5v2h-11v-2H8z\"></path></g></svg>", "dorm wars": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><defs><g id=\"s\"><path d=\"M12 1l1.4 1.8v11.4h-2.8V2.8z\"></path><rect x=\"8\" y=\"14.2\" width=\"8\" height=\"2\"></rect><rect x=\"11\" y=\"16.2\" width=\"2\" height=\"3.6\"></rect><rect x=\"10.4\" y=\"19.8\" width=\"3.2\" height=\"2\"></rect></g></defs><g fill=\"#eef1f8\"><use href=\"#s\" transform=\"rotate(42 12 12)\"></use><use href=\"#s\" transform=\"rotate(-42 12 12)\"></use></g></svg>", "watercooler": "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\"><mask id=\"m\"><rect width=\"24\" height=\"24\" fill=\"#fff\"></rect><path d=\"M7.6 7.6h15v12h-1.6v4.4L15.8 19.6H7.6z\" fill=\"#000\"></path></mask><path fill=\"#eef1f8\" mask=\"url(#m)\" d=\"M1.5 2.5h14v10H7l-3.5 3.2V12.5h-2z\"></path><path fill=\"#eef1f8\" d=\"M9 9h12.5v9.2h-1.8v3.3l-3.9-3.3H9z\"></path></svg>"};
const icon = (n) => {
  const svg = ICONS[(n || "").toLowerCase()];
  return svg ? `data:image/svg+xml,${encodeURIComponent(svg)}` : null;
};
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const num = (n) => (n || 0).toLocaleString("en-US");
const short = (n) => (n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(n));
const replies = (n) => (n === 1 ? "1 reply" : `${num(n)} replies`);

function age(iso) {
  const d = new Date(iso);
  const mins = Math.floor((Date.now() - d) / 60000);
  if (mins < 60) return `${Math.max(mins, 1)}m`;
  if (mins < 1440) return `${Math.floor(mins / 60)}h`;
  if (mins < 43200) return `${Math.floor(mins / 1440)}d`;
  return d.getFullYear() === new Date().getFullYear()
    ? `${MONTHS[d.getMonth()]} ${d.getDate()}`
    : `${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

export default class OmegaHome extends Component {
  @service router;
  @service site;

  @tracked cats = [];
  @tracked latest = [];

  constructor() {
    super(...arguments);
    this.load();
  }

  get show() {
    return this.router.currentRouteName === "discovery.categories";
  }

  get subCount() {
    return this.cats.reduce((n, c) => n + c.subs.length, 0);
  }

  async load() {
    const [c, l] = await Promise.all([
      ajax("/categories.json?include_subcategories=true"),
      ajax("/latest.json"),
    ]);
    const top = c.category_list.categories.filter((x) => !x.parent_category_id);
    const recents = await Promise.all(
      top.map((x) =>
        ajax(`/c/${x.slug}/${x.id}.json`)
          .then((r) => r.topic_list.topics.slice(0, 3))
          .catch(() => [])
      )
    );
    this.cats = top.map((x, i) => ({
      name: x.name,
      color: `#${x.color}`,
      icon: icon(x.name),
      url: `/c/${x.slug}/${x.id}`,
      total: short(x.topic_count),
      desc: x.description ? htmlSafe(x.description) : null,
      subs: (x.subcategory_list || []).map((s) => ({
        name: s.name,
        color: `#${s.color}`,
        url: `/c/${x.slug}/${s.slug}/${s.id}`,
        count: num(s.topic_count),
      })),
      topics: recents[i].map((t) => ({
        title: t.title,
        url: `/t/${t.slug}/${t.id}`,
        age: age(t.last_posted_at || t.created_at),
        replies: num(t.reply_count),
        label: replies(t.reply_count),
      })),
    }));
    const users = l.users || [];
    this.latest = l.topic_list.topics.slice(0, 8).map((t) => {
      const u = users.find((x) => x.username === t.last_poster_username);
      const cat = this.site.categories.find((x) => x.id === t.category_id);
      return {
        title: t.title,
        url: `/t/${t.slug}/${t.id}`,
        pinned: t.pinned,
        cat: cat?.name,
        replies: replies(t.reply_count),
        age: age(t.last_posted_at || t.created_at),
        by: `${t.reply_count ? "Last reply by" : "Posted by"} ${t.last_poster_username}`,
        avatar: u?.avatar_template?.replace("{size}", "64"),
        initial: (t.last_poster_username || "?").charAt(0).toUpperCase(),
      };
    });
  }

  <template>
    {{#if this.show}}
      <div class="oh-home">
        <section class="oh-home__cats" aria-labelledby="oh-cat-h">
          <div class="oh-sec">
            <span class="oh-sec__n">01</span>
            <h2 id="oh-cat-h">Categories</h2>
            <span class="oh-sec__rule"></span>
            <span class="oh-signal">{{this.cats.length}} categories · {{this.subCount}} subcategories</span>
          </div>
          {{#each this.cats as |c|}}
            <article class="oh-card">
              <div class="oh-card__in">
                <div class="oh-card__info">
                  <div class="oh-card__head">
                    <span class="oh-ico" aria-hidden="true" style="box-shadow: inset 0 -3px 0 {{c.color}}">{{#if c.icon}}<img src={{c.icon}} alt="" width="24" height="24" />{{/if}}</span>
                    <h3><a href={{c.url}}>{{c.name}}</a></h3>
                    <span class="oh-signal oh-card__total">{{c.total}} total</span>
                  </div>
                  {{#if c.desc}}<div class="oh-card__desc">{{c.desc}}</div>{{/if}}
                  <ul class="oh-chips" aria-label="Subcategories">
                    {{#each c.subs as |s|}}
                      <li><a class="oh-chip" href={{s.url}}><span class="oh-sq oh-sq--sm" style="background: {{s.color}}"></span>{{s.name}}<span class="oh-signal">{{s.count}}</span></a></li>
                    {{/each}}
                  </ul>
                </div>
                <div class="oh-card__recent">
                  <span class="oh-signal">Recent topics</span>
                  <ol class="oh-rows">
                    {{#each c.topics as |t|}}
                      <li class="oh-row">
                        <div class="oh-row__main">
                          <a class="oh-ttl oh-row__t" href={{t.url}}>{{t.title}}</a>
                          <span class="oh-signal">{{t.age}}</span>
                        </div>
                        <span class="oh-row__rep" aria-label={{t.label}}>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M3 4h18v13H8l-5 4z"></path></svg>
                          <span>{{t.replies}}</span>
                        </span>
                      </li>
                    {{/each}}
                  </ol>
                </div>
              </div>
            </article>
          {{/each}}
        </section>

        <aside class="oh-home__latest" aria-label="Latest and links">
          <div class="oh-sec">
            <span class="oh-sec__n">02</span>
            <h2>Latest</h2>
            <span class="oh-sec__rule"></span>
            <span class="oh-signal">Newest first</span>
          </div>
          <div class="oh-panel">
            <div class="oh-panel__in">
              <ol class="oh-lat">
                {{#each this.latest as |l|}}
                  <li class="oh-lat__row">
                    {{#if l.avatar}}
                      <img class="oh-lat__av" src={{l.avatar}} alt="" width="32" height="32" />
                    {{else}}
                      <span class="oh-lat__av oh-lat__av--i" aria-hidden="true">{{l.initial}}</span>
                    {{/if}}
                    <div class="oh-lat__body">
                      <a class="oh-ttl oh-lat__t" href={{l.url}}>{{l.title}}</a>
                      <div class="oh-lat__meta">
                        {{#if l.pinned}}<span class="oh-signal oh-lat__pin"><svg width="11" height="11" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M15 2l7 7-1.6 1.6-1.2-.4-3.7 3.7.4 4.4-1.6 1.6-4.2-4.2L4.4 21.4 3 20l5.7-5.7-4.2-4.2 1.6-1.6 4.4.4 3.7-3.7-.4-1.2z"></path></svg>Pinned</span>{{/if}}
                        <span class="oh-signal oh-lat__cat">{{l.cat}}</span>
                        <span class="oh-signal">{{l.replies}} · {{l.age}}</span>
                      </div>
                      <span class="oh-lat__by">{{l.by}}</span>
                    </div>
                  </li>
                {{/each}}
              </ol>
              <div class="oh-lat__all"><a class="oh-signal" href="/latest">View all latest<svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M4 11h11.2l-4.6-4.6L12 5l7 7-7 7-1.4-1.4 4.6-4.6H4z"></path></svg></a></div>
            </div>
          </div>
        </aside>
      </div>
    {{/if}}
  </template>
}
