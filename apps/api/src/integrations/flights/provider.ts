export type FlightCabin = 'ECONOMY' | 'PREMIUM_ECONOMY' | 'BUSINESS' | 'FIRST';

export type FlightSearchQuery = {
  origin: string;
  destination: string;
  departureDate: string;
  returnDate?: string;
  adults?: number;
  cabin?: FlightCabin;
};

export type FlightOffer = {
  offerId: string;
  carrierCode: string;
  flightNumber: string;
  origin: string;
  destination: string;
  departureAt: string;
  arrivalAt: string;
  cabin: FlightCabin;
  seatsLeft: number;
  priceAmount: number;
  currency: string;
  provider: 'mock' | 'amadeus' | 'duffel';
};

export type FlightPassenger = {
  firstName: string;
  lastName: string;
  dateOfBirth?: string;
};

export type FlightBookingResult = {
  pnr: string;
  offerId: string;
  status: 'PENDING' | 'TICKETED' | 'CANCELLED';
  totalAmount: number;
  currency: string;
  raw?: unknown;
};

export interface FlightsProvider {
  search(query: FlightSearchQuery): Promise<FlightOffer[]>;
  getOffer(offerId: string): Promise<FlightOffer | null>;
  book(offerId: string, passengers: FlightPassenger[]): Promise<FlightBookingResult>;
  cancel(pnr: string): Promise<{ pnr: string; status: 'CANCELLED' }>;
}
