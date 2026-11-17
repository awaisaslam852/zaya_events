CREATE TYPE "ReviewDirection" AS ENUM ('CUSTOMER_TO_VENDOR', 'VENDOR_TO_CUSTOMER');

ALTER TABLE "User" ADD COLUMN "ratingAvg" DECIMAL(3,2) NOT NULL DEFAULT 0;
ALTER TABLE "User" ADD COLUMN "ratingCount" INTEGER NOT NULL DEFAULT 0;

CREATE TABLE "Review" (
    "id" UUID NOT NULL,
    "bookingId" UUID NOT NULL,
    "authorId" UUID NOT NULL,
    "targetUserId" UUID NOT NULL,
    "vendorId" UUID,
    "venueId" UUID,
    "listingId" UUID,
    "direction" "ReviewDirection" NOT NULL,
    "rating" INTEGER NOT NULL,
    "body" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Review_bookingId_direction_key" ON "Review"("bookingId", "direction");
CREATE INDEX "Review_vendorId_direction_createdAt_idx" ON "Review"("vendorId", "direction", "createdAt");
CREATE INDEX "Review_venueId_direction_idx" ON "Review"("venueId", "direction");
CREATE INDEX "Review_listingId_direction_idx" ON "Review"("listingId", "direction");
CREATE INDEX "Review_targetUserId_idx" ON "Review"("targetUserId");
CREATE INDEX "Review_deletedAt_idx" ON "Review"("deletedAt");

ALTER TABLE "Review" ADD CONSTRAINT "Review_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "Vendor"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_venueId_fkey" FOREIGN KEY ("venueId") REFERENCES "Venue"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "Listing"("id") ON DELETE SET NULL ON UPDATE CASCADE;
