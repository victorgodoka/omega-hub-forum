import { apiInitializer } from "discourse/lib/api";

// Touch devices reveal category art as it enters the usable viewport. Pointer
// devices use CSS hover instead. Rescan when Discourse replaces route content.
export default apiInitializer((api) => {
  const touch = window.matchMedia("(hover: none), (pointer: coarse)");
  const cards = new Set();
  let observer;
  let frame;

  const scan = () => {
    frame = null;
    for (const card of cards) {
      if (!touch.matches || !card.isConnected) {
        observer?.unobserve(card);
        card.classList.remove("is-art-visible");
        cards.delete(card);
      }
    }
    if (!touch.matches) return;
    if (!observer && "IntersectionObserver" in window) {
      observer = new IntersectionObserver((entries) => {
        for (const entry of entries) {
          entry.target.classList.toggle("is-art-visible", touch.matches && entry.isIntersecting && entry.intersectionRatio >= 0.35);
        }
      }, { rootMargin: "-80px 0px -10% 0px", threshold: [0, 0.35] });
    }
    document.querySelectorAll(".oh-card--block").forEach((card) => {
      if (cards.has(card)) return;
      cards.add(card);
      if (observer) observer.observe(card);
      else card.classList.add("is-art-visible");
    });
  };
  const schedule = () => {
    if (frame == null) frame = requestAnimationFrame(scan);
  };
  new MutationObserver(schedule).observe(document.body, { childList: true, subtree: true });
  touch.addEventListener("change", schedule);
  api.onPageChange(schedule);
  schedule();
});
