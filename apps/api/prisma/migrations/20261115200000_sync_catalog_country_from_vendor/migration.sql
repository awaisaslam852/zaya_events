UPDATE "Venue" AS v
SET country = vend.country
FROM "Vendor" AS vend
WHERE v."vendorId" = vend.id
  AND vend.country IS NOT NULL
  AND v.country IS DISTINCT FROM vend.country;

UPDATE "Listing" AS l
SET country = vend.country
FROM "Vendor" AS vend
WHERE l."vendorId" = vend.id
  AND vend.country IS NOT NULL
  AND l.country IS DISTINCT FROM vend.country;

UPDATE "Accommodation" AS a
SET country = vend.country
FROM "Vendor" AS vend
WHERE a."vendorId" = vend.id
  AND vend.country IS NOT NULL
  AND a.country IS DISTINCT FROM vend.country;
