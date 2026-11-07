import Component from "@glimmer/component";
import { service } from "@ember/service";
import { AutoAd } from "../../components/oh-ad";

// Ads on the flat topic lists (latest, top, new, unread...). Home and categories have their own connectors.
export default class OmegaLatest extends Component {
  @service router;

  get show() {
    const r = this.router.currentRouteName || "";
    return /^discovery\./.test(r) && !/categor/i.test(r);
  }

  <template>
    {{#if this.show}}
      <div class="oh-latest__top"><AutoAd @id="oh-ad-latest-top" @size="lb" @note="Leaderboard · topic list top" /></div>
      <div class="oh-rail oh-rail--l"><AutoAd @id="oh-ad-latest-rail-l" @size="rail" /></div>
      <div class="oh-rail oh-rail--r"><AutoAd @id="oh-ad-latest-rail-r" @size="rail" /></div>
      <div class="oh-latest__bottom"><AutoAd @id="oh-ad-latest-bottom" @size="lb" @note="Leaderboard · before footer" /></div>
    {{/if}}
  </template>
}
