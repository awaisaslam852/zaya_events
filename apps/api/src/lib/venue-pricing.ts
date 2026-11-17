export type VenuePricingModel = 'HIRE' | 'PER_GUEST' | 'HYBRID';
export type VenuePackageUnit = 'EVENT' | 'GUEST';

export type VenuePackageQuote = {
  id?: string;
  priceAmount?: unknown;
  pricingUnit?: string | null;
  guestCountMin?: number | null;
  isActive?: boolean | null;
  deletedAt?: Date | string | null;
};

export type VenueQuoteInput = {
  startingPrice?: unknown;
  pricingModel?: string | null;
  currency?: string | null;
  capacityMin?: number | null;
  packages?: VenuePackageQuote[] | null;
  packageId?: string | null;
  guestCount?: number | null;
};

function money(value: unknown): number {
  const amount = Number(value ?? 0);
  return Number.isFinite(amount) && amount > 0 ? Math.round(amount * 100) / 100 : 0;
}

function asUnit(value: string | null | undefined, fallback: VenuePackageUnit): VenuePackageUnit {
  return value === 'GUEST' || value === 'EVENT' ? value : fallback;
}

export function activeVenuePackages(packages: VenuePackageQuote[] | null | undefined): VenuePackageQuote[] {
  return (packages ?? []).filter((item) => item.isActive !== false && !item.deletedAt);
}

export function venuePackageUnit(pkg: VenuePackageQuote | undefined, model?: string | null): VenuePackageUnit {
  if (pkg?.pricingUnit === 'GUEST' || pkg?.pricingUnit === 'EVENT') {
    return pkg.pricingUnit;
  }
  return model === 'PER_GUEST' ? 'GUEST' : 'EVENT';
}

export function billableGuests(guestCount: number | null | undefined, minimum: number | null | undefined): number {
  const guests = Number(guestCount ?? 0);
  const floor = Number(minimum ?? 0);
  return Math.max(guests > 0 ? guests : floor > 0 ? floor : 1, floor > 0 ? floor : 1);
}

export function quoteVenueAmount(input: VenueQuoteInput): number {
  const packages = activeVenuePackages(input.packages);
  const selected = input.packageId ? packages.find((item) => item.id === input.packageId) : packages[0];
  const model = (input.pricingModel ?? 'HYBRID') as VenuePricingModel;
  if (selected) {
    const amount = money(selected.priceAmount);
    if (venuePackageUnit(selected, model) === 'GUEST') {
      return amount * billableGuests(input.guestCount, selected.guestCountMin ?? input.capacityMin);
    }
    return amount;
  }
  const starting = money(input.startingPrice);
  if (model === 'PER_GUEST') {
    return starting * billableGuests(input.guestCount, input.capacityMin);
  }
  return starting;
}

export function quoteVenueCurrency(input: VenueQuoteInput, fallback = 'AED'): string {
  const packages = activeVenuePackages(input.packages);
  const selected = input.packageId ? packages.find((item) => item.id === input.packageId) : packages[0];
  const fromPackage = selected && 'currency' in selected ? String((selected as { currency?: unknown }).currency ?? '') : '';
  return fromPackage || input.currency || fallback;
}
