import { apiInitializer } from "discourse/lib/api";

const API = "https://godokaapi.duelistsunite.org/calendar";
const MAX = 4;
const cache = new Map(); // "from|to" -> Promise<entries>

const ymd = (d) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
const hm = (d) =>
  d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false });

function load(from, to) {
  const key = `${from}|${to}`;
  if (!cache.has(key)) {
    cache.set(
      key,
      fetch(`${API}?from=${from}&to=${to}`)
        .then((r) => r.json())
        .then((j) => j.entries || [])
        .catch(() => {
          cache.delete(key); // retry next time
          return [];
        })
    );
  }
  return cache.get(key);
}

function chip(e) {
  const t = new Date(e.startsAt);
  const el = document.createElement(e.url ? "a" : "span");
  el.className = `oh-cal-ev oh-cal-ev--${e.status}`;
  if (e.url) {
    el.href = `https://omega.duelistsunite.org/tournament${e.url}`;
    el.target = "_blank";
    el.rel = "noopener";
  }
  el.title = [e.format, e.banlist, e.structure, e.players != null && `${e.players} players`]
    .filter(Boolean)
    .join(" · ");
  el.textContent = `${hm(t)} ${e.format}`;
  return el;
}

async function paint() {
  const cells = [...document.querySelectorAll(".fc-daygrid-day[data-date]")];
  if (!cells.length) {
    return;
  }
  const from = cells[0].dataset.date;
  const last = new Date(`${cells.at(-1).dataset.date}T00:00:00`);
  last.setDate(last.getDate() + 1);
  const entries = await load(from, ymd(last));

  const byDay = {};
  for (const e of entries) {
    (byDay[ymd(new Date(e.startsAt))] ||= []).push(e);
  }
  for (const cell of document.querySelectorAll(".fc-daygrid-day[data-date]")) {
    const host = cell.querySelector(".fc-daygrid-day-events");
    if (!host || host.querySelector(".oh-cal-list")) {
      continue;
    }
    const list = (byDay[cell.dataset.date] || []).sort((a, b) =>
      a.startsAt.localeCompare(b.startsAt)
    );
    const wrap = document.createElement("div");
    wrap.className = "oh-cal-list";
    list.slice(0, MAX).forEach((e) => wrap.append(chip(e)));
    if (list.length > MAX) {
      const more = document.createElement("span");
      more.className = "oh-cal-more";
      more.textContent = `+${list.length - MAX} more`;
      more.title = list.slice(MAX).map((e) => `${hm(new Date(e.startsAt))} ${e.format}`).join("\n");
      wrap.append(more);
    }
    host.prepend(wrap);
  }
}

export default apiInitializer((api) => {
  let observer;
  api.onPageChange((url) => {
    observer?.disconnect();
    if (!url.startsWith("/upcoming-events")) {
      return;
    }
    // FullCalendar replaces cells on month change; repaint whenever they do.
    let raf;
    observer = new MutationObserver(() => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(paint);
    });
    observer.observe(document.getElementById("main-outlet"), { childList: true, subtree: true });
    paint();
  });
});
