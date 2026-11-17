/* Zaya Events — Figma generator
 * Run from Plugins > Development after importing this folder's manifest.json
 */
const T = {
  ivory: { r: 246 / 255, g: 241 / 255, b: 232 / 255 },
  ivoryDeep: { r: 239 / 255, g: 230 / 255, b: 216 / 255 },
  cream: { r: 255 / 255, g: 252 / 255, b: 246 / 255 },
  ink: { r: 28 / 255, g: 20 / 255, b: 16 / 255 },
  muted: { r: 122 / 255, g: 106 / 255, b: 92 / 255 },
  gold: { r: 196 / 255, g: 165 / 255, b: 116 / 255 },
  goldSoft: { r: 232 / 255, g: 217 / 255, b: 190 / 255 },
  merlot: { r: 59 / 255, g: 42 / 255, b: 36 / 255 },
  line: { r: 230 / 255, g: 217 / 255, b: 200 / 255 },
  white: { r: 1, g: 1, b: 1 },
  success: { r: 61 / 255, g: 107 / 255, b: 79 / 255 },
  danger: { r: 155 / 255, g: 61 / 255, b: 61 / 255 },
};

const W = 390;
const H = 844;
const GAP = 64;
const COLS = 5;

let serif = { family: "Inter", style: "Bold" };

function solid(c) {
  return [{ type: "SOLID", color: c }];
}

function auto(parent, dir, opts = {}) {
  const f = figma.createFrame();
  f.layoutMode = dir;
  f.fills = opts.fill ? solid(opts.fill) : [];
  f.itemSpacing = opts.gap ?? 0;
  f.paddingLeft = opts.pl ?? opts.pad ?? 0;
  f.paddingRight = opts.pr ?? opts.pad ?? 0;
  f.paddingTop = opts.pt ?? opts.pad ?? 0;
  f.paddingBottom = opts.pb ?? opts.pad ?? 0;
  f.primaryAxisAlignItems = opts.main ?? "MIN";
  f.counterAxisAlignItems = opts.cross ?? "MIN";
  f.layoutAlign = opts.stretch ? "STRETCH" : "INHERIT";
  f.primaryAxisSizingMode = opts.mainFixed ? "FIXED" : "AUTO";
  f.counterAxisSizingMode = opts.crossFixed ? "FIXED" : "AUTO";
  if (opts.w) f.resize(opts.w, opts.h || f.height || 1);
  if (opts.h && !opts.w) {
    f.layoutGrow = opts.grow || 0;
  }
  if (opts.grow) f.layoutGrow = opts.grow;
  if (opts.radius != null) f.cornerRadius = opts.radius;
  if (opts.stroke) {
    f.strokes = solid(opts.stroke);
    f.strokeWeight = opts.sw ?? 1;
  }
  if (opts.name) f.name = opts.name;
  if (opts.clip) f.clipsContent = true;
  parent.appendChild(f);
  if (opts.w && opts.h) f.resize(opts.w, opts.h);
  return f;
}

function txt(parent, chars, opts = {}) {
  const t = figma.createText();
  t.fontName = opts.font || { family: "Inter", style: opts.weight || "Regular" };
  t.characters = String(chars ?? "");
  t.fontSize = opts.size ?? 14;
  t.fills = solid(opts.color || T.ink);
  if (opts.ls) t.letterSpacing = { unit: "PIXELS", value: opts.ls };
  if (opts.lh) t.lineHeight = { unit: "PIXELS", value: opts.lh };
  t.textAlignHorizontal = opts.align || "LEFT";
  t.layoutAlign = opts.stretch ? "STRETCH" : "INHERIT";
  if (opts.grow) t.layoutGrow = opts.grow;
  if (opts.center) t.textAlignHorizontal = "CENTER";
  parent.appendChild(t);
  return t;
}

function box(parent, opts = {}) {
  const r = figma.createRectangle();
  r.fills = solid(opts.fill || T.goldSoft);
  if (opts.w && opts.h) r.resize(opts.w, opts.h);
  r.cornerRadius = opts.radius ?? 0;
  if (opts.stretch) r.layoutAlign = "STRETCH";
  if (opts.h && !opts.w) {
    r.resize(100, opts.h);
    r.layoutAlign = "STRETCH";
  }
  parent.appendChild(r);
  return r;
}

function circle(parent, size, fill) {
  const e = figma.createEllipse();
  e.resize(size, size);
  e.fills = solid(fill || T.merlot);
  parent.appendChild(e);
  return e;
}

function phone(page, name, col, row) {
  const f = figma.createFrame();
  f.name = name;
  f.resize(W, H);
  f.x = col * (W + GAP);
  f.y = row * (H + GAP + 40);
  f.fills = solid(T.ivory);
  f.layoutMode = "VERTICAL";
  f.primaryAxisSizingMode = "FIXED";
  f.counterAxisSizingMode = "FIXED";
  f.itemSpacing = 0;
  f.clipsContent = true;
  f.layoutAlign = "INHERIT";
  page.appendChild(f);
  return f;
}

function statusBar(parent) {
  const row = auto(parent, "HORIZONTAL", {
    name: "Status bar",
    pad: 0,
    pl: 24,
    pr: 24,
    pt: 14,
    pb: 8,
    stretch: true,
    main: "SPACE_BETWEEN",
    cross: "CENTER",
  });
  txt(row, "9:41", { size: 13, weight: "Semi Bold" });
  txt(row, "5G  100%", { size: 12, weight: "Medium", color: T.muted });
  return row;
}

function hero(parent, opts) {
  const h = auto(parent, "VERTICAL", {
    name: "Hero",
    fill: T.merlot,
    pad: 20,
    pt: 8,
    pb: 22,
    gap: 8,
    stretch: true,
  });
  const top = auto(h, "HORIZONTAL", { stretch: true, main: "SPACE_BETWEEN", cross: "CENTER" });
  txt(top, opts.kicker || "ZAYA", { size: 12, weight: "Bold", color: T.gold, ls: 2 });
  if (opts.right) txt(top, opts.right, { size: 12, weight: "Medium", color: T.goldSoft });
  txt(h, opts.title, { size: 26, font: serif, color: T.cream, stretch: true });
  if (opts.sub) txt(h, opts.sub, { size: 13, color: T.goldSoft, stretch: true, lh: 18 });
  return h;
}

function pageHeader(parent, opts) {
  const h = auto(parent, "VERTICAL", {
    name: "Header",
    pad: 20,
    pt: 8,
    pb: 12,
    gap: 4,
    stretch: true,
  });
  const top = auto(h, "HORIZONTAL", { stretch: true, cross: "CENTER", gap: 10 });
  if (opts.back) txt(top, "←", { size: 18, weight: "Medium" });
  txt(top, opts.kicker || "", { size: 11, weight: "Semi Bold", color: T.gold, ls: 1.4, grow: 1 });
  txt(h, opts.title, { size: 24, font: serif, stretch: true });
  if (opts.sub) txt(h, opts.sub, { size: 13, color: T.muted, stretch: true });
  return h;
}

function field(parent, label, value) {
  const wrap = auto(parent, "VERTICAL", { gap: 6, stretch: true, name: "Field / " + label });
  txt(wrap, label.toUpperCase(), { size: 10, weight: "Semi Bold", color: T.muted, ls: 1 });
  const boxF = auto(wrap, "HORIZONTAL", {
    fill: T.cream,
    pad: 14,
    radius: 12,
    stretch: true,
    stroke: T.line,
    cross: "CENTER",
  });
  txt(boxF, value, { size: 14, color: T.ink, grow: 1 });
  return wrap;
}

function primaryBtn(parent, label) {
  const b = auto(parent, "HORIZONTAL", {
    name: "Button / Primary",
    fill: T.gold,
    pad: 14,
    radius: 14,
    stretch: true,
    main: "CENTER",
    cross: "CENTER",
  });
  txt(b, label, { size: 14, weight: "Bold", color: T.merlot, center: true });
  return b;
}

function ghostBtn(parent, label) {
  const b = auto(parent, "HORIZONTAL", {
    name: "Button / Ghost",
    pad: 14,
    radius: 14,
    stretch: true,
    main: "CENTER",
    stroke: T.line,
    sw: 1,
  });
  txt(b, label, { size: 14, weight: "Semi Bold", color: T.merlot, center: true });
  return b;
}

function photo(parent, h, caption) {
  const p = auto(parent, "VERTICAL", {
    name: "Photo",
    fill: T.merlot,
    h,
    stretch: true,
    radius: 16,
    clip: true,
    main: "MAX",
    pad: 12,
  });
  p.resize(p.width || 350, h);
  p.layoutAlign = "STRETCH";
  p.minHeight = h;
  const spacer = figma.createFrame();
  spacer.layoutGrow = 1;
  spacer.fills = [];
  p.insertChild(0, spacer);
  if (caption) txt(p, caption, { size: 11, weight: "Medium", color: T.goldSoft });
  return p;
}

function cardRow(parent, opts) {
  const row = auto(parent, "HORIZONTAL", {
    name: "Card",
    fill: T.cream,
    pad: 12,
    gap: 12,
    radius: 16,
    stretch: true,
    stroke: T.line,
    cross: "CENTER",
  });
  const thumb = figma.createRectangle();
  thumb.resize(64, 64);
  thumb.cornerRadius = 12;
  thumb.fills = solid(opts.thumb || T.merlot);
  row.appendChild(thumb);
  const col = auto(row, "VERTICAL", { gap: 4, grow: 1 });
  txt(col, opts.title, { size: 15, weight: "Semi Bold", stretch: true });
  if (opts.sub) txt(col, opts.sub, { size: 12, color: T.muted, stretch: true });
  if (opts.meta) txt(col, opts.meta, { size: 12, weight: "Bold", color: T.gold, stretch: true });
  return row;
}

function chip(parent, label, on) {
  const c = auto(parent, "HORIZONTAL", {
    fill: on ? T.merlot : T.cream,
    pad: 8,
    pl: 12,
    pr: 12,
    radius: 20,
    stroke: on ? undefined : T.line,
  });
  txt(c, label, { size: 12, weight: "Semi Bold", color: on ? T.goldSoft : T.ink });
  return c;
}

function tabBar(parent, role, selected) {
  const items =
    role === "vendor"
      ? ["Dashboard", "Listings", "Requests", "Chat", "Profile"]
      : ["Home", "Events", "Chat", "Favorites", "Profile"];
  const bar = auto(parent, "HORIZONTAL", {
    name: "Tab bar / " + role,
    fill: T.cream,
    pad: 8,
    pt: 10,
    pb: 18,
    stretch: true,
    stroke: T.line,
  });
  items.forEach((label) => {
    const on = label === selected;
    const cell = auto(bar, "VERTICAL", { grow: 1, gap: 4, cross: "CENTER", radius: 12, fill: on ? T.goldSoft : undefined, pad: 6 });
    txt(cell, on ? "●" : "○", { size: 11, color: on ? T.merlot : T.muted, center: true });
    txt(cell, label, { size: 9, weight: on ? "Bold" : "Medium", color: on ? T.merlot : T.muted, center: true });
  });
  return bar;
}

function body(parent) {
  return auto(parent, "VERTICAL", {
    name: "Body",
    grow: 1,
    pad: 16,
    gap: 12,
    stretch: true,
    clip: true,
  });
}

function placeGrid(frames, page) {
  frames.forEach((frame, i) => {
    const col = i % COLS;
    const row = Math.floor(i / COLS);
    frame.x = 80 + col * (W + GAP);
    frame.y = 120 + row * (H + GAP);
  });
  page.name = page.name;
}

async function loadFonts() {
  const needed = [
    ["Inter", "Regular"],
    ["Inter", "Medium"],
    ["Inter", "Semi Bold"],
    ["Inter", "Bold"],
  ];
  for (const [family, style] of needed) {
    await figma.loadFontAsync({ family, style });
  }
  const serifs = [
    ["Playfair Display", "SemiBold"],
    ["Playfair Display", "Bold"],
    ["Georgia", "Bold"],
  ];
  for (const [family, style] of serifs) {
    try {
      await figma.loadFontAsync({ family, style });
      serif = { family, style };
      break;
    } catch (_) {}
  }
}

function swatch(parent, name, color) {
  const col = auto(parent, "VERTICAL", { gap: 8, w: 120 });
  const s = figma.createRectangle();
  s.resize(120, 72);
  s.cornerRadius = 12;
  s.fills = solid(color);
  col.appendChild(s);
  txt(col, name, { size: 12, weight: "Semi Bold" });
  return col;
}

function buildDesignSystem(page) {
  const board = figma.createFrame();
  board.name = "Design system";
  board.layoutMode = "VERTICAL";
  board.resize(1440, 1100);
  board.primaryAxisSizingMode = "AUTO";
  board.counterAxisSizingMode = "FIXED";
  board.paddingLeft = 64;
  board.paddingRight = 64;
  board.paddingTop = 64;
  board.paddingBottom = 64;
  board.itemSpacing = 28;
  board.fills = solid(T.ivory);
  page.appendChild(board);

  txt(board, "ZAYA EVENTS", { size: 12, weight: "Bold", color: T.gold, ls: 3 });
  txt(board, "Mobile design system", { size: 40, font: serif });
  txt(board, "Luxury Gulf events — ivory, champagne gold, merlot. Use these tokens when polishing screens.", { size: 14, color: T.muted, stretch: true });

  const colors = auto(board, "HORIZONTAL", { gap: 16, name: "Colors" });
  swatch(colors, "Ivory", T.ivory);
  swatch(colors, "Cream", T.cream);
  swatch(colors, "Merlot", T.merlot);
  swatch(colors, "Gold", T.gold);
  swatch(colors, "Ink", T.ink);
  swatch(colors, "Muted", T.muted);

  const type = auto(board, "VERTICAL", { gap: 8, name: "Type" });
  txt(type, "Display  /  Playfair", { size: 32, font: serif });
  txt(type, "UI  /  Inter Medium  ·  14–16  ·  bookings, forms, tabs", { size: 14, color: T.muted });

  const btns = auto(board, "HORIZONTAL", { gap: 16, w: 480 });
  btns.resize(480, 1);
  primaryBtn(btns, "Book this venue");
  ghostBtn(btns, "Send inquiry");

  txt(board, "Polish in Figma: tweak auto-layout padding, swap photo fills, edit copy. Components are named Button / Primary, Card, Tab bar.", { size: 12, color: T.muted, stretch: true });
}

function authLogin() {
  const f = phone(figma.currentPage, "Auth / Login");
  statusBar(f);
  const h = auto(f, "VERTICAL", { fill: T.merlot, pad: 24, pt: 36, pb: 36, gap: 10, stretch: true });
  txt(h, "ZAYA", { size: 13, weight: "Bold", color: T.gold, ls: 4 });
  txt(h, "Events, written softly.", { size: 28, font: serif, color: T.cream, stretch: true });
  txt(h, "Venues, cars, stays and honeymoons across the Gulf.", { size: 13, color: T.goldSoft, stretch: true });
  const b = body(f);
  field(b, "Email", "amira.uae@zayaevents.com");
  field(b, "Password", "••••••••••••");
  primaryBtn(b, "Sign in");
  ghostBtn(b, "Create an account");
  txt(b, "Forgot password", { size: 12, weight: "Medium", color: T.gold, center: true, stretch: true });
  return f;
}

function authRegister(role) {
  const f = phone(figma.currentPage, "Auth / Register " + role);
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Join Zaya", title: role === "vendor" ? "Partner account" : "Create account" });
  const b = body(f);
  field(b, "First name", role === "vendor" ? "Layla" : "Amira");
  field(b, "Email", role === "vendor" ? "venues.uae@zayaevents.com" : "amira.uae@zayaevents.com");
  if (role === "vendor") field(b, "Business", "Palms Celebration Hall");
  field(b, "Country", "United Arab Emirates");
  field(b, "Password", "••••••••••••");
  primaryBtn(b, "Continue");
  return f;
}

function authForgot() {
  const f = phone(figma.currentPage, "Auth / Forgot password");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Account", title: "Reset password", sub: "We’ll email a link if the account exists." });
  const b = body(f);
  field(b, "Email", "amira.uae@zayaevents.com");
  primaryBtn(b, "Send reset link");
  return f;
}

function customerHome() {
  const f = phone(figma.currentPage, "Customer / Home");
  statusBar(f);
  hero(f, {
    kicker: "ZAYA  ·  AE",
    right: "EN | AR",
    title: "Plan a gathering that feels like you.",
    sub: "Venues, cars, stays and honeymoon stories — one place.",
  });
  const b = body(f);
  const search = auto(b, "HORIZONTAL", { fill: T.cream, pad: 14, radius: 14, stroke: T.line, stretch: true, cross: "CENTER" });
  txt(search, "Search Dubai villas, classic cars…", { size: 13, color: T.muted, grow: 1 });
  const chips = auto(b, "HORIZONTAL", { gap: 8, stretch: true });
  ["Venues", "Vendors", "Cars", "Stays"].forEach((c, i) => chip(chips, c, i === 0));
  txt(b, "Featured venues", { size: 16, font: serif });
  cardRow(b, { title: "Palms Celebration Hall", sub: "Dubai · 400 guests", meta: "AED 18,500" });
  cardRow(b, { title: "Noor Garden Villa", sub: "Abu Dhabi · lawn + majlis", meta: "AED 12,000" });
  tabBar(f, "customer", "Home");
  return f;
}

function catalogList(name, title, kicker, items, tab) {
  const f = phone(figma.currentPage, name);
  statusBar(f);
  pageHeader(f, { back: true, kicker, title });
  const b = body(f);
  items.forEach((item) => cardRow(b, item));
  tabBar(f, "customer", tab || "Home");
  return f;
}

function catalogDetail(name, opts) {
  const f = phone(figma.currentPage, name);
  statusBar(f);
  const photoWrap = auto(f, "VERTICAL", { fill: T.merlot, stretch: true, pad: 16, pt: 12, pb: 16, gap: 10 });
  txt(photoWrap, "←", { size: 18, color: T.cream });
  txt(photoWrap, opts.kicker, { size: 11, weight: "Semi Bold", color: T.gold, ls: 1 });
  txt(photoWrap, opts.title, { size: 26, font: serif, color: T.cream, stretch: true });
  txt(photoWrap, opts.place, { size: 13, color: T.goldSoft });
  const b = body(f);
  txt(b, opts.price, { size: 20, weight: "Bold", color: T.gold });
  txt(b, opts.body, { size: 13, color: T.muted, stretch: true, lh: 18 });
  if (opts.facts) {
    opts.facts.forEach((fact) => txt(b, "·  " + fact, { size: 13, color: T.ink, stretch: true }));
  }
  primaryBtn(b, opts.primary || "Book now");
  ghostBtn(b, opts.secondary || "Inquire");
  return f;
}

function eventsList() {
  const f = phone(figma.currentPage, "Customer / Events");
  statusBar(f);
  pageHeader(f, { kicker: "Your occasions", title: "My events", sub: "One event can hold venue, cars and stays." });
  const b = body(f);
  cardRow(b, { title: "Amira & Yusuf — Walima", sub: "18 Apr 2027 · Dubai", meta: "3 bookings" });
  cardRow(b, { title: "Noor’s birthday majlis", sub: "2 Jun 2027 · Sharjah", meta: "Inquiry" });
  primaryBtn(b, "New event");
  tabBar(f, "customer", "Events");
  return f;
}

function eventDetail() {
  const f = phone(figma.currentPage, "Customer / Event detail");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Event", title: "Amira & Yusuf — Walima", sub: "18 April 2027  ·  Dubai" });
  const b = body(f);
  cardRow(b, { title: "Palms Celebration Hall", sub: "Venue · Confirmed", meta: "AED 18,500" });
  cardRow(b, { title: "Rolls Dawn — pearl", sub: "Car · Pending", meta: "AED 2,400" });
  ghostBtn(b, "Add a booking");
  tabBar(f, "customer", "Events");
  return f;
}

function eventEditor() {
  const f = phone(figma.currentPage, "Customer / New event");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Create", title: "New event" });
  const b = body(f);
  field(b, "Name", "Amira & Yusuf — Walima");
  field(b, "Date", "18 April 2027");
  field(b, "City", "Dubai");
  field(b, "Guests", "320");
  primaryBtn(b, "Save event");
  return f;
}

function chatInbox(role) {
  const f = phone(figma.currentPage, role === "vendor" ? "Vendor / Chat inbox" : "Customer / Chat inbox");
  statusBar(f);
  pageHeader(f, { kicker: "Messages", title: "Inbox" });
  const b = body(f);
  cardRow(b, { title: role === "vendor" ? "Amira Hassan" : "Palms Celebration Hall", sub: "We can hold the lawn from 4pm…", meta: "14:02" });
  cardRow(b, { title: "Zaya Support", sub: "Your visit is confirmed.", meta: "Yesterday" });
  tabBar(f, role === "vendor" ? "vendor" : "customer", "Chat");
  return f;
}

function chatThread(role) {
  const f = phone(figma.currentPage, role === "vendor" ? "Vendor / Chat thread" : "Customer / Chat thread");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Chat", title: role === "vendor" ? "Amira Hassan" : "Palms / Layla" });
  const b = body(f);
  const inb = auto(b, "VERTICAL", { fill: T.ivoryDeep, pad: 12, radius: 14, stretch: true });
  txt(inb, "Can we visit Thursday at 11?", { size: 13, stretch: true });
  const out = auto(b, "VERTICAL", { fill: T.merlot, pad: 12, radius: 14, stretch: true });
  txt(out, "Yes — I’ll have the majlis ready, and tea.", { size: 13, color: T.cream, stretch: true });
  const composer = auto(f, "HORIZONTAL", { pad: 12, gap: 8, stretch: true, fill: T.cream, cross: "CENTER" });
  const input = auto(composer, "HORIZONTAL", { grow: 1, fill: T.ivory, pad: 12, radius: 12, stroke: T.line });
  txt(input, "Message…", { size: 13, color: T.muted });
  const send = auto(composer, "HORIZONTAL", { fill: T.gold, pad: 12, radius: 12 });
  txt(send, "Send", { size: 12, weight: "Bold", color: T.merlot });
  return f;
}

function favorites() {
  const f = phone(figma.currentPage, "Customer / Favorites");
  statusBar(f);
  pageHeader(f, { kicker: "Saved", title: "Favorites" });
  const b = body(f);
  cardRow(b, { title: "Palms Celebration Hall", sub: "Venue · Dubai", meta: "Saved" });
  cardRow(b, { title: "Coastal honeymoon, Muscat", sub: "Honeymoon · 7 nights", meta: "Saved" });
  tabBar(f, "customer", "Favorites");
  return f;
}

function profile(role) {
  const f = phone(figma.currentPage, role === "vendor" ? "Vendor / Profile" : "Customer / Profile");
  statusBar(f);
  pageHeader(f, { kicker: "Account", title: role === "vendor" ? "Layla Al Farsi" : "Amira Hassan" });
  const b = body(f);
  const id = auto(b, "HORIZONTAL", { gap: 12, stretch: true, cross: "CENTER", fill: T.cream, pad: 14, radius: 16, stroke: T.line });
  circle(id, 56, T.merlot);
  const col = auto(id, "VERTICAL", { gap: 4, grow: 1 });
  txt(col, role === "vendor" ? "Palms Celebration Hall" : "Amira Hassan", { size: 16, weight: "Semi Bold" });
  txt(col, role === "vendor" ? "Partner · UAE" : "Customer · UAE", { size: 12, color: T.muted });
  ["Edit profile", "Notifications", "Language  ·  EN | AR", "Call history", "Settings"].forEach((row) => {
    const r = auto(b, "HORIZONTAL", { stretch: true, pad: 14, radius: 12, fill: T.cream, stroke: T.line, main: "SPACE_BETWEEN" });
    txt(r, row, { size: 14, weight: "Medium" });
    txt(r, "›", { size: 16, color: T.muted });
  });
  tabBar(f, role === "vendor" ? "vendor" : "customer", "Profile");
  return f;
}

function simpleForm(name, title, kicker, fields, cta) {
  const f = phone(figma.currentPage, name);
  statusBar(f);
  pageHeader(f, { back: true, kicker, title });
  const b = body(f);
  fields.forEach(([l, v]) => field(b, l, v));
  primaryBtn(b, cta);
  return f;
}

function notifications() {
  const f = phone(figma.currentPage, "Customer / Notifications");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Alerts", title: "Notifications" });
  const b = body(f);
  cardRow(b, { title: "Booking accepted", sub: "Palms confirmed ZY-2026-44120", meta: "Now" });
  cardRow(b, { title: "New message", sub: "Layla: Thursday at 11 works.", meta: "1h" });
  cardRow(b, { title: "Visit approved", sub: "Venue walkthrough this week", meta: "Yesterday" });
  return f;
}

function bookingsList() {
  const f = phone(figma.currentPage, "Customer / Bookings");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Planning", title: "Bookings" });
  const b = body(f);
  cardRow(b, { title: "ZY-2026-44120", sub: "Palms Celebration Hall · Confirmed", meta: "AED 18,500" });
  cardRow(b, { title: "ZY-2026-44188", sub: "Rolls Dawn · Pending", meta: "AED 2,400" });
  return f;
}

function bookingDetail() {
  const f = phone(figma.currentPage, "Customer / Booking detail");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "ZY-2026-44120", title: "Palms Celebration Hall", sub: "18 Apr 2027  ·  Confirmed" });
  const b = body(f);
  txt(b, "Deposit paid  ·  AED 5,550", { size: 14, weight: "Semi Bold", color: T.gold });
  txt(b, "Balance due 14 days before the walima. Chat with Layla for floor plan and catering notes.", { size: 13, color: T.muted, stretch: true, lh: 18 });
  primaryBtn(b, "Message vendor");
  ghostBtn(b, "Voice call");
  return f;
}

function visits() {
  const f = phone(figma.currentPage, "Customer / Venue visits");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Walkthroughs", title: "Venue visits" });
  const b = body(f);
  cardRow(b, { title: "Palms Celebration Hall", sub: "Thu 11:00  ·  Confirmed", meta: "Layla" });
  cardRow(b, { title: "Noor Garden Villa", sub: "Requested", meta: "Pending" });
  return f;
}

function visitDetail() {
  const f = phone(figma.currentPage, "Customer / Visit detail");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Visit", title: "Thursday, 11:00", sub: "Palms Celebration Hall" });
  const b = body(f);
  txt(b, "Meet Layla at the main majlis. Parking under the palms.", { size: 13, color: T.muted, stretch: true, lh: 18 });
  primaryBtn(b, "Add to calendar");
  ghostBtn(b, "Cancel visit");
  return f;
}

function aiPlanner() {
  const f = phone(figma.currentPage, "Customer / AI planner");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Atelier", title: "AI planner", sub: "Describe the gathering. We’ll sketch a plan." });
  const b = body(f);
  field(b, "Tell Zaya", "Walima for 320 in Dubai, garden feel, golden hour, classic cars.");
  primaryBtn(b, "Compose a plan");
  const out = auto(b, "VERTICAL", { fill: T.cream, pad: 14, radius: 16, gap: 8, stretch: true, stroke: T.line });
  txt(out, "Suggested path", { size: 14, weight: "Semi Bold" });
  txt(out, "1. Palms Celebration Hall  ·  lawn + indoor\n2. Two Dawn convertibles  ·  pearl\n3. Guest stay at Creek residences", { size: 13, color: T.muted, stretch: true, lh: 18 });
  return f;
}

function incomingCall() {
  const f = phone(figma.currentPage, "Calls / Incoming");
  f.fills = solid(T.merlot);
  statusBar(f);
  const b = auto(f, "VERTICAL", { grow: 1, pad: 32, gap: 12, stretch: true, main: "CENTER", cross: "CENTER" });
  circle(b, 96, T.gold);
  txt(b, "Palms / Layla", { size: 24, font: serif, color: T.cream, center: true, stretch: true });
  txt(b, "Incoming voice call", { size: 14, color: T.goldSoft, center: true, stretch: true });
  const actions = auto(f, "HORIZONTAL", { pad: 28, pb: 48, stretch: true, main: "SPACE_BETWEEN" });
  const decline = auto(actions, "VERTICAL", { gap: 8, cross: "CENTER" });
  circle(decline, 64, T.danger);
  txt(decline, "Decline", { size: 12, color: T.goldSoft });
  const accept = auto(actions, "VERTICAL", { gap: 8, cross: "CENTER" });
  circle(accept, 64, T.success);
  txt(accept, "Accept", { size: 12, color: T.goldSoft });
  return f;
}

function activeCall() {
  const f = phone(figma.currentPage, "Calls / Active audio");
  f.fills = solid(T.merlot);
  statusBar(f);
  const b = auto(f, "VERTICAL", { grow: 1, pad: 32, gap: 10, stretch: true, main: "CENTER", cross: "CENTER" });
  txt(b, "Voice", { size: 12, weight: "Semi Bold", color: T.gold, ls: 2 });
  circle(b, 88, T.gold);
  txt(b, "Layla Al Farsi", { size: 24, font: serif, color: T.cream, center: true, stretch: true });
  txt(b, "03:42", { size: 14, color: T.goldSoft });
  const actions = auto(f, "HORIZONTAL", { pad: 24, pb: 40, stretch: true, main: "SPACE_AROUND" });
  ["Mute", "Speaker", "End"].forEach((label) => {
    const c = auto(actions, "VERTICAL", { gap: 8, cross: "CENTER" });
    circle(c, 56, label === "End" ? T.danger : T.ivoryDeep);
    txt(c, label, { size: 11, color: T.goldSoft });
  });
  return f;
}

function callHistory() {
  const f = phone(figma.currentPage, "Calls / History");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Voice", title: "Call history" });
  const b = body(f);
  cardRow(b, { title: "Layla Al Farsi", sub: "Outgoing · 4 min", meta: "Today" });
  cardRow(b, { title: "Amira Hassan", sub: "Missed", meta: "Yesterday" });
  return f;
}

function vendorDashboard() {
  const f = phone(figma.currentPage, "Vendor / Dashboard");
  statusBar(f);
  hero(f, { kicker: "Partner hub", right: "EN | AR", title: "Welcome back, Layla.", sub: "Palms Celebration Hall  ·  Approved" });
  const b = body(f);
  const kpis = auto(b, "HORIZONTAL", { gap: 10, stretch: true });
  [
    ["Earnings", "AED 64,200"],
    ["Requests", "5 new"],
  ].forEach(([l, v]) => {
    const k = auto(kpis, "VERTICAL", { grow: 1, fill: T.cream, pad: 14, radius: 14, gap: 6, stroke: T.line });
    txt(k, l, { size: 11, color: T.muted });
    txt(k, v, { size: 16, weight: "Bold" });
  });
  cardRow(b, { title: "Amira & Yusuf — Walima", sub: "Awaiting confirmation", meta: "Today" });
  cardRow(b, { title: "Calendar", sub: "Block dates, open hours", meta: "Open" });
  tabBar(f, "vendor", "Dashboard");
  return f;
}

function vendorListings() {
  const f = phone(figma.currentPage, "Vendor / Listings");
  statusBar(f);
  pageHeader(f, { kicker: "Inventory", title: "Listings" });
  const b = body(f);
  cardRow(b, { title: "Palms Celebration Hall", sub: "Venue · Live", meta: "Edit" });
  cardRow(b, { title: "Pearl Dawn convertible", sub: "Car · Live", meta: "Edit" });
  primaryBtn(b, "New listing");
  tabBar(f, "vendor", "Listings");
  return f;
}

function listingEditor() {
  const f = phone(figma.currentPage, "Vendor / New listing");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Create", title: "New listing" });
  const b = body(f);
  field(b, "Title", "Palms Celebration Hall");
  field(b, "City", "Dubai");
  field(b, "Starting price", "AED 18,500");
  field(b, "Capacity", "400");
  primaryBtn(b, "Publish");
  return f;
}

function vendorRequests() {
  const f = phone(figma.currentPage, "Vendor / Booking requests");
  statusBar(f);
  pageHeader(f, { kicker: "Inbox", title: "Booking requests", sub: "Accept or decline with one tap." });
  const b = body(f);
  const card = auto(b, "VERTICAL", { fill: T.cream, pad: 14, radius: 16, gap: 10, stretch: true, stroke: T.line });
  txt(card, "ZY-2026-44120", { size: 12, color: T.gold, weight: "Semi Bold" });
  txt(card, "Amira Hassan  ·  Walima", { size: 16, weight: "Semi Bold" });
  txt(card, "18 Apr 2027  ·  320 guests", { size: 13, color: T.muted });
  const row = auto(card, "HORIZONTAL", { gap: 8, stretch: true });
  ghostBtn(row, "Decline");
  primaryBtn(row, "Accept");
  cardRow(b, { title: "ZY-2026-44188", sub: "Car  ·  Pending", meta: "Review" });
  tabBar(f, "vendor", "Requests");
  return f;
}

function vendorCalendar() {
  const f = phone(figma.currentPage, "Vendor / Calendar");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Availability", title: "April 2027" });
  const b = body(f);
  const grid = auto(b, "VERTICAL", { gap: 6, stretch: true, fill: T.cream, pad: 12, radius: 16, stroke: T.line });
  txt(grid, "Su  Mo  Tu  We  Th  Fr  Sa", { size: 11, color: T.muted, stretch: true });
  txt(grid, "          1   2   3   4", { size: 13, stretch: true });
  txt(grid, "5   6   7   8   9  10  11", { size: 13, stretch: true });
  txt(grid, "12  13  14  15  16  17  18 ●", { size: 13, stretch: true });
  txt(b, "18 Apr  ·  Palms reserved for Amira", { size: 13, color: T.muted });
  primaryBtn(b, "Block a date");
  return f;
}

function vendorPackages() {
  const f = phone(figma.currentPage, "Vendor / Packages");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Offers", title: "Packages" });
  const b = body(f);
  cardRow(b, { title: "Walima gold", sub: "Hall + lighting + coordinator", meta: "AED 18,500" });
  cardRow(b, { title: "Garden afternoon", sub: "Lawn only, 120 guests", meta: "AED 9,800" });
  primaryBtn(b, "Add package");
  return f;
}

function vendorReviews() {
  const f = phone(figma.currentPage, "Vendor / Reviews");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Reputation", title: "Reviews", sub: "4.9  ·  36 reviews" });
  const b = body(f);
  cardRow(b, { title: "Amira Hassan", sub: "The majlis felt like home. Layla was precise and kind.", meta: "5.0" });
  cardRow(b, { title: "Noor Al Ali", sub: "Cars arrived early, immaculate.", meta: "5.0" });
  return f;
}

function vendorBusiness() {
  const f = phone(figma.currentPage, "Vendor / Business profile");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "House", title: "Business profile" });
  const b = body(f);
  field(b, "Name", "Palms Celebration Hall");
  field(b, "City", "Dubai");
  field(b, "About", "A palm-lined hall and garden majlis for walimas and bidhs.");
  primaryBtn(b, "Save");
  return f;
}

function vendorEarnings() {
  const f = phone(figma.currentPage, "Vendor / Earnings");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Ledger", title: "Earnings", sub: "Totals only — no commission breakdown." });
  const b = body(f);
  const heroK = auto(b, "VERTICAL", { fill: T.merlot, pad: 18, radius: 16, gap: 6, stretch: true });
  txt(heroK, "This season", { size: 12, color: T.goldSoft });
  txt(heroK, "AED 64,200", { size: 28, font: serif, color: T.cream });
  cardRow(b, { title: "ZY-2026-44120", sub: "Paid", meta: "AED 18,500" });
  cardRow(b, { title: "ZY-2026-43811", sub: "Paid", meta: "AED 9,800" });
  return f;
}

function settings() {
  const f = phone(figma.currentPage, "Shared / Settings");
  statusBar(f);
  pageHeader(f, { back: true, kicker: "Prefs", title: "Settings" });
  const b = body(f);
  field(b, "Language", "English");
  field(b, "Country desk", "United Arab Emirates");
  ghostBtn(b, "Sign out");
  return f;
}

figma.showUI(__html__, { width: 280, height: 180 });

figma.ui.onmessage = async (msg) => {
  if (msg.type !== "generate") return;
  try {
    figma.ui.postMessage({ type: "progress", text: "Loading fonts…" });
    await loadFonts();

    const ds = figma.currentPage;
    ds.name = "01 Design system";
    const auth = figma.createPage();
    auth.name = "02 Auth";
    const customer = figma.createPage();
    customer.name = "03 Customer";
    const vendor = figma.createPage();
    vendor.name = "04 Vendor";
    const calls = figma.createPage();
    calls.name = "05 Calls";

    figma.currentPage = ds;
    figma.ui.postMessage({ type: "progress", text: "Design system…" });
    buildDesignSystem(ds);

    figma.currentPage = auth;
    figma.ui.postMessage({ type: "progress", text: "Auth screens…" });
    const authFrames = [authLogin(), authRegister("customer"), authRegister("vendor"), authForgot(), simpleForm("Auth / Reset password", "Choose a new password", "Account", [["Password", "••••••••"], ["Confirm", "••••••••"]], "Update password")];
    placeGrid(authFrames, auth);

    figma.currentPage = customer;
    figma.ui.postMessage({ type: "progress", text: "Customer screens…" });
    const customerFrames = [
      customerHome(),
      eventsList(),
      eventDetail(),
      eventEditor(),
      catalogList("Customer / Venues", "Venues", "Halls & gardens", [
        { title: "Palms Celebration Hall", sub: "Dubai · 400 guests", meta: "AED 18,500" },
        { title: "Noor Garden Villa", sub: "Abu Dhabi · lawn", meta: "AED 12,000" },
        { title: "Pearl Majlis", sub: "Sharjah · 180 guests", meta: "AED 8,400" },
      ]),
      catalogDetail("Customer / Venue detail", {
        kicker: "Venue  ·  Dubai",
        title: "Palms Celebration Hall",
        place: "Al Barari  ·  400 guests",
        price: "From AED 18,500",
        body: "A palm court, indoor majlis, and a kitchen wing. Built for walimas that move from daylight to lanterns.",
        facts: ["Indoor + garden", "Bridal suite", "Valet"],
      }),
      catalogList("Customer / Vendors", "Vendors", "Houses", [
        { title: "Palms Celebration Hall", sub: "Venues · Dubai", meta: "4.9" },
        { title: "Noor Motors", sub: "Cars · Sharjah", meta: "4.8" },
      ]),
      catalogDetail("Customer / Vendor detail", {
        kicker: "Partner",
        title: "Palms Celebration Hall",
        place: "Layla Al Farsi  ·  Dubai",
        price: "Approved partner",
        body: "A small house for large days. Hall, garden, and a quiet kitchen.",
        primary: "View listings",
        secondary: "Message",
      }),
      catalogList("Customer / Cars", "Cars", "Arrivals", [
        { title: "Rolls Dawn — pearl", sub: "Convertible · 2024", meta: "AED 2,400 / day" },
        { title: "Mercedes S 580", sub: "Sedan · chauffeur", meta: "AED 1,600 / day" },
      ]),
      catalogDetail("Customer / Car detail", {
        kicker: "Car",
        title: "Rolls Dawn — pearl",
        place: "Dubai  ·  with chauffeur",
        price: "AED 2,400 / day",
        body: "Pearl paint, beige hide, for the short road from home to the hall.",
        facts: ["Chauffeur included", "White ribbons on request"],
      }),
      catalogList("Customer / Stays", "Stays", "Guest houses", [
        { title: "Creek residences", sub: "3 BR · Dubai", meta: "AED 1,900 / night" },
        { title: "Al Ain oasis villa", sub: "5 BR", meta: "AED 2,800 / night" },
      ]),
      catalogDetail("Customer / Stay detail", {
        kicker: "Accommodation",
        title: "Creek residences",
        place: "Dubai Creek  ·  3 bedrooms",
        price: "AED 1,900 / night",
        body: "For the family who fly in the night before. Quiet water, morning tea.",
      }),
      catalogList("Customer / Honeymoon", "Honeymoon", "After the walima", [
        { title: "Muscat coastal week", sub: "7 nights  ·  two people", meta: "AED 14,200" },
        { title: "AlUla quiet desert", sub: "5 nights", meta: "AED 18,900" },
      ]),
      catalogDetail("Customer / Honeymoon detail", {
        kicker: "Honeymoon",
        title: "Muscat coastal week",
        place: "Oman  ·  7 nights",
        price: "AED 14,200",
        body: "A slow week: sea at breakfast, mountains by late day.",
        primary: "Request this journey",
      }),
      catalogList("Customer / Flights", "Flights", "Arrivals", [
        { title: "DXB → MCT", sub: "Morning  ·  economy", meta: "AED 640" },
        { title: "RUH → DXB", sub: "Evening", meta: "AED 710" },
      ]),
      catalogDetail("Customer / Flight detail", {
        kicker: "Flight",
        title: "DXB → MCT",
        place: "18 Apr  ·  08:40",
        price: "AED 640",
        body: "Outbound for the honeymoon week. Return open.",
        primary: "Hold seats",
      }),
      catalogList("Customer / Hotels", "Hotels", "Guests from abroad", [
        { title: "Jumeirah Al Naseem", sub: "Madinat  ·  sea", meta: "AED 1,450" },
        { title: "The Chedi Muscat", sub: "Honeymoon wing", meta: "AED 1,820" },
      ]),
      catalogDetail("Customer / Hotel detail", {
        kicker: "Hotel",
        title: "Jumeirah Al Naseem",
        place: "Dubai  ·  king room",
        price: "AED 1,450 / night",
        body: "For uncles flying in. Garden, sea, and a late breakfast.",
      }),
      chatInbox("customer"),
      chatThread("customer"),
      favorites(),
      bookingsList(),
      bookingDetail(),
      visits(),
      visitDetail(),
      aiPlanner(),
      profile("customer"),
      simpleForm("Customer / Edit profile", "Edit profile", "Account", [["First name", "Amira"], ["Last name", "Hassan"], ["Phone", "+971 50 000 0000"]], "Save"),
      notifications(),
      settings(),
    ];
    placeGrid(customerFrames, customer);

    figma.currentPage = vendor;
    figma.ui.postMessage({ type: "progress", text: "Vendor screens…" });
    const vendorFrames = [
      vendorDashboard(),
      vendorListings(),
      listingEditor(),
      vendorRequests(),
      chatInbox("vendor"),
      chatThread("vendor"),
      vendorCalendar(),
      vendorPackages(),
      vendorReviews(),
      vendorBusiness(),
      vendorEarnings(),
      profile("vendor"),
    ];
    placeGrid(vendorFrames, vendor);

    figma.currentPage = calls;
    figma.ui.postMessage({ type: "progress", text: "Call screens…" });
    const callFrames = [incomingCall(), activeCall(), callHistory()];
    placeGrid(callFrames, calls);

    figma.currentPage = ds;
    figma.ui.postMessage({
      type: "done",
      text: "Done. Pages: Design system, Auth, Customer, Vendor, Calls. Close this and polish.",
    });
  } catch (error) {
    figma.ui.postMessage({ type: "error", text: String(error && error.message ? error.message : error) });
  }
};
