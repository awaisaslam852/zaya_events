import type { z } from 'zod';
import { handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { env } from '../../config/env.js';
import { integrationsConfig } from '../../integrations/config.js';
import { mapsProvider } from '../../integrations/index.js';
import type { directionsQuery, geocodeQuery, placesQuery, reverseQuery, staticMapQuery } from './maps.schema.js';

function parsePoint(value: string): { lat: number; lng: number } | string {
  const parts = value.split(',').map((part) => Number(part.trim()));
  const lat = parts[0];
  const lng = parts[1];
  if (lat !== undefined && lng !== undefined && Number.isFinite(lat) && Number.isFinite(lng)) {
    return { lat, lng };
  }
  return value;
}

export const mapsController = {
  config: handle(async (_req, res) => {
    sendSuccess(res, {
      provider: integrationsConfig.MAPS_PROVIDER,
      live: integrationsConfig.MAPS_PROVIDER === 'google' && Boolean(integrationsConfig.GOOGLE_MAPS_API_KEY),
    });
  }),
  geocode: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof geocodeQuery>;
    sendSuccess(res, { items: await mapsProvider.geocode(query.q) });
  }),
  reverse: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof reverseQuery>;
    sendSuccess(res, { items: await mapsProvider.reverseGeocode({ lat: query.lat, lng: query.lng }) });
  }),
  places: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof placesQuery>;
    const near = query.lat != null && query.lng != null ? { lat: query.lat, lng: query.lng } : undefined;
    sendSuccess(res, { items: await mapsProvider.places(query.q, near) });
  }),
  directions: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof directionsQuery>;
    sendSuccess(res, await mapsProvider.directions(parsePoint(query.from), parsePoint(query.to)));
  }),
  staticMap: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof staticMapQuery>;
    if (!env.GOOGLE_MAPS_API_KEY) {
      res.status(204).end();
      return;
    }
    const url = new URL('https://maps.googleapis.com/maps/api/staticmap');
    url.searchParams.set('center', `${query.lat},${query.lng}`);
    url.searchParams.set('zoom', String(query.zoom));
    url.searchParams.set('size', '640x320');
    url.searchParams.set('markers', `color:0x003580|${query.lat},${query.lng}`);
    url.searchParams.set('key', env.GOOGLE_MAPS_API_KEY);
    res.redirect(url.toString());
  }),
};
