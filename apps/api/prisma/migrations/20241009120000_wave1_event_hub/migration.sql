DO $$ BEGIN
  ALTER TYPE "AccommodationType" ADD VALUE 'BUNGALOW';
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TYPE "FavoriteResourceType" ADD VALUE 'HOTEL';
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE "Event" ADD COLUMN IF NOT EXISTS "notes" JSONB;
ALTER TABLE "Event" ADD COLUMN IF NOT EXISTS "preferredVenueType" TEXT;
ALTER TABLE "Event" ADD COLUMN IF NOT EXISTS "checklist" JSONB NOT NULL DEFAULT '[]';

ALTER TABLE "VenueVisit" ADD COLUMN IF NOT EXISTS "eventId" UUID;
CREATE INDEX IF NOT EXISTS "VenueVisit_eventId_idx" ON "VenueVisit"("eventId");

DO $$ BEGIN
  ALTER TABLE "VenueVisit"
    ADD CONSTRAINT "VenueVisit_eventId_fkey"
    FOREIGN KEY ("eventId") REFERENCES "Event"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
