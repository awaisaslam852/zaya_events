# Zaya Events — Figma UI kit

Figma cannot be written as a `.fig` file from this repo. This **plugin** creates a real Figma document: pages, iPhone frames, auto-layout, and editable text so you can polish in Figma.

## Install (Figma Desktop)

1. Open **Figma Desktop** (plugins from disk do not run in the browser).
2. Create a new file, or open any file.
3. Menu: **Plugins → Development → Import plugin from manifest…**
4. Select:

`design/figma-plugin/manifest.json`

5. Menu: **Plugins → Development → Zaya Events — Generate UI**
6. Click **Generate artboards**. Wait until it says Done.

You get five pages:

| Page | Contents |
|---|---|
| 01 Design system | Colors, type, buttons |
| 02 Auth | Login, register, passwords |
| 03 Customer | Home through bookings, visits, AI, profile |
| 04 Vendor | Dashboard, listings, requests, calendar, earnings |
| 05 Calls | Incoming, active audio, history |

## Polish

- Click any frame and edit copy, spacing, or fills.
- Auto-layout is on, so padding and gaps are easy to tweak.
- Swap the merlot photo blocks for real venue images (Fill → Image).
- Optional: Tokens Studio → import `design/tokens/zaya.tokens.json`.

## Fonts

Install **Inter** (Figma has it) and **Playfair Display** (Google Fonts) for serif titles. If Playfair is missing, titles fall back to Inter Bold.
