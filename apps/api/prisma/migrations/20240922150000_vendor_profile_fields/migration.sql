ALTER TABLE "Vendor" ADD COLUMN IF NOT EXISTS "galleryKeys" JSONB NOT NULL DEFAULT '[]';
ALTER TABLE "Vendor" ADD COLUMN IF NOT EXISTS "serviceAreas" JSONB NOT NULL DEFAULT '[]';
ALTER TABLE "Vendor" ADD COLUMN IF NOT EXISTS "notificationPrefs" JSONB NOT NULL DEFAULT '{"email":true,"push":true,"whatsapp":false}';
