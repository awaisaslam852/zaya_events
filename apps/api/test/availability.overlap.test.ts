import { AppError } from '../src/lib/errors.js';
import { assertNoOverlap, slotsOverlap } from '../src/modules/availability/availability.service.js';

describe('availability overlap', () => {
  const aStart = new Date('2026-10-01T10:00:00.000Z');
  const aEnd = new Date('2026-10-01T14:00:00.000Z');

  it('detects overlapping half-open ranges', () => {
    expect(slotsOverlap(aStart, aEnd, new Date('2026-10-01T13:00:00.000Z'), new Date('2026-10-01T16:00:00.000Z'))).toBe(
      true,
    );
    expect(slotsOverlap(aStart, aEnd, new Date('2026-10-01T14:00:00.000Z'), new Date('2026-10-01T16:00:00.000Z'))).toBe(
      false,
    );
    expect(slotsOverlap(aStart, aEnd, new Date('2026-10-01T08:00:00.000Z'), new Date('2026-10-01T10:00:00.000Z'))).toBe(
      false,
    );
  });

  it('rejects inverted ranges before querying the database', async () => {
    await expect(
      assertNoOverlap({
        resourceType: 'VENUE',
        resourceId: '00000000-0000-4000-8000-000000000001',
        startAt: aEnd,
        endAt: aStart,
      }),
    ).rejects.toMatchObject({
      statusCode: 422,
      code: 'INVALID_RANGE',
    } satisfies Partial<AppError>);
  });
});
