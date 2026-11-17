import { Role, type Prisma } from '@prisma/client';
import { ForbiddenError } from './errors.js';

export type AdminScope = { all: true } | { all: false; countries: string[] };

export type AdminActor = {
  id: string;
  role: Role;
  isSuperAdmin?: boolean;
  allowedCountries?: string[];
  deskCountry?: string | null;
};

export function parseCountryList(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return [...new Set(value.filter((item): item is string => typeof item === 'string' && item.length === 2))];
}

export function adminScope(user?: AdminActor | null): AdminScope | null {
  if (!user || user.role !== Role.ADMIN) {
    return null;
  }
  if (user.isSuperAdmin) {
    if (user.deskCountry && user.deskCountry.length === 2) {
      return { all: false, countries: [user.deskCountry] };
    }
    return { all: true };
  }
  return { all: false, countries: user.allowedCountries ?? [] };
}

export function countryInFilter(scope: AdminScope | null): Prisma.StringFilter | string | undefined {
  if (!scope || scope.all) {
    return undefined;
  }
  return { in: scope.countries.length > 0 ? scope.countries : ['__none__'] };
}

export function countryWhere(scope: AdminScope | null): { country?: Prisma.StringFilter | string } {
  const country = countryInFilter(scope);
  return country ? { country } : {};
}

export function viaVendorCountry(scope: AdminScope | null): { vendor?: Prisma.VendorWhereInput } {
  const country = countryInFilter(scope);
  return country ? { vendor: { country } } : {};
}

export function viaBookingVendorCountry(scope: AdminScope | null): { booking?: Prisma.BookingWhereInput } {
  const country = countryInFilter(scope);
  return country ? { booking: { vendor: { country } } } : {};
}

export function viaVenueCountry(scope: AdminScope | null): { venue?: Prisma.VenueWhereInput } {
  const country = countryInFilter(scope);
  return country ? { venue: { OR: [{ country }, { vendor: { country } }] } } : {};
}

export function viaCustomerCountry(scope: AdminScope | null): { customer?: Prisma.UserWhereInput } {
  const country = countryInFilter(scope);
  return country ? { customer: { country } } : {};
}

export function viaEventCountry(scope: AdminScope | null): Prisma.EventWhereInput {
  const country = countryInFilter(scope);
  if (!country) {
    return {};
  }
  return { OR: [{ country }, { customer: { country } }] };
}

export function viaPeerCountry(scope: AdminScope | null): Prisma.UserWhereInput {
  const country = countryInFilter(scope);
  return country ? { country } : {};
}

export function publicCatalogCountry(country?: string): {
  OR?: Array<{ country?: string } | { vendor: { country: string } }>;
} {
  if (!country) {
    return {};
  }
  return { OR: [{ country }, { vendor: { country } }] };
}

export function publicVendorCountry(country?: string): { vendor?: { country: string } } {
  return country ? { vendor: { country } } : {};
}

export function recordCountry(row: {
  country?: string | null;
  vendor?: { country?: string | null } | null;
}): string | null {
  return row.vendor?.country ?? row.country ?? null;
}

export function assertCountryAllowed(scope: AdminScope | null, country: string | null | undefined): void {
  if (!scope || scope.all) {
    return;
  }
  if (!country || !scope.countries.includes(country)) {
    throw new ForbiddenError('This record is outside your assigned countries');
  }
}

export function assignableCountry(scope: AdminScope | null, country: string | undefined): string | undefined {
  if (!scope || scope.all) {
    return country;
  }
  if (country && !scope.countries.includes(country)) {
    throw new ForbiddenError('You can only manage your assigned countries');
  }
  return country ?? scope.countries[0];
}

export function isSuperAdminUser(user?: AdminActor | null): boolean {
  return Boolean(user?.role === Role.ADMIN && user.isSuperAdmin);
}
