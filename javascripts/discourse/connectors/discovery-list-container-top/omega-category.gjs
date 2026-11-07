import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";

import { AutoAd } from "../../components/oh-ad";

const num =(n) => (n || 0).toLocaleString("en-US");

export default class OmegaCategory extends Component {
  @service router;
  @service site;

  get isCategory() {
    return /^discovery\..*[cC]ategory/.test(this.router.currentRouteName || "");
  }

  // Category id is the last segment of /c/<slug path>/<id>
  get cat() {
    if (!this.isCategory) {
      return null;
    }
    const path = this.router.currentRoute?.params?.category_slug_path_with_id || "";
    const id = parseInt(path.split("/").filter(Boolean).pop(), 10);
    return this.site.categories.find((c) => c.id === id) || null;
  }

  get view() {
    const c = this.cat;
    if (!c) {
      return null;
    }
    const parent = c.parentCategory;
    const subs = this.site.categories
      .filter((s) => s.parent_category_id === c.id)
      .map((s) => ({
        name: s.name,
        color: `#${s.color}`,
        url: `/c/${c.slug}/${s.slug}/${s.id}`,
        count: `${num(s.topic_count)} topics`,
      }));
    return {
      name: c.name,
      color: `#${c.color}`,
      desc: c.description ? htmlSafe(c.description) : null,
      url: `/c/${c.slug}/${c.id}`,
      parent: parent && { name: parent.name, url: `/c/${parent.slug}/${parent.id}` },
      subs,
      topics: num(c.topic_count),
      posts: num(c.post_count),
    };
  }

  <template>
    {{#if this.view}}
      <header class="oh-cat">
        <nav class="oh-cat__crumbs" aria-label="Breadcrumb">
          <a class="oh-signal" href="/categories">Categories</a>
          {{#if this.view.parent}}
            <span class="oh-signal" aria-hidden="true">/</span>
            <a class="oh-signal" href={{this.view.parent.url}}>{{this.view.parent.name}}</a>
          {{/if}}
          <span class="oh-signal" aria-hidden="true">/</span>
          <span class="oh-signal oh-cat__here" aria-current="page">{{this.view.name}}</span>
        </nav>
        <div class="oh-panel">
          <div class="oh-panel__in oh-cat__in">
            <div class="oh-cat__main">
              <span class="oh-signal">Latest topics in {{this.view.name}}</span>
              <h1>{{this.view.name}}</h1>
              {{#if this.view.desc}}<div class="oh-cat__desc">{{this.view.desc}}</div>{{/if}}
            </div>
            <div class="oh-cat__side">
              <div class="oh-stats oh-stats--3">
                <div class="oh-stat"><span class="oh-signal">Subcategories</span><span class="oh-stat__n">{{this.view.subs.length}}</span></div>
                <div class="oh-stat"><span class="oh-signal">Topics</span><span class="oh-stat__n">{{this.view.topics}}</span></div>
                <div class="oh-stat"><span class="oh-signal">Posts</span><span class="oh-stat__n">{{this.view.posts}}</span></div>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div class="oh-cat__ad"><AutoAd @id="oh-ad-cat-top" @size="lb" @note="Leaderboard · topic list top" /></div>
      <div class="oh-rail oh-rail--l"><AutoAd @id="oh-ad-cat-rail-l" @size="rail" /></div>
      <div class="oh-rail oh-rail--r"><AutoAd @id="oh-ad-cat-rail-r" @size="rail" /></div>

      {{#if this.view.subs.length}}
        <section class="oh-cat__subs" aria-labelledby="oh-sub-h">
          <div class="oh-sec">
            <span class="oh-sec__n">01</span>
            <h2 id="oh-sub-h">Subcategories</h2>
            <span class="oh-sec__rule"></span>
          </div>
          <div class="oh-subgrid">
            {{#each this.view.subs as |s|}}
              <a class="oh-sub" href={{s.url}}>
                <span class="oh-sq oh-sq--sm" style="background: {{s.color}}"></span>
                <span class="oh-sub__n">{{s.name}}</span>
                <span class="oh-signal">{{s.count}}</span>
              </a>
            {{/each}}
          </div>
        </section>
      {{/if}}

      <div class="oh-sec oh-cat__topics-h">
        <span class="oh-sec__n">{{if this.view.subs.length "02" "01"}}</span>
        <h2>Topics</h2>
        <span class="oh-sec__rule"></span>
        <span class="oh-signal">Newest activity first</span>
      </div>
      <div class="oh-cat__bottom"><AutoAd @id="oh-ad-cat-bottom" @size="lb" @note="Leaderboard · before footer" /></div>
    {{/if}}
  </template>
}
