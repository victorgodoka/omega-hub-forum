import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { settings } from "virtual:theme";

// ---- Nitro ads ----
const SIZES = {
  lb: [["970", "90"], ["728", "90"], ["320", "100"]],
  half: [["300", "600"], ["300", "250"]],
  rail: [["160", "600"]],
};

function loadNitro() {
  if (!settings.nitro_site_id || document.getElementById("nitro-loader")) {
    return;
  }
  window.nitroAds = window.nitroAds || {
    createAd() {
      return new Promise((r) => window.nitroAds.queue.push(["createAd", arguments, r]));
    },
    addUserToken() {
      window.nitroAds.queue.push(["addUserToken", arguments]);
    },
    queue: [],
  };
  const el = document.createElement("script");
  el.id = "nitro-loader";
  el.async = true;
  el.setAttribute("data-cfasync", "false");
  el.src = `https://s.nitropay.com/ads-${settings.nitro_site_id}.js`;
  document.head.append(el);
}

function boot(id, size) {
  loadNitro();
  window.nitroAds.createAd(id, {
    refreshLimit: 10,
    refreshTime: 30,
    renderVisibleOnly: false,
    refreshVisibleOnly: true,
    sizes: SIZES[size],
    report: { enabled: true, wording: "Report Ad", position: "top-right" },
  });
}

const Slot = <template>
  <aside class="oh-ad oh-ad--{{@size}}" aria-label="Advertisement">
    <span class="oh-signal">Advertisement</span>
    {{#if @live}}
      <div id={{@id}} class="oh-ad__box" {{didInsert (fn boot @id @size)}}></div>
    {{else}}
      <div class="oh-ad__box oh-ad__box--ph">
        <span class="oh-ad__dims">{{@dims}}</span>
        <span class="oh-signal">{{@note}}</span>
      </div>
    {{/if}}
  </aside>
</template>;

export default Slot;

// Self-gating slot: renders nothing unless Nitro is configured (or placeholders are on)
const SPEC = {
  lb: ["970 × 90", "Leaderboard"],
  row: ["728 × 90", "In-feed"],
  rail: ["160 × 600", "Siderail · sticky"],
};
export class AutoAd extends Component {
  get live() {
    return !!settings.nitro_site_id;
  }
  get on() {
    return this.live || settings.ad_show_placeholders;
  }
  get size() {
    return this.args.size === "row" ? "lb" : this.args.size;
  }
  get dims() {
    return SPEC[this.args.size][0];
  }
  get note() {
    return this.args.note || SPEC[this.args.size][1];
  }
  <template>
    {{#if this.on}}
      <Slot @live={{this.live}} @id={{@id}} @size={{this.size}} @dims={{this.dims}} @note={{this.note}} />
    {{/if}}
  </template>
}
