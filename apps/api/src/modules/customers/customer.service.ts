import bcrypt from 'bcryptjs';
import { Role, UserStatus, type Prisma } from '@prisma/client';
import { env } from '../../config/env.js';
import { adminScope, assignableCountry, assertCountryAllowed, countryWhere } from '../../lib/admin-scope.js';
import type { AuthUser } from '../../middleware/auth.js';
import { ConflictError, NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { authRepository } from '../auth/auth.repository.js';
import { customerRepository } from './customer.repository.js';
import type { z } from 'zod';
import type { customerCreateSchema, customerListQuery, customerPatchSchema } from './customer.schema.js';

export const customerService = {
  async list(query: z.infer<typeof customerListQuery>, actor?: AuthUser) {
    const { skip, take } = skipTake(query);
    const where: Prisma.UserWhereInput = {
      role: Role.CUSTOMER,
      ...notDeleted,
      ...countryWhere(adminScope(actor)),
      ...(query.status ? { status: query.status } : {}),
      ...(query.q
        ? {
            OR: [
              { email: { contains: query.q, mode: 'insensitive' } },
              { firstName: { contains: query.q, mode: 'insensitive' } },
              { lastName: { contains: query.q, mode: 'insensitive' } },
              { phone: { contains: query.q, mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [items, total] = await customerRepository.list(where, skip, take);
    return paginated(items, total, query);
  },
  async get(id: string, actor?: AuthUser) {
    const row = await customerRepository.findById(id);
    if (!row) {
      throw new NotFoundError('Customer not found');
    }
    assertCountryAllowed(adminScope(actor), row.country);
    const { passwordHash: _passwordHash, ...safe } = row as typeof row & { passwordHash?: string };
    return safe;
  },
  async setActive(id: string, active: boolean, actor?: AuthUser) {
    await this.get(id, actor);
    return customerRepository.setStatus(id, active ? UserStatus.ACTIVE : UserStatus.INACTIVE);
  },
  async update(id: string, input: z.infer<typeof customerPatchSchema>, actor?: AuthUser) {
    const current = await this.get(id, actor);
    const { password, ...rest } = input;
    if (password) {
      await authRepository.updatePassword(id, await bcrypt.hash(password, env.BCRYPT_ROUNDS));
    }
    const firstName = rest.firstName ?? current.firstName;
    const lastName = rest.lastName ?? current.lastName;
    await authRepository.updateProfile(id, {
      firstName: rest.firstName,
      lastName: rest.lastName,
      phone: rest.phone === undefined ? undefined : rest.phone,
      locale: rest.locale,
      country: rest.country === undefined ? undefined : assignableCountry(adminScope(actor), rest.country ?? undefined),
      avatarKey: rest.avatarKey,
      status: rest.status,
      displayName: `${firstName} ${lastName}`,
    });
    return this.get(id, actor);
  },
  async remove(id: string, actor?: AuthUser) {
    await this.get(id, actor);
    await authRepository.updateProfile(id, { deletedAt: new Date(), status: UserStatus.INACTIVE });
    await authRepository.revokeAllRefreshTokens(id);
    return { deleted: true };
  },
  async create(input: z.infer<typeof customerCreateSchema>, actor?: AuthUser) {
    const existing = await authRepository.findActiveByEmail(input.email);
    if (existing) {
      throw new ConflictError('An account with this email already exists');
    }
    const passwordHash = await bcrypt.hash(input.password, env.BCRYPT_ROUNDS);
    const user = await authRepository.createCustomer({
      email: input.email,
      passwordHash,
      firstName: input.firstName,
      lastName: input.lastName,
      phone: input.phone,
      locale: input.locale,
      country: assignableCountry(adminScope(actor), input.country) ?? input.country,
    });
    return this.get(user.id, actor);
  },
};
