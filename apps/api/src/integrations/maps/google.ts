import { integrationsConfig } from '../config.js';
import { logger } from '../../lib/logger.js';
import { MockMapsProvider } from './mock.js';
import type { DirectionsResult, GeocodeResult, LatLng, MapsProvider, PlaceResult } from './provider.js';

function point(value: LatLng | string): string {
  return typeof value === 'string' ? value : `${value.lat},${value.lng}`;
}

export class GoogleMapsProvider implements MapsProvider {
  private readonly fallback = new MockMapsProvider();

  private ready(): boolean {
    return Boolean(integrationsConfig.GOOGLE_MAPS_API_KEY);
  }

  private async getJson(url: URL): Promise<Record<string, unknown>> {
    url.searchParams.set('key', integrationsConfig.GOOGLE_MAPS_API_KEY);
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Google Maps HTTP ${response.status}`);
    }
    return (await response.json()) as Record<string, unknown>;
  }

  private mapGeocode(results: Array<Record<string, unknown>>): GeocodeResult[] {
    return results.map((row) => {
      const geometry = row.geometry as { location?: { lat?: number; lng?: number } } | undefined;
      const components = (row.address_components as Array<{ types?: string[]; long_name?: string; short_name?: string }>) ?? [];
      const city = components.find((part) => part.types?.includes('locality'))?.long_name;
      const country = components.find((part) => part.types?.includes('country'))?.short_name;
      return {
        formattedAddress: String(row.formatted_address ?? ''),
        location: { lat: Number(geometry?.location?.lat ?? 0), lng: Number(geometry?.location?.lng ?? 0) },
        placeId: row.place_id ? String(row.place_id) : undefined,
        city,
        country,
      };
    });
  }

  async geocode(address: string): Promise<GeocodeResult[]> {
    if (!this.ready()) {
      return this.fallback.geocode(address);
    }
    try {
      const url = new URL('https://maps.googleapis.com/maps/api/geocode/json');
      url.searchParams.set('address', address);
      const json = await this.getJson(url);
      const results = (json.results as Array<Record<string, unknown>> | undefined) ?? [];
      return results.length ? this.mapGeocode(results) : this.fallback.geocode(address);
    } catch (error) {
      logger.warn({ err: error }, 'Google geocode failed');
      return this.fallback.geocode(address);
    }
  }

  async reverseGeocode(location: LatLng): Promise<GeocodeResult[]> {
    if (!this.ready()) {
      return this.fallback.reverseGeocode(location);
    }
    try {
      const url = new URL('https://maps.googleapis.com/maps/api/geocode/json');
      url.searchParams.set('latlng', `${location.lat},${location.lng}`);
      const json = await this.getJson(url);
      const results = (json.results as Array<Record<string, unknown>> | undefined) ?? [];
      return results.length ? this.mapGeocode(results) : this.fallback.reverseGeocode(location);
    } catch (error) {
      logger.warn({ err: error }, 'Google reverse geocode failed');
      return this.fallback.reverseGeocode(location);
    }
  }

  async places(query: string, near?: LatLng): Promise<PlaceResult[]> {
    if (!this.ready()) {
      return this.fallback.places(query, near);
    }
    try {
      const url = new URL('https://maps.googleapis.com/maps/api/place/textsearch/json');
      url.searchParams.set('query', query);
      if (near) {
        url.searchParams.set('location', `${near.lat},${near.lng}`);
        url.searchParams.set('radius', '15000');
      }
      const json = await this.getJson(url);
      const results = (json.results as Array<Record<string, unknown>> | undefined) ?? [];
      if (results.length === 0) {
        return this.fallback.places(query, near);
      }
      return results.map((row) => {
        const geometry = row.geometry as { location?: { lat?: number; lng?: number } } | undefined;
        return {
          placeId: String(row.place_id ?? ''),
          name: String(row.name ?? query),
          address: String(row.formatted_address ?? ''),
          location: { lat: Number(geometry?.location?.lat ?? 0), lng: Number(geometry?.location?.lng ?? 0) },
          types: Array.isArray(row.types) ? (row.types as string[]) : [],
          rating: row.rating ? Number(row.rating) : undefined,
        };
      });
    } catch (error) {
      logger.warn({ err: error }, 'Google places failed');
      return this.fallback.places(query, near);
    }
  }

  async directions(origin: LatLng | string, destination: LatLng | string): Promise<DirectionsResult> {
    if (!this.ready()) {
      return this.fallback.directions(origin, destination);
    }
    try {
      const url = new URL('https://maps.googleapis.com/maps/api/directions/json');
      url.searchParams.set('origin', point(origin));
      url.searchParams.set('destination', point(destination));
      const json = await this.getJson(url);
      const route = (json.routes as Array<Record<string, unknown>> | undefined)?.[0];
      const leg = (route?.legs as Array<Record<string, unknown>> | undefined)?.[0];
      if (!route || !leg) {
        return this.fallback.directions(origin, destination);
      }
      const distance = leg.distance as { value?: number } | undefined;
      const duration = leg.duration as { value?: number } | undefined;
      const overview = route.overview_polyline as { points?: string } | undefined;
      return {
        distanceMeters: Number(distance?.value ?? 0),
        durationSeconds: Number(duration?.value ?? 0),
        polyline: overview?.points ?? '',
        summary: String(route.summary ?? ''),
      };
    } catch (error) {
      logger.warn({ err: error }, 'Google directions failed');
      return this.fallback.directions(origin, destination);
    }
  }
}
