import Component from "@glimmer/component";
import { service } from "@ember/service";
import { AutoAd } from "../../components/oh-ad";

export default class OmegaCategoryBottom extends Component {
  @service router;

  get show() {
    return /^discovery\..*[cC]ategory/.test(this.router.currentRouteName || "");
  }

  <template>
    {{#if this.show}}
      <div class="oh-bottom"><AutoAd @id="oh-ad-cat-bottom" @size="lb" @note="Leaderboard · before footer" /></div>
    {{/if}}
  </template>
}
