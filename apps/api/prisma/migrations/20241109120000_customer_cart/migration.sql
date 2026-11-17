CREATE TABLE "CartItem" (
  "id" UUID NOT NULL,
  "userId" UUID NOT NULL,
  "type" "BookingType" NOT NULL,
  "resourceId" TEXT NOT NULL,
  "startAt" TIMESTAMP(3) NOT NULL,
  "endAt" TIMESTAMP(3),
  "guestCount" INTEGER,
  "notes" JSONB,
  "snapshot" JSONB NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3),

  CONSTRAINT "CartItem_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "CartItem_userId_deletedAt_idx" ON "CartItem"("userId", "deletedAt");

ALTER TABLE "CartItem"
  ADD CONSTRAINT "CartItem_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
