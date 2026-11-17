CREATE TYPE "VenuePricingModel" AS ENUM ('HIRE', 'PER_GUEST', 'HYBRID');
CREATE TYPE "VenuePackageUnit" AS ENUM ('EVENT', 'GUEST');

ALTER TABLE "Venue" ADD COLUMN "startingPrice" DECIMAL(12,2) NOT NULL DEFAULT 0;
ALTER TABLE "Venue" ADD COLUMN "currency" TEXT NOT NULL DEFAULT 'AED';
ALTER TABLE "Venue" ADD COLUMN "pricingModel" "VenuePricingModel" NOT NULL DEFAULT 'HYBRID';
ALTER TABLE "VenuePackage" ADD COLUMN "pricingUnit" "VenuePackageUnit" NOT NULL DEFAULT 'EVENT';

UPDATE "Venue" AS v
SET
  "startingPrice" = p.min_price,
  "currency" = p.currency
FROM (
  SELECT
    "venueId",
    MIN("priceAmount") AS min_price,
    MIN("currency") AS currency
  FROM "VenuePackage"
  WHERE "deletedAt" IS NULL
  GROUP BY "venueId"
) AS p
WHERE v.id = p."venueId"
  AND v."startingPrice" = 0;
