export const DEFAULT_VENDOR_RATE = 12;
export const DEFAULT_HQ_SHARE = 30;

export type CommissionSplit = {
  vendorRate: number;
  hqShareRate: number;
  amount: number;
  hqAmount: number;
  deskAmount: number;
};

function clampRate(value: number | null | undefined, fallback: number): number {
  const n = Number(value);
  if (!Number.isFinite(n)) {
    return fallback;
  }
  return Math.min(100, Math.max(0, n));
}

export function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

export function splitCommission(input: {
  bookingAmount: number;
  vendorRate?: number | null;
  hqShareRate?: number | null;
}): CommissionSplit {
  const vendorRate = clampRate(input.vendorRate, DEFAULT_VENDOR_RATE);
  const hqShareRate = clampRate(input.hqShareRate, DEFAULT_HQ_SHARE);
  const amount = roundMoney((Number(input.bookingAmount) * vendorRate) / 100);
  const hqAmount = roundMoney((amount * hqShareRate) / 100);
  const deskAmount = roundMoney(amount - hqAmount);
  return { vendorRate, hqShareRate, amount, hqAmount, deskAmount };
}
