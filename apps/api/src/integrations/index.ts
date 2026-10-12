import { integrationsConfig } from './config.js';
import { AmadeusFlightsProvider } from './flights/amadeus.js';
import { MockFlightsProvider } from './flights/mock.js';
import type { FlightsProvider } from './flights/provider.js';
import { BookingComHotelsProvider } from './hotels/bookingcom.js';
import { MockHotelsProvider } from './hotels/mock.js';
import type { HotelsProvider } from './hotels/provider.js';
import { GoogleMapsProvider } from './maps/google.js';
import { MockMapsProvider } from './maps/mock.js';
import type { MapsProvider } from './maps/provider.js';
import { MockOpenAiProvider } from './openai/mock.js';
import { RealOpenAiProvider } from './openai/openai.js';
import type { OpenAiProvider } from './openai/provider.js';
import { CloudWhatsAppProvider } from './whatsapp/cloud.js';
import { MockWhatsAppProvider } from './whatsapp/mock.js';
import type { WhatsAppProvider } from './whatsapp/provider.js';

function createFlightsProvider(): FlightsProvider {
  return integrationsConfig.FLIGHTS_PROVIDER === 'amadeus' ? new AmadeusFlightsProvider() : new MockFlightsProvider();
}

function createHotelsProvider(): HotelsProvider {
  return integrationsConfig.HOTELS_PROVIDER === 'bookingcom'
    ? new BookingComHotelsProvider()
    : new MockHotelsProvider();
}

function createWhatsAppProvider(): WhatsAppProvider {
  return integrationsConfig.WHATSAPP_PROVIDER === 'cloud' ? new CloudWhatsAppProvider() : new MockWhatsAppProvider();
}

function createOpenAiProvider(): OpenAiProvider {
  return integrationsConfig.OPENAI_PROVIDER === 'openai' ? new RealOpenAiProvider() : new MockOpenAiProvider();
}

function createMapsProvider(): MapsProvider {
  return integrationsConfig.MAPS_PROVIDER === 'google' ? new GoogleMapsProvider() : new MockMapsProvider();
}

/** Swap mock↔real with FLIGHTS_PROVIDER / HOTELS_PROVIDER / WHATSAPP_PROVIDER / OPENAI_PROVIDER / MAPS_PROVIDER. */
export const flightsProvider: FlightsProvider = createFlightsProvider();
export const hotelsProvider: HotelsProvider = createHotelsProvider();
export const whatsappProvider: WhatsAppProvider = createWhatsAppProvider();
export const openaiProvider: OpenAiProvider = createOpenAiProvider();
export const mapsProvider: MapsProvider = createMapsProvider();
