import { env } from '../config/env.js';
import { integrationsConfigSchema, type IntegrationsConfig } from './config.schema.js';

export type { IntegrationsConfig };

function loadIntegrationsConfig(): IntegrationsConfig {
  const parsed = integrationsConfigSchema.safeParse({
    FLIGHTS_PROVIDER: env.FLIGHTS_PROVIDER,
    HOTELS_PROVIDER: env.HOTELS_PROVIDER,
    WHATSAPP_PROVIDER: env.WHATSAPP_PROVIDER,
    OPENAI_PROVIDER: env.OPENAI_PROVIDER,
    MAPS_PROVIDER: env.MAPS_PROVIDER,
    AMADEUS_CLIENT_ID: env.AMADEUS_CLIENT_ID,
    AMADEUS_CLIENT_SECRET: env.AMADEUS_CLIENT_SECRET,
    AMADEUS_HOSTNAME: env.AMADEUS_HOSTNAME,
    DUFFEL_ACCESS_TOKEN: env.DUFFEL_ACCESS_TOKEN,
    BOOKINGCOM_API_KEY: env.BOOKINGCOM_API_KEY,
    BOOKINGCOM_AFFILIATE_ID: env.BOOKINGCOM_AFFILIATE_ID,
    EXPEDIA_API_KEY: env.EXPEDIA_API_KEY,
    EXPEDIA_SHARED_SECRET: env.EXPEDIA_SHARED_SECRET,
    WHATSAPP_TOKEN: env.WHATSAPP_TOKEN,
    WHATSAPP_PHONE_NUMBER_ID: env.WHATSAPP_PHONE_NUMBER_ID,
    WHATSAPP_API_VERSION: env.WHATSAPP_API_VERSION,
    OPENAI_API_KEY: env.OPENAI_API_KEY,
    OPENAI_MODEL: env.OPENAI_MODEL,
    GOOGLE_MAPS_API_KEY: env.GOOGLE_MAPS_API_KEY,
  });
  if (!parsed.success) {
    throw new Error(`Invalid integrations config: ${JSON.stringify(parsed.error.flatten().fieldErrors)}`);
  }
  return parsed.data;
}

export const integrationsConfig = loadIntegrationsConfig();
