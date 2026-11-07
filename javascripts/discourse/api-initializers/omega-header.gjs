import { apiInitializer } from "discourse/lib/api";

const Social = <template>
  <li class="oh-social">
    <a href="https://discord.gg/duelistsunite" target="_blank" rel="noopener noreferrer">Discord</a>
    <a href="https://www.twitch.tv/duelists_unite" target="_blank" rel="noopener noreferrer">Twitch</a>
  </li>
</template>;

export default apiInitializer((api) => {
  api.headerIcons?.add("oh-social", Social, { before: "search" });
  // Core hides the footer on lists that can load more; our design wants it on every page
  api.container.lookup("service:footer")._showFooterOverride = true;
});
