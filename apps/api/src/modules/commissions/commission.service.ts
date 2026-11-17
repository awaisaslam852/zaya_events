import { Prisma } from '@prisma/client';
import { adminScope, assertCountryAllowed, isSuperAdminUser, viaVendorCountry } from '../../lib/admin-scope.js';
import {
  DEFAULT_HQ_SHARE,
  DEFAULT_VENDOR_RATE,
} from '../../lib/commission-split.js';
import { ForbiddenError } from '../../lib/errors.js';
import type { AuthUser } from '../../middleware/auth.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { commissionRepository } from './commission.repository.js';
import type { z } from 'zod';
import type { commissionListQuery, commissionPolicyPatch, commissionRateBody } from './commission.schema.js';

export type ResolvedCommissionPolicy = {
  country: string | null;
  hqShareRate: number;
  defaultVendorRate: number;
};

function asPolicy(
  country: string,
  row?: { hqShareRate: Prisma.Decimal | number; defaultVendorRate: Prisma.Decimal | number } | null,
): ResolvedCommissionPolicy {
  return {
    country,
    hqShareRate: Number(row?.hqShareRate ?? DEFAULT_HQ_SHARE),
    defaultVendorRate: Number(row?.defaultVendorRate ?? DEFAULT_VENDOR_RATE),
  };
}

export const commissionService = {
  async resolvePolicy(country?: string | null): Promise<ResolvedCommissionPolicy> {
    if (!country) {
      return { country: null, hqShareRate: DEFAULT_HQ_SHARE, defaultVendorRate: DEFAULT_VENDOR_RATE };
    }
    const row = await commissionRepository.findPolicy(country);
    return asPolicy(country, row);
  },
  async ledger(query: z.infer<typeof commissionListQuery>, actor?: AuthUser) {
    const { skip, take } = skipTake(query);
    const [items, total] = await commissionRepository.listLedger(
      {
        ...notDeleted,
        ...viaVendorCountry(adminScope(actor)),
        ...(query.vendorId ? { vendorId: query.vendorId } : {}),
      },
      skip,
      take,
    );
    return paginated(items, total, query);
  },
  rates() {
    return commissionRepository.listRates();
  },
  createRate(input: z.infer<typeof commissionRateBody>) {
    return commissionRepository.createRate({
      name: input.name as Prisma.InputJsonValue,
      rate: input.rate,
      bookingType: input.bookingType,
      isDefault: input.isDefault,
      isActive: input.isActive,
    });
  },
  updateRate(id: string, input: Partial<z.infer<typeof commissionRateBody>>) {
    return commissionRepository.updateRate(id, {
      ...(input.name ? { name: input.name as Prisma.InputJsonValue } : {}),
      ...(input.rate !== undefined ? { rate: input.rate } : {}),
      ...(input.bookingType !== undefined ? { bookingType: input.bookingType } : {}),
      ...(input.isDefault !== undefined ? { isDefault: input.isDefault } : {}),
      ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
    });
  },
  async listPolicies(actor?: AuthUser) {
    const scope = adminScope(actor);
    const countries = !scope || scope.all ? undefined : scope.countries;
    const rows = await commissionRepository.listPolicies(countries);
    const known = new Map(rows.map((row) => [row.country, row]));
    const codes = countries ?? [...new Set([...rows.map((row) => row.country), 'AE', 'SA', 'PK'])];
    return codes.sort().map((country) => asPolicy(country, known.get(country)));
  },
  async updatePolicy(
    country: string,
    input: z.infer<typeof commissionPolicyPatch>,
    actor?: AuthUser,
  ) {
    const scope = adminScope(actor);
    assertCountryAllowed(scope, country);
    const superAdmin = isSuperAdminUser(actor);
    if (!superAdmin && input.hqShareRate !== undefined) {
      throw new ForbiddenError('Only the main administrator can set HQ commission on a country desk');
    }
    if (!superAdmin && input.defaultVendorRate === undefined) {
      throw new ForbiddenError('Country admins can only change the vendor commission for their desk');
    }
    const patch = superAdmin
      ? input
      : { defaultVendorRate: input.defaultVendorRate };
    const row = await commissionRepository.upsertPolicy(country, patch);
    return asPolicy(country, row);
  },
};
