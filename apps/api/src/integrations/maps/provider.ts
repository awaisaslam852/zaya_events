export type LatLng = { lat: number; lng: number };

export type GeocodeResult = {
  formattedAddress: string;
  location: LatLng;
  placeId?: string;
  city?: string;
  country?: string;
};

export type PlaceResult = {
  placeId: string;
  name: string;
  address: string;
  location: LatLng;
  types: string[];
  rating?: number;
};

export type DirectionsResult = {
  distanceMeters: number;
  durationSeconds: number;
  polyline: string;
  summary: string;
};

export interface MapsProvider {
  geocode(address: string): Promise<GeocodeResult[]>;
  reverseGeocode(location: LatLng): Promise<GeocodeResult[]>;
  places(query: string, near?: LatLng): Promise<PlaceResult[]>;
  directions(origin: LatLng | string, destination: LatLng | string): Promise<DirectionsResult>;
}
