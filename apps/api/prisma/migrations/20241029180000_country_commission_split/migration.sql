ALTER TABLE "Commission"
    ADD COLUMN IF NOT EXISTS "country" TEXT,
    ADD COLUMN IF NOT EXISTS "hqRate" DECIMAL(5, 2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS "hqAmount" DECIMAL(12, 2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS "deskAmount" DECIMAL(12, 2) NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS "Commission_country_idx" ON "Commission"("country");

CREATE TABLE IF NOT EXISTS "CountryCommissionPolicy" (
    "id" UUID NOT NULL,
    "country" TEXT NOT NULL,
    "hqShareRate" DECIMAL(5, 2) NOT NULL DEFAULT 30.00,
    "defaultVendorRate" DECIMAL(5, 2) NOT NULL DEFAULT 12.00,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CountryCommissionPolicy_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "CountryCommissionPolicy_country_key" ON "CountryCommissionPolicy"("country");
