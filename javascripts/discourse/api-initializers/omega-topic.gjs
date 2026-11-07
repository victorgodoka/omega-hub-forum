import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { AutoAd } from "../components/oh-ad";

// 728x90 after post 1, then after every 5th (posts 6, 11, ...)
class AfterPost extends Component {
  get show() {
    const n = this.args.outletArgs.post?.post_number;
    return n === 1 || n % 5 === 1;
  }
  get id() {
    return `oh-ad-post-${this.args.outletArgs.post.post_number}`;
  }
  <template>
    {{#if this.show}}
      <div class="oh-post-ad"><AutoAd @id={{this.id}} @size="row" @note="After post 1 · then every 5" /></div>
    {{/if}}
  </template>
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
const day = (iso) => {
  const d = new Date(iso);
  return `${MONTHS[d.getMonth()]} ${d.getDate()}`;
};
const av = (u) => u?.avatar_template?.replace("{size}", "48");

// Participants list inside the timeline card
class Participants extends Component {
  get list() {
    return (this.args.outletArgs?.model?.details?.participants || []).slice(0, 8).map((p) => ({
      name: p.username,
      avatar: av(p),
      count: p.post_count,
    }));
  }
  <template>
    {{#if this.list.length}}
      <div class="oh-parts">
        <span class="oh-signal">Participants</span>
        {{#each this.list as |p|}}
          <div class="oh-parts__row">
            <img src={{p.avatar}} alt="" width="24" height="24" />
            <a href="/u/{{p.name}}">{{p.name}}</a>
            <span class="oh-signal">{{p.count}} posts</span>
          </div>
        {{/each}}
      </div>
    {{/if}}
  </template>
}

// Stat cells under the title: Created / Last reply / Replies / Views / Users
class TopicMap extends Component {
  get t() {
    return this.args.outletArgs.model;
  }
  get created() {
    return { date: day(this.t.created_at), avatar: av(this.t.details?.created_by) };
  }
  get last() {
    return { date: day(this.t.last_posted_at), avatar: av(this.t.details?.last_poster) };
  }
  get replies() {
    return Math.max((this.t.posts_count || 1) - 1, 0).toLocaleString("en-US");
  }
  get views() {
    return (this.t.views || 0).toLocaleString("en-US");
  }
  <template>
    <div class="oh-map-wrap"><dl class="oh-map">
      <div class="oh-map__c"><dt class="oh-signal">Created</dt><dd>{{#if this.created.avatar}}<img src={{this.created.avatar}} alt="" width="22" height="22" />{{/if}}<span class="oh-signal oh-map__d">{{this.created.date}}</span></dd></div>
      <div class="oh-map__c"><dt class="oh-signal">Last reply</dt><dd>{{#if this.last.avatar}}<img src={{this.last.avatar}} alt="" width="22" height="22" />{{/if}}<span class="oh-signal oh-map__d">{{this.last.date}}</span></dd></div>
      <div class="oh-map__c"><dt class="oh-signal">Replies</dt><dd class="oh-map__n">{{this.replies}}</dd></div>
      <div class="oh-map__c"><dt class="oh-signal">Views</dt><dd class="oh-map__n">{{this.views}}</dd></div>
      <div class="oh-map__c"><dt class="oh-signal">Users</dt><dd class="oh-map__n">{{this.t.participant_count}}</dd></div>
    </dl></div>
    <div class="oh-rail oh-rail--l"><AutoAd @id="oh-ad-topic-rail-l" @size="rail" /></div>
    <div class="oh-rail oh-rail--r"><AutoAd @id="oh-ad-topic-rail-r" @size="rail" /></div>
  </template>
}

// Breadcrumb above the title: Categories / Parent / Category
class Crumbs extends Component {
  get items() {
    const c = this.args.outletArgs.model?.category;
    if (!c) {
      return [];
    }
    const path = [c.parentCategory, c].filter(Boolean);
    return path.map((x) => ({ name: x.name, url: `/c/${x.slug}/${x.id}` }));
  }
  <template>
    <nav class="oh-bc oh-signal" aria-label="Breadcrumb">
      <a href="/categories">Categories</a>
      {{#each this.items as |i|}}<span>/</span><a href={{i.url}}>{{i.name}}</a>{{/each}}
    </nav>
  </template>
}

// Last activity + participants, shown under the timeline
class Participants extends Component {
  get t() {
    return this.args.outletArgs.topic;
  }
  get last() {
    const iso = this.t?.last_posted_at;
    if (!iso) {
      return "";
    }
    const d = Math.floor((Date.now() - new Date(iso)) / 864e5);
    return `${day(iso)} · ${d}d ago`;
  }
  get people() {
    return (this.t?.details?.participants || []).map((p) => ({
      name: p.username,
      avatar: av(p),
      posts: `${p.post_count} post${p.post_count === 1 ? "" : "s"}`,
    }));
  }
  <template>
    <div class="oh-parts">
      <div class="oh-parts__last oh-signal">{{this.last}}</div>
      <div class="oh-parts__h oh-signal">Participants</div>
      {{#each this.people as |p|}}
        <div class="oh-parts__p">
          <img src={{p.avatar}} alt="" width="22" height="22" /><span>{{p.name}}</span><span class="oh-signal">{{p.posts}}</span>
        </div>
      {{/each}}
    </div>
  </template>
}

// Post number next to the date
const PostNum = <template><span class="oh-signal oh-postnum">#{{@outletArgs.post.post_number}}</span></template>;

const AboveSuggested = <template>
  <div class="oh-bottom"><AutoAd @id="oh-ad-topic-bottom" @size="lb" @note="Leaderboard · above suggested" /></div>
</template>;

export default apiInitializer((api) => {
  api.renderAfterWrapperOutlet("post-article", AfterPost);
  api.renderInOutlet("topic-above-post-stream", TopicMap);
  api.renderInOutlet("timeline-footer-controls-after", Participants);
  api.renderInOutlet("topic-title", Crumbs);
  api.renderInOutlet("topic-navigation", Participants);
  api.renderInOutlet("post-meta-data-infos", PostNum);
  api.renderInOutlet("topic-above-suggested", AboveSuggested);
});
