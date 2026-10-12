import { prisma } from '../../lib/prisma.js';
import { notDeleted } from '../../lib/common.js';

export const aiRepository = {
  event(id: string, customerId: string) {
    return prisma.event.findFirst({
      where: { id, customerId, ...notDeleted },
      include: { category: true },
    });
  },
};
