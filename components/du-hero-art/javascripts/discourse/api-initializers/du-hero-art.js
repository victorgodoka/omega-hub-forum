import { apiInitializer } from "discourse/lib/api";

// Duelists Unite: hero art behaviour
// 1. Puts Kurai + ShirAI into the homepage hero as two stacked images: a dark
//    silhouette (at rest) and a lit version that fades in on reveal.
// 2. "Reveal" = mouse hover on desktop. Touch screens have no hover, so there
//    the hero and category cards reveal while they sit in the middle of the
//    screen as you scroll (class du-in-view).

export default apiInitializer((api) => {
  const uploads = settings.theme_uploads || {};
  const canHover = window.matchMedia("(hover: hover) and (pointer: fine)").matches;

  let observer = null;
  if (!canHover && "IntersectionObserver" in window) {
    observer = new IntersectionObserver(
      (entries) =>
        entries.forEach((e) => e.target.classList.toggle("du-in-view", e.isIntersecting)),
      // "in view" = overlapping the middle 40% of the screen
      { rootMargin: "-30% 0px -30% 0px", threshold: 0 }
    );
  }
  const watched = new WeakSet();

  const decorate = () => {
    const hero = document.querySelector(".oh-hero");
    if (
      hero &&
      settings.show_mascots &&
      uploads.mascots &&
      uploads.mascots_lit &&
      !hero.querySelector(".du-mascots")
    ) {
      const wrap = document.createElement("div");
      wrap.className = "du-mascots";
      wrap.setAttribute("aria-hidden", "true");
      for (const [cls, src] of [
        ["du-mascots__dark", uploads.mascots],
        ["du-mascots__lit", uploads.mascots_lit],
      ]) {
        const img = document.createElement("img");
        img.className = cls;
        img.alt = "";
        img.src = src;
        img.decoding = "async";
        wrap.append(img);
      }
      hero.prepend(wrap);
    }

    if (observer) {
      document.querySelectorAll(".oh-hero, .oh-card").forEach((el) => {
        if (!watched.has(el)) {
          watched.add(el);
          observer.observe(el);
        }
      });
    }
  };

  new MutationObserver(decorate).observe(document.body, { childList: true, subtree: true });
  api.onPageChange(decorate);
});
