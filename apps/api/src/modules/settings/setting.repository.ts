import type { Prisma } from '@prisma/client';
import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const settingRepository = {
  list(group?: string) {
    return prisma.setting.findMany({
      where: { ...notDeleted, ...(group ? { group } : {}) },
      orderBy: [{ group: 'asc' }, { key: 'asc' }],
    });
  },
  findByKey(key: string) {
    return prisma.setting.findFirst({ where: { key, ...notDeleted } });
  },
  upsert(data: Prisma.SettingCreateInput) {
    return prisma.setting.upsert({
      where: { key: String(data.key) },
      update: { value: data.value, group: data.group },
      create: data,
    });
  },
  update(id: string, data: Prisma.SettingUpdateInput) {
    return prisma.setting.update({ where: { id }, data });
  },
};
