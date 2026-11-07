import Component from "@glimmer/component";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { action } from "@ember/object";

// Sidebar from the Messages design: New Message + Personal inbox + group inboxes
export default class OmegaMailboxes extends Component {
  @service router;
  @service currentUser;
  @service composer;

  get base() {
    const m = (this.router.currentURL || "").match(/^\/u\/([^/]+)\/messages/);
    return `/u/${m ? m[1] : this.currentUser.username}/messages`;
  }

  get boxes() {
    const url = (this.router.currentURL || "").split("?")[0];
    const groups = (this.currentUser.groups || [])
      .filter((g) => g.has_messages)
      .map((g) => ({ name: g.name, url: `${this.base}/group/${g.name}` }));
    return [{ name: "Inbox", url: this.base, personal: true }, ...groups].map((b) => ({
      ...b,
      current: b.personal ? url === this.base || /\/(sent|new|unread|archive)$/.test(url) && !url.includes("/group/") : url.startsWith(b.url),
    }));
  }

  @action
  compose() {
    this.composer.openNewMessage({ title: "", body: "" });
  }

  <template>
    <aside class="oh-mbox" aria-label="Mailboxes">
      <button type="button" class="btn btn-primary" {{on "click" this.compose}}>New Message</button>
      <nav>
        <span class="oh-signal">Mailboxes</span>
        {{#each this.boxes as |b|}}
          <a href={{b.url}} class="oh-mbox__a {{if b.current 'is-current'}}" aria-current={{if b.current "page"}}>{{b.name}}</a>
        {{/each}}
      </nav>
    </aside>
  </template>
}
