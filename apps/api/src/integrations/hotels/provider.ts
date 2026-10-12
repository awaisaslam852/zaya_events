export type HotelSearchQuery = {
  city?: string;
  country?: string;
  q?: string;
  checkIn?: string;
  checkOut?: string;
  rooms?: number;
  guests?: number;
};

export type HotelOffer = {
  hotelId: string;
  name: { en: string; ar: string };
  description: { en: string; ar: string };
  city: string;
  country: string;
  address: { en: string; ar: string };
  latitude?: number;
  longitude?: number;
  starRating: number;
  amenities: string[];
  provider: 'mock' | 'bookingcom' | 'expedia';
};

export type HotelRoomType = {
  roomId: string;
  name: { en: string; ar: string };
  occupancy: number;
  priceAmount: number;
  currency: string;
  refundable: boolean;
};

export type HotelBookingResult = {
  confirmation: string;
  hotelId: string;
  roomId: string;
  status: 'PENDING' | 'CONFIRMED' | 'CANCELLED';
  totalAmount: number;
  currency: string;
  raw?: unknown;
};

export interface HotelsProvider {
  search(query: HotelSearchQuery): Promise<HotelOffer[]>;
  getHotel(hotelId: string): Promise<HotelOffer | null>;
  roomTypes(hotelId: string, query?: Pick<HotelSearchQuery, 'checkIn' | 'checkOut' | 'rooms' | 'guests'>): Promise<HotelRoomType[]>;
  book(input: {
    hotelId: string;
    roomId: string;
    checkIn: string;
    checkOut: string;
    rooms: number;
    guests: number;
  }): Promise<HotelBookingResult>;
  cancel(confirmation: string): Promise<{ confirmation: string; status: 'CANCELLED' }>;
}
