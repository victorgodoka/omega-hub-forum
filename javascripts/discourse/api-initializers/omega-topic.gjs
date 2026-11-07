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

const AboveSuggested = <template>
  <div class="oh-bottom"><AutoAd @id="oh-ad-topic-bottom" @size="lb" @note="Leaderboard · above suggested" /></div>
</template>;

export default apiInitializer((api) => {
  api.renderAfterWrapperOutlet("post-article", AfterPost);
  api.renderInOutlet("topic-above-posts", TopicMap);
  api.renderInOutlet("topic-above-suggested", AboveSuggested);
});
