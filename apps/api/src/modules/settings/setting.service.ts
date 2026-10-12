import { Prisma } from '@prisma/client';
import { NotFoundError } from '../../lib/errors.js';
import { integrationsConfig } from '../../integrations/config.js';
import { env } from '../../config/env.js';
import { APP_CURRENCIES, COUNTRIES } from '../../lib/countries.js';
import { settingRepository } from './setting.repository.js';
import type { z } from 'zod';
import type { settingBody, settingListQuery, settingPatch } from './setting.schema.js';

const CURRENCY_SET = new Set<string>(APP_CURRENCIES);

function settingText(value: unknown, fallback: string): string {
  if (typeof value === 'string' && value.trim()) {
    return value.trim();
  }
  if (value && typeof value === 'object') {
    const rec = value as { currency?: unknown; en?: unknown };
    if (typeof rec.currency === 'string' && rec.currency.trim()) {
      return rec.currency.trim();
    }
    if (typeof rec.en === 'string' && rec.en.trim()) {
      return rec.en.trim();
    }
  }
  return fallback;
}

export const settingService = {
  list(query: z.infer<typeof settingListQuery>) {
    return settingRepository.list(query.group);
  },
  async get(key: string) {
    const row = await settingRepository.findByKey(key);
    if (!row) {
      throw new NotFoundError('Setting not found');
    }
    return row;
  },
  upsert(input: z.infer<typeof settingBody>) {
    return settingRepository.upsert({
      key: input.key,
      group: input.group,
      value: input.value as Prisma.InputJsonValue,
    });
  },
  async update(key: string, input: z.infer<typeof settingPatch>) {
    const row = await this.get(key);
    return settingRepository.update(row.id, {
      ...(input.group ? { group: input.group } : {}),
      ...(input.value !== undefined ? { value: input.value as Prisma.InputJsonValue } : {}),
    });
  },
  async public() {
    const [currencyRow, legacyCurrency, siteRow, platformName] = await Promise.all([
      settingRepository.findByKey('general.currency'),
      settingRepository.findByKey('platform.defaultCurrency'),
      settingRepository.findByKey('general.siteName'),
      settingRepository.findByKey('platform.name'),
    ]);
    const requested = settingText(currencyRow?.value, settingText(legacyCurrency?.value, 'AED')).toUpperCase();
    const currency = CURRENCY_SET.has(requested) ? requested : 'AED';
    return {
      currency,
      currencies: APP_CURRENCIES,
      countries: COUNTRIES,
      siteName: settingText(siteRow?.value, settingText(platformName?.value, 'Zaya Events')),
    };
  },
  integrations() {
    return {
      stripe: {
        mode: env.STRIPE_SECRET_KEY ? 'stripe' : 'mock',
        configured: Boolean(env.STRIPE_SECRET_KEY),
      },
      vat: {
        mode: `${env.VAT_RATE}% inclusive`,
        configured: true,
      },
      fcm: Boolean(env.FCM_PROJECT_ID && env.FCM_CLIENT_EMAIL && env.FCM_PRIVATE_KEY),
      whatsapp: {
        mode: integrationsConfig.WHATSAPP_PROVIDER,
        configured: Boolean(integrationsConfig.WHATSAPP_TOKEN && integrationsConfig.WHATSAPP_PHONE_NUMBER_ID),
      },
      openai: {
        mode: integrationsConfig.OPENAI_PROVIDER,
        configured: Boolean(integrationsConfig.OPENAI_API_KEY),
      },
      agora: Boolean(env.AGORA_APP_ID && env.AGORA_APP_CERTIFICATE),
      maps: {
        mode: integrationsConfig.MAPS_PROVIDER,
        configured: Boolean(integrationsConfig.GOOGLE_MAPS_API_KEY),
      },
      flights: {
        mode: integrationsConfig.FLIGHTS_PROVIDER,
        configured: Boolean(integrationsConfig.AMADEUS_CLIENT_ID && integrationsConfig.AMADEUS_CLIENT_SECRET),
      },
      hotels: {
        mode: integrationsConfig.HOTELS_PROVIDER,
        configured: Boolean(integrationsConfig.BOOKINGCOM_API_KEY),
      },
      smtp: Boolean(env.SMTP_HOST),
    };
  },
};
