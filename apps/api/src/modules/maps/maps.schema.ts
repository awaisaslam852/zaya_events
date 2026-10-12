import { z } from 'zod';

export const geocodeQuery = z.object({
  q: z.string().min(1),
});

export const reverseQuery = z.object({
  lat: z.coerce.number(),
  lng: z.coerce.number(),
});

export const placesQuery = z.object({
  q: z.string().min(1),
  lat: z.coerce.number().optional(),
  lng: z.coerce.number().optional(),
});

export const directionsQuery = z.object({
  from: z.string().min(1),
  to: z.string().min(1),
});

export const staticMapQuery = z.object({
  lat: z.coerce.number(),
  lng: z.coerce.number(),
  zoom: z.coerce.number().int().min(1).max(21).default(14),
});
