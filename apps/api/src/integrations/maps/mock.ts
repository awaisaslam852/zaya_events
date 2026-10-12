import type { DirectionsResult, GeocodeResult, LatLng, MapsProvider, PlaceResult } from './provider.js';

export class MockMapsProvider implements MapsProvider {
  async geocode(address: string): Promise<GeocodeResult[]> {
    const lower = address.toLowerCase();
    if (lower.includes('abu dhabi') || lower.includes('أبوظبي')) {
      return [
        {
          formattedAddress: 'Abu Dhabi, United Arab Emirates',
          location: { lat: 24.4539, lng: 54.3773 },
          city: 'Abu Dhabi',
          country: 'AE',
          placeId: 'mock-auh',
        },
      ];
    }
    if (lower.includes('amman') || lower.includes('عمّان') || lower.includes('عمان')) {
      return [
        {
          formattedAddress: 'Amman, Jordan',
          location: { lat: 31.9539, lng: 35.9106 },
          city: 'Amman',
          country: 'JO',
          placeId: 'mock-amm',
        },
      ];
    }
    return [
      {
        formattedAddress: `${address}, Dubai, United Arab Emirates`,
        location: { lat: 25.2048, lng: 55.2708 },
        city: 'Dubai',
        country: 'AE',
        placeId: 'mock-dxb',
      },
    ];
  }

  async reverseGeocode(location: LatLng): Promise<GeocodeResult[]> {
    return this.geocode(`${location.lat},${location.lng}`);
  }

  async places(query: string, near?: LatLng): Promise<PlaceResult[]> {
    const origin = near ?? { lat: 25.2048, lng: 55.2708 };
    return [
      {
        placeId: 'mock-place-1',
        name: query || 'Wedding venue',
        address: 'Downtown Dubai',
        location: origin,
        types: ['lodging', 'point_of_interest'],
        rating: 4.7,
      },
    ];
  }

  async directions(origin: LatLng | string, destination: LatLng | string): Promise<DirectionsResult> {
    return {
      distanceMeters: 12_400,
      durationSeconds: 22 * 60,
      polyline: 'mockpolyline',
      summary: `${typeof origin === 'string' ? origin : 'origin'} → ${typeof destination === 'string' ? destination : 'destination'}`,
    };
  }
}
