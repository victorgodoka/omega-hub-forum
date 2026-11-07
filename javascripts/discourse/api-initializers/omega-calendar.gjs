import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  api.onPageChange((url) => {
    if (/^\/upcoming-events(?:[/?#]|$)/.test(url)) {
      window.location.replace("https://omega.duelistsunite.org/calendar");
    }
  });
});
