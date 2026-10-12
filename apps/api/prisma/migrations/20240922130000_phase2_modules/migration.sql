-- AlterEnum
ALTER TYPE "BookingStatus" ADD VALUE IF NOT EXISTS 'UNDER_REVIEW';
ALTER TYPE "VenueVisitStatus" ADD VALUE IF NOT EXISTS 'APPROVED';
ALTER TYPE "VenueVisitStatus" ADD VALUE IF NOT EXISTS 'RESCHEDULED';
ALTER TYPE "VenueVisitStatus" ADD VALUE IF NOT EXISTS 'DECIDED';

-- CreateEnum
CREATE TYPE "AvailabilitySlotStatus" AS ENUM ('AVAILABLE', 'UNAVAILABLE', 'RESERVED');
CREATE TYPE "PaymentKind" AS ENUM ('DEPOSIT', 'BALANCE', 'REFUND');
CREATE TYPE "CallStatus" AS ENUM ('RINGING', 'ACCEPTED', 'REJECTED', 'ENDED', 'MISSED');
CREATE TYPE "CrmFollowUpStatus" AS ENUM ('OPEN', 'DONE', 'CANCELLED');

-- AlterTable
ALTER TABLE "ServiceCategory" ADD COLUMN IF NOT EXISTS "customFields" JSONB NOT NULL DEFAULT '[]';
ALTER TABLE "Listing" ADD COLUMN IF NOT EXISTS "customFieldValues" JSONB NOT NULL DEFAULT '{}';
ALTER TABLE "Availability" ADD COLUMN IF NOT EXISTS "status" "AvailabilitySlotStatus" NOT NULL DEFAULT 'AVAILABLE';
ALTER TABLE "Availability" ADD COLUMN IF NOT EXISTS "source" TEXT NOT NULL DEFAULT 'internal';
ALTER TABLE "Availability" ADD COLUMN IF NOT EXISTS "bookingId" UUID;
ALTER TABLE "Booking" ADD COLUMN IF NOT EXISTS "depositAmount" DECIMAL(12,2) NOT NULL DEFAULT 0;
ALTER TABLE "Booking" ADD COLUMN IF NOT EXISTS "balanceAmount" DECIMAL(12,2) NOT NULL DEFAULT 0;
ALTER TABLE "VenueVisit" ADD COLUMN IF NOT EXISTS "decision" JSONB;
ALTER TABLE "VenueVisit" ADD COLUMN IF NOT EXISTS "decisionAt" TIMESTAMP(3);
ALTER TABLE "Conversation" ADD COLUMN IF NOT EXISTS "aLastReadAt" TIMESTAMP(3);
ALTER TABLE "Conversation" ADD COLUMN IF NOT EXISTS "bLastReadAt" TIMESTAMP(3);
ALTER TABLE "Payment" ADD COLUMN IF NOT EXISTS "kind" "PaymentKind" NOT NULL DEFAULT 'DEPOSIT';

CREATE INDEX IF NOT EXISTS "Availability_bookingId_idx" ON "Availability"("bookingId");

CREATE TABLE IF NOT EXISTS "Call" (
    "id" UUID NOT NULL,
    "callerId" UUID NOT NULL,
    "calleeId" UUID NOT NULL,
    "bookingId" UUID,
    "channelName" TEXT NOT NULL,
    "status" "CallStatus" NOT NULL DEFAULT 'RINGING',
    "callerUid" INTEGER NOT NULL,
    "calleeUid" INTEGER NOT NULL,
    "startedAt" TIMESTAMP(3),
    "endedAt" TIMESTAMP(3),
    "missedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    CONSTRAINT "Call_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "Call_callerId_createdAt_idx" ON "Call"("callerId", "createdAt");
CREATE INDEX IF NOT EXISTS "Call_calleeId_createdAt_idx" ON "Call"("calleeId", "createdAt");
CREATE INDEX IF NOT EXISTS "Call_status_idx" ON "Call"("status");

ALTER TABLE "Call" ADD CONSTRAINT "Call_callerId_fkey" FOREIGN KEY ("callerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Call" ADD CONSTRAINT "Call_calleeId_fkey" FOREIGN KEY ("calleeId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "Call" ADD CONSTRAINT "Call_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS "CrmFollowUp" (
    "id" UUID NOT NULL,
    "ownerId" UUID NOT NULL,
    "subjectType" "CrmSubjectType" NOT NULL,
    "subjectId" UUID NOT NULL,
    "dueAt" TIMESTAMP(3) NOT NULL,
    "summary" TEXT NOT NULL,
    "status" "CrmFollowUpStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    CONSTRAINT "CrmFollowUp_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "CrmFollowUp_ownerId_status_idx" ON "CrmFollowUp"("ownerId", "status");
CREATE INDEX IF NOT EXISTS "CrmFollowUp_subjectType_subjectId_idx" ON "CrmFollowUp"("subjectType", "subjectId");
ALTER TABLE "CrmFollowUp" ADD CONSTRAINT "CrmFollowUp_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS "CommissionRate" (
    "id" UUID NOT NULL,
    "name" JSONB NOT NULL,
    "rate" DECIMAL(5,2) NOT NULL,
    "bookingType" "BookingType",
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    CONSTRAINT "CommissionRate_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "CommissionRate_isActive_isDefault_idx" ON "CommissionRate"("isActive", "isDefault");
