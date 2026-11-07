import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";

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
                    <span class="oh-sq" style="background: {{c.color}}"></span>
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
                        {{#if l.pinned}}<span class="oh-signal oh-lat__pin">Pinned</span>{{/if}}
                        <span class="oh-signal oh-lat__cat">{{l.cat}}</span>
                        <span class="oh-signal">{{l.replies}} · {{l.age}}</span>
                      </div>
                      <span class="oh-lat__by">{{l.by}}</span>
                    </div>
                  </li>
                {{/each}}
              </ol>
              <div class="oh-lat__all"><a class="oh-signal" href="/latest">View all latest →</a></div>
            </div>
          </div>
        </aside>
      </div>
    {{/if}}
  </template>
}
