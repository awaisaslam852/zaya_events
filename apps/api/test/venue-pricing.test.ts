import { billableGuests, quoteVenueAmount } from '../src/lib/venue-pricing.js';

describe('venue pricing', () => {
  it('bills hall hire as a flat event fee', () => {
    expect(
      quoteVenueAmount({
        startingPrice: 80000,
        pricingModel: 'HIRE',
        capacityMin: 50,
        guestCount: 120,
      }),
    ).toBe(80000);
  });

  it('bills per-guest rates with a minimum guaranteed headcount', () => {
    expect(billableGuests(20, 50)).toBe(50);
    expect(billableGuests(80, 50)).toBe(80);
    expect(
      quoteVenueAmount({
        startingPrice: 2500,
        pricingModel: 'PER_GUEST',
        capacityMin: 50,
        guestCount: 80,
      }),
    ).toBe(200000);
  });

  it('prefers an explicit package over the starting price', () => {
    expect(
      quoteVenueAmount({
        startingPrice: 80000,
        pricingModel: 'HYBRID',
        capacityMin: 50,
        guestCount: 100,
        packages: [
          { id: 'hire', priceAmount: 90000, pricingUnit: 'EVENT', guestCountMin: 50, isActive: true },
          { id: 'gold', priceAmount: 3500, pricingUnit: 'GUEST', guestCountMin: 80, isActive: true },
        ],
        packageId: 'gold',
      }),
    ).toBe(350000);
  });
});
