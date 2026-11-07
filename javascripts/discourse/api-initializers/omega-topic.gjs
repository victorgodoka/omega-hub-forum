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

const Rails = <template>
  <div class="oh-rail oh-rail--l"><AutoAd @id="oh-ad-topic-rail-l" @size="rail" /></div>
  <div class="oh-rail oh-rail--r"><AutoAd @id="oh-ad-topic-rail-r" @size="rail" /></div>
</template>;

const AboveSuggested = <template>
  <div class="oh-bottom"><AutoAd @id="oh-ad-topic-bottom" @size="lb" @note="Leaderboard · above suggested" /></div>
</template>;

export default apiInitializer((api) => {
  api.renderAfterWrapperOutlet("post-article", AfterPost);
  api.renderInOutlet("topic-above-posts", Rails);
  api.renderInOutlet("topic-above-suggested", AboveSuggested);
});
