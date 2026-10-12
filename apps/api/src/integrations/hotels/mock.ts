import { AppError } from '../../lib/errors.js';
import type { HotelBookingResult, HotelOffer, HotelRoomType, HotelSearchQuery, HotelsProvider } from './provider.js';

const HOTELS: HotelOffer[] = [
  {
    hotelId: 'mock-htl-atlantis',
    name: { en: 'Atlantis The Palm', ar: 'أتلانتس النخلة' },
    description: {
      en: 'Iconic Palm Jumeirah resort with aquapark and ballrooms.',
      ar: 'منتجع شهير في نخلة جميرا مع حديقة مائية وقاعات مناسبات.',
    },
    city: 'Dubai',
    country: 'AE',
    address: { en: 'Crescent Rd, Palm Jumeirah', ar: 'طريق الهلال، نخلة جميرا' },
    latitude: 25.1308,
    longitude: 55.1172,
    starRating: 5,
    amenities: ['wifi', 'pool', 'spa', 'ballroom'],
    provider: 'mock',
  },
  {
    hotelId: 'mock-htl-stregis',
    name: { en: 'The St. Regis Saadiyat Island', ar: 'سانت ريجيس جزيرة السعديات' },
    description: {
      en: 'Beachfront Abu Dhabi hotel suited for wedding weekends.',
      ar: 'فندق شاطئي في أبوظبي مناسب لعطل الزفاف.',
    },
    city: 'Abu Dhabi',
    country: 'AE',
    address: { en: 'Saadiyat Island', ar: 'جزيرة السعديات' },
    latitude: 24.541,
    longitude: 54.436,
    starRating: 5,
    amenities: ['wifi', 'beach', 'kids-club'],
    provider: 'mock',
  },
  {
    hotelId: 'mock-htl-fairmont',
    name: { en: 'Fairmont Amman', ar: 'فيرمونت عمّان' },
    description: {
      en: 'Hilltop rooms overlooking Amman for guest overflow nights.',
      ar: 'غرف مطلة على عمّان لإقامة الضيوف.',
    },
    city: 'Amman',
    country: 'JO',
    address: { en: '6th Circle', ar: 'الدوار السادس' },
    latitude: 31.963,
    longitude: 35.866,
    starRating: 5,
    amenities: ['wifi', 'gym'],
    provider: 'mock',
  },
];

const ROOMS: Record<string, HotelRoomType[]> = {
  'mock-htl-atlantis': [
    {
      roomId: 'atl-deluxe-king',
      name: { en: 'Deluxe King', ar: 'ديلوكس كينغ' },
      occupancy: 2,
      priceAmount: 2100,
      currency: 'AED',
      refundable: true,
    },
    {
      roomId: 'atl-royal-bridge',
      name: { en: 'Royal Bridge Suite', ar: 'جناح الجسر الملكي' },
      occupancy: 4,
      priceAmount: 9800,
      currency: 'AED',
      refundable: false,
    },
  ],
  'mock-htl-stregis': [
    {
      roomId: 'sr-ocean',
      name: { en: 'Ocean View King', ar: 'كينغ بإطلالة بحرية' },
      occupancy: 2,
      priceAmount: 1650,
      currency: 'AED',
      refundable: true,
    },
  ],
  'mock-htl-fairmont': [
    {
      roomId: 'fm-deluxe',
      name: { en: 'Deluxe Room', ar: 'غرفة ديلوكس' },
      occupancy: 2,
      priceAmount: 720,
      currency: 'AED',
      refundable: true,
    },
  ],
};

const bookings = new Map<string, HotelBookingResult>();

export class MockHotelsProvider implements HotelsProvider {
  async search(query: HotelSearchQuery): Promise<HotelOffer[]> {
    const city = query.city?.toLowerCase();
    const country = query.country?.toUpperCase();
    const q = query.q?.toLowerCase();
    return HOTELS.filter((hotel) => {
      if (city && hotel.city.toLowerCase() !== city) {
        return false;
      }
      if (country && hotel.country !== country) {
        return false;
      }
      if (q && !`${hotel.name.en} ${hotel.name.ar}`.toLowerCase().includes(q)) {
        return false;
      }
      return true;
    });
  }

  async getHotel(hotelId: string): Promise<HotelOffer | null> {
    return HOTELS.find((hotel) => hotel.hotelId === hotelId) ?? null;
  }

  async roomTypes(
    hotelId: string,
    _query?: Pick<HotelSearchQuery, 'checkIn' | 'checkOut' | 'rooms' | 'guests'>,
  ): Promise<HotelRoomType[]> {
    return ROOMS[hotelId] ?? [];
  }

  async book(input: {
    hotelId: string;
    roomId: string;
    checkIn: string;
    checkOut: string;
    rooms: number;
    guests: number;
  }): Promise<HotelBookingResult> {
    const rooms = await this.roomTypes(input.hotelId);
    const room = rooms.find((item) => item.roomId === input.roomId) ?? rooms[0];
    if (!room) {
      throw new AppError(404, 'HOTEL_ROOM_NOT_FOUND', 'Room type is not available');
    }
    const confirmation = `HTL${Date.now().toString(36).toUpperCase()}`;
    const nights = Math.max(
      1,
      Math.round((new Date(input.checkOut).getTime() - new Date(input.checkIn).getTime()) / 86_400_000),
    );
    const result: HotelBookingResult = {
      confirmation,
      hotelId: input.hotelId,
      roomId: room.roomId,
      status: 'CONFIRMED',
      totalAmount: room.priceAmount * nights * input.rooms,
      currency: room.currency,
      raw: { mock: true, guests: input.guests },
    };
    bookings.set(confirmation, result);
    return result;
  }

  async cancel(confirmation: string): Promise<{ confirmation: string; status: 'CANCELLED' }> {
    const existing = bookings.get(confirmation);
    if (existing) {
      bookings.set(confirmation, { ...existing, status: 'CANCELLED' });
    }
    return { confirmation, status: 'CANCELLED' };
  }
}
