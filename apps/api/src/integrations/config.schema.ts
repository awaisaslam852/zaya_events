import { z } from 'zod';

export const integrationsConfigSchema = z.object({
  FLIGHTS_PROVIDER: z.enum(['mock', 'amadeus']).default('mock'),
  HOTELS_PROVIDER: z.enum(['mock', 'bookingcom']).default('mock'),
  WHATSAPP_PROVIDER: z.enum(['mock', 'cloud']).default('mock'),
  OPENAI_PROVIDER: z.enum(['mock', 'openai']).default('mock'),
  MAPS_PROVIDER: z.enum(['mock', 'google']).default('mock'),
  AMADEUS_CLIENT_ID: z.string().default(''),
  AMADEUS_CLIENT_SECRET: z.string().default(''),
  AMADEUS_HOSTNAME: z.enum(['test', 'production']).default('test'),
  DUFFEL_ACCESS_TOKEN: z.string().default(''),
  BOOKINGCOM_API_KEY: z.string().default(''),
  BOOKINGCOM_AFFILIATE_ID: z.string().default(''),
  EXPEDIA_API_KEY: z.string().default(''),
  EXPEDIA_SHARED_SECRET: z.string().default(''),
  WHATSAPP_TOKEN: z.string().default(''),
  WHATSAPP_PHONE_NUMBER_ID: z.string().default(''),
  WHATSAPP_API_VERSION: z.string().default('v21.0'),
  OPENAI_API_KEY: z.string().default(''),
  OPENAI_MODEL: z.string().default('gpt-4o-mini'),
  GOOGLE_MAPS_API_KEY: z.string().default(''),
});

export type IntegrationsConfig = z.infer<typeof integrationsConfigSchema>;
