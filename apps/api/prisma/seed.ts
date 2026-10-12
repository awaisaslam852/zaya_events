import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import dotenv from 'dotenv';
import { PrismaClient, Role, UserStatus, VendorStatus, BannerPlacement, BookingType, BookingStatus, FavoriteResourceType, ConversationType } from '@prisma/client';
import bcrypt from 'bcryptjs';

for (const candidate of [resolve(process.cwd(), '../../.env'), resolve(process.cwd(), '.env')]) {
  if (existsSync(candidate)) {
    dotenv.config({ path: candidate });
  }
}

const prisma = new PrismaClient();

const loc = (en: string, ar: string) => ({ en, ar });

const EVENT_CATEGORIES = [
  { slug: 'wedding', name: loc('Wedding', 'زفاف'), description: loc('Wedding ceremonies and receptions', 'حفلات الزفاف والاستقبال'), icon: 'rings' },
  { slug: 'engagement', name: loc('Engagement', 'خطوبة'), description: loc('Engagement parties', 'حفلات الخطوبة'), icon: 'heart' },
  { slug: 'birthday', name: loc('Birthday', 'عيد ميلاد'), description: loc('Birthday celebrations', 'احتفالات أعياد الميلاد'), icon: 'cake' },
  { slug: 'family', name: loc('Family gathering', 'تجمع عائلي'), description: loc('Family reunions and private gatherings', 'لمّات عائلية وتجمعات خاصة'), icon: 'family' },
  { slug: 'social', name: loc('Social event', 'مناسبة اجتماعية'), description: loc('Social parties and celebrations', 'مناسبات وحفلات اجتماعية'), icon: 'cheers' },
  { slug: 'educational', name: loc('Educational', 'تعليمي'), description: loc('Graduations, workshops, and academic events', 'حفلات تخرج وورش وفعاليات أكاديمية'), icon: 'graduation' },
  { slug: 'corporate', name: loc('Corporate', 'شركات'), description: loc('Conferences, offsites, and company events', 'مؤتمرات وفعاليات الشركات'), icon: 'briefcase' },
  { slug: 'baby-shower', name: loc('Baby shower', 'استقبال مولود'), description: loc('Baby showers and newborn celebrations', 'حفلات استقبال المولود'), icon: 'baby' },
  { slug: 'conference', name: loc('Conference', 'مؤتمر'), description: loc('Professional conferences', 'مؤتمرات مهنية'), icon: 'mic' },
  { slug: 'graduation', name: loc('Graduation', 'تخرج'), description: loc('Graduation ceremonies and parties', 'حفلات التخرج'), icon: 'cap' },
  { slug: 'gender-reveal', name: loc('Gender reveal', 'تحديد جنس المولود'), description: loc('Gender reveal celebrations', 'حفلات الكشف عن جنس المولود'), icon: 'balloon' },
  { slug: 'anniversary', name: loc('Anniversary', 'ذكرى سنوية'), description: loc('Wedding and family anniversaries', 'ذكريات الزواج والعائلة'), icon: 'calendar' },
  { slug: 'bridal-shower', name: loc('Bridal shower', 'حفلة العروس'), description: loc('Bridal showers and parties', 'حفلات توديع العزوبية للعروس'), icon: 'gift' },
  { slug: 'bachelor', name: loc('Bachelor / bachelorette', 'حفلة توديع العزوبية'), description: loc('Bachelor and bachelorette events', 'حفلات توديع العزوبية'), icon: 'sparkles' },
  { slug: 'eid', name: loc('Eid / seasonal', 'عيد ومواسم'), description: loc('Eid and seasonal celebrations', 'احتفالات العيد والمواسم'), icon: 'moon' },
];

const SERVICE_CATEGORIES = [
  { slug: 'photography', name: loc('Photography', 'تصوير'), description: loc('Photo and video coverage', 'تغطية تصوير فوتوغرافي وفيديو'), icon: 'camera' },
  { slug: 'videography', name: loc('Videography', 'فيديو'), description: loc('Cinematic event films', 'أفلام مناسبات سينمائية'), icon: 'video' },
  { slug: 'catering', name: loc('Catering', 'تموين'), description: loc('Food and beverage service', 'خدمات الطعام والشراب'), icon: 'utensils' },
  { slug: 'florist', name: loc('Florist', 'زهور'), description: loc('Floral design and bouquets', 'تنسيق الزهور والباقات'), icon: 'flower' },
  { slug: 'dj', name: loc('DJ & music', 'دي جي وموسيقى'), description: loc('DJs, live bands, and sound', 'دي جي وفرق حية وصوت'), icon: 'music' },
  { slug: 'makeup', name: loc('Makeup & beauty', 'مكياج وتجميل'), description: loc('Bridal makeup and styling', 'مكياج وتصفيف العروس'), icon: 'sparkle' },
  { slug: 'decoration', name: loc('Decoration', 'ديكور'), description: loc('Stage and venue styling', 'تنسيق المسرح والقاعة'), icon: 'palette' },
  { slug: 'cake', name: loc('Cakes', 'كيك'), description: loc('Wedding and event cakes', 'كيك الزفاف والمناسبات'), icon: 'cake-slice' },
  { slug: 'entertainment', name: loc('Entertainment', 'ترفيه'), description: loc('Hosts, dancers, and kids entertainment', 'تقديم وترفيه للكبار والأطفال'), icon: 'star' },
  { slug: 'planning', name: loc('Event planning', 'تنظيم فعاليات'), description: loc('Full-service planners', 'منظمو مناسبات متكاملون'), icon: 'clipboard' },
  { slug: 'wedding-planner', name: loc('Wedding planner', 'منسق زفاف'), description: loc('Dedicated wedding coordinators', 'منسقو حفلات زفاف'), icon: 'rings' },
  { slug: 'dresses', name: loc('Dresses & formalwear', 'فساتين وملابس رسمية'), description: loc('Bridal gowns, party dresses, and groom suits', 'فساتين زفاف وبدل العريس'), icon: 'shirt' },
  { slug: 'jewelry', name: loc('Jewelry & accessories', 'مجوهرات وإكسسوارات'), description: loc('Jewelry and event accessories', 'مجوهرات وإكسسوارات المناسبات'), icon: 'gem' },
  { slug: 'invitations', name: loc('Invitations & printing', 'دعوات وطباعة'), description: loc('Cards, invitations, and stationery', 'بطاقات ودعوات ومطبوعات'), icon: 'mail' },
  { slug: 'production', name: loc('Sound, lighting & stage', 'صوت وإضاءة ومسرح'), description: loc('Sound, lighting, and event production', 'صوت وإضاءة وإنتاج'), icon: 'lightbulb' },
  { slug: 'rentals', name: loc('Furniture & equipment rental', 'تأجير أثاث ومعدات'), description: loc('Tables, chairs, tents, and booths', 'طاولات وكراسي وخيام'), icon: 'box' },
  { slug: 'gifts', name: loc('Gifts & favors', 'هدايا وتذكارات'), description: loc('Guest gifts and wedding favors', 'هدايا الضيوف'), icon: 'gift' },
];

async function main(): Promise<void> {
  const rounds = Number.parseInt(process.env.BCRYPT_ROUNDS ?? '12', 10);
  const adminEmail = process.env.SEED_ADMIN_EMAIL ?? 'admin@zayaevents.com';
  const adminPassword = process.env.SEED_ADMIN_PASSWORD ?? 'ChangeMeAdmin!123';
  const vendorPassword = process.env.SEED_VENDOR_PASSWORD ?? 'ChangeMeVendor!123';
  const guestEmail = process.env.SEED_CUSTOMER_EMAIL ?? 'guest@zayaevents.com';
  const guestPassword = process.env.SEED_CUSTOMER_PASSWORD ?? 'ChangeMeGuest!123';
  const adminHash = await bcrypt.hash(adminPassword, rounds);
  const vendorHash = await bcrypt.hash(vendorPassword, rounds);
  const guestHash = await bcrypt.hash(guestPassword, rounds);

  const admin = await prisma.user.upsert({
    where: { email: adminEmail },
    update: {},
    create: {
      email: adminEmail,
      passwordHash: adminHash,
      role: Role.ADMIN,
      status: UserStatus.ACTIVE,
      firstName: 'Zaya',
      lastName: 'Admin',
      displayName: 'Zaya Admin',
      locale: 'en',
      emailVerifiedAt: new Date(),
    },
  });

  const guest = await prisma.user.upsert({
    where: { email: guestEmail },
    update: {},
    create: {
      email: guestEmail,
      passwordHash: guestHash,
      role: Role.CUSTOMER,
      status: UserStatus.ACTIVE,
      firstName: 'Demo',
      lastName: 'Guest',
      displayName: 'Demo Guest',
      locale: 'en',
      emailVerifiedAt: new Date(),
    },
  });

  for (const [index, category] of EVENT_CATEGORIES.entries()) {
    await prisma.eventCategory.upsert({
      where: { slug: category.slug },
      update: { name: category.name, description: category.description, icon: category.icon, sortOrder: index },
      create: { ...category, sortOrder: index },
    });
  }

  const serviceCategoryIds: Record<string, string> = {};
  for (const [index, category] of SERVICE_CATEGORIES.entries()) {
    const row = await prisma.serviceCategory.upsert({
      where: { slug: category.slug },
      update: { name: category.name, description: category.description, icon: category.icon, sortOrder: index },
      create: { ...category, sortOrder: index },
    });
    serviceCategoryIds[category.slug] = row.id;
  }

  const vendorSpecs = [
    {
      email: 'palms@vendors.zayaevents.com',
      firstName: 'Layla',
      lastName: 'Hassan',
      businessName: loc('Palms Venue Collective', 'مجموعة قاعات النخيل'),
      description: loc('Premium wedding halls across Dubai and Abu Dhabi.', 'قاعات زفاف فاخرة في دبي وأبوظبي.'),
      city: 'Dubai',
    },
    {
      email: 'lumen@vendors.zayaevents.com',
      firstName: 'Omar',
      lastName: 'Farid',
      businessName: loc('Lumen Films', 'لومين للأفلام'),
      description: loc('Cinematic photography and videography.', 'تصوير سينمائي فوتوغرافي وفيديو.'),
      city: 'Abu Dhabi',
    },
    {
      email: 'voyage@vendors.zayaevents.com',
      firstName: 'Noor',
      lastName: 'Al Mazrouei',
      businessName: loc('Voyage Atelier', 'أتيليه فوياج'),
      description: loc('Cars, stays, and honeymoon packages.', 'سيارات وإقامة وبرامج شهر عسل.'),
      city: 'Sharjah',
    },
  ] as const;

  const vendors = [];
  for (const spec of vendorSpecs) {
    const user = await prisma.user.upsert({
      where: { email: spec.email },
      update: {},
      create: {
        email: spec.email,
        passwordHash: vendorHash,
        role: Role.VENDOR,
        status: UserStatus.ACTIVE,
        firstName: spec.firstName,
        lastName: spec.lastName,
        displayName: `${spec.firstName} ${spec.lastName}`,
        locale: 'en',
        emailVerifiedAt: new Date(),
      },
    });
    const vendor = await prisma.vendor.upsert({
      where: { userId: user.id },
      update: { status: VendorStatus.APPROVED },
      create: {
        userId: user.id,
        businessName: spec.businessName,
        description: spec.description,
        status: VendorStatus.APPROVED,
        commissionRate: 12,
        city: spec.city,
        country: 'AE',
        phone: '+971500000000',
      },
    });
    vendors.push({ user, vendor, spec });
  }

  const palms = vendors[0]!.vendor;
  const lumen = vendors[1]!.vendor;
  const voyage = vendors[2]!.vendor;

  const venueData = [
    {
      vendorId: palms.id,
      name: loc('Palms Ballroom Downtown', 'قاعة النخيل داون تاون'),
      description: loc('Grand ballroom with garden terrace for 80–400 guests.', 'قاعة كبرى مع تراس حديقة تتسع من 80 إلى 400 ضيف.'),
      city: 'Dubai',
      latitude: 25.2048,
      longitude: 55.2708,
      capacityMin: 80,
      capacityMax: 400,
      cover: 'https://images.unsplash.com/photo-1519167758481-83f29da8c2b0?auto=format&fit=crop&w=1400&q=80',
      rating: 9.1,
      reviews: 214,
    },
    {
      vendorId: palms.id,
      name: loc('Saadiyat Orchid Hall', 'قاعة أوركيد السعديات'),
      description: loc('Beach-adjacent hall for ceremonies and galas.', 'قاعة قرب الشاطئ للمراسم والحفلات.'),
      city: 'Abu Dhabi',
      latitude: 24.4539,
      longitude: 54.3773,
      capacityMin: 50,
      capacityMax: 250,
      cover: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1400&q=80',
      rating: 8.8,
      reviews: 156,
    },
    {
      vendorId: palms.id,
      name: loc('Al Qasba Garden Pavilion', 'جناح حديقة القصباء'),
      description: loc('Open-air pavilion for family and social events.', 'جناح مفتوح للمناسبات العائلية والاجتماعية.'),
      city: 'Sharjah',
      latitude: 25.3463,
      longitude: 55.4209,
      capacityMin: 40,
      capacityMax: 180,
      cover: 'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?auto=format&fit=crop&w=1400&q=80',
      rating: 8.4,
      reviews: 98,
    },
  ];

  const venues = [];
  for (const item of venueData) {
    const existing = await prisma.venue.findFirst({
      where: { vendorId: item.vendorId, city: item.city, deletedAt: null },
    });
    const venue =
      existing ??
      (await prisma.venue.create({
        data: {
          vendorId: item.vendorId,
          name: item.name,
          description: item.description,
          address: loc(`${item.city}, United Arab Emirates`, `${item.city}، الإمارات العربية المتحدة`),
          city: item.city,
          country: 'AE',
          latitude: item.latitude,
          longitude: item.longitude,
          capacityMin: item.capacityMin,
          capacityMax: item.capacityMax,
          amenities: ['parking', 'bridal-suite', 'av', 'catering-kitchen'],
          galleryKeys: [item.cover],
          coverKey: item.cover,
          ratingAvg: item.rating,
          ratingCount: item.reviews,
          isPublished: true,
        },
      }));
    if (existing) {
      await prisma.venue.update({
        where: { id: venue.id },
        data: {
          coverKey: item.cover,
          galleryKeys: [item.cover],
          ratingAvg: item.rating,
          ratingCount: item.reviews,
          isPublished: true,
        },
      });
    }
    venues.push(venue);
    const pkgCount = await prisma.venuePackage.count({ where: { venueId: venue.id, deletedAt: null } });
    if (pkgCount === 0) {
      await prisma.venuePackage.create({
        data: {
          venueId: venue.id,
          name: loc('Signature reception', 'استقبال مميز'),
          description: loc('8-hour exclusive hire with lighting package.', 'استئجار حصري لـ 8 ساعات مع باقة إضاءة.'),
          priceAmount: 18000,
          guestCountMin: item.capacityMin,
          guestCountMax: item.capacityMax,
          durationHours: 8,
        },
      });
    }
  }

  const photoCategoryId = serviceCategoryIds['photography'];
  if (photoCategoryId) {
    const existingListing = await prisma.listing.findFirst({ where: { vendorId: lumen.id, deletedAt: null } });
    if (!existingListing) {
      const listing = await prisma.listing.create({
        data: {
          vendorId: lumen.id,
          categoryId: photoCategoryId,
          title: loc('Full-day wedding film', 'فيلم زفاف ليوم كامل'),
          description: loc('Two shooters, highlight film, and 400 edited photos.', 'مصوران، فيلم أبرز اللحظات، و400 صورة معدّلة.'),
          city: 'Abu Dhabi',
          country: 'AE',
          galleryKeys: ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1400&q=80'],
          coverKey: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1400&q=80',
          startingPrice: 6500,
          ratingAvg: 9.2,
          ratingCount: 88,
        },
      });
      await prisma.listingPackage.create({
        data: {
          listingId: listing.id,
          name: loc('Signature day', 'يوم مميز'),
          description: loc('12 hours of coverage.', 'تغطية لمدة 12 ساعة.'),
          priceAmount: 8500,
          durationHours: 12,
        },
      });
    }
  }

  const existingCar = await prisma.car.findFirst({ where: { vendorId: voyage.id, deletedAt: null } });
  if (!existingCar) {
    await prisma.car.create({
      data: {
        vendorId: voyage.id,
        name: loc('Mercedes S-Class chauffeur', 'مرسيدس إس كلاس مع سائق'),
        description: loc('Bridal transfer with professional chauffeur.', 'توصيل العروس مع سائق محترف.'),
        make: 'Mercedes-Benz',
        model: 'S-Class',
        year: 2024,
        seats: 4,
        transmission: 'AUTOMATIC',
        dailyRate: 1200,
        coverKey: 'https://images.unsplash.com/photo-1549924231-f129b911e442?auto=format&fit=crop&w=1400&q=80',
        galleryKeys: ['https://images.unsplash.com/photo-1549924231-f129b911e442?auto=format&fit=crop&w=1400&q=80'],
      },
    });
  }

  const existingStay = await prisma.accommodation.findFirst({ where: { vendorId: voyage.id, deletedAt: null } });
  if (!existingStay) {
    await prisma.accommodation.create({
      data: {
        vendorId: voyage.id,
        name: loc('Palm Suite overnight', 'جناح النخلة لليلة واحدة'),
        description: loc('Sea-view suite for the couple after the reception.', 'جناح بإطلالة بحرية للعروسين بعد الحفل.'),
        type: 'HOTEL_ROOM',
        address: loc('Palm Jumeirah, Dubai', 'نخلة جميرا، دبي'),
        city: 'Dubai',
        country: 'AE',
        latitude: 25.1124,
        longitude: 55.139,
        maxGuests: 2,
        bedrooms: 1,
        bathrooms: 1,
        nightlyRate: 2200,
        amenities: ['sea-view', 'breakfast', 'late-checkout'],
        coverKey: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1400&q=80',
        galleryKeys: ['https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1400&q=80'],
      },
    });
  }

  const existingHoneymoon = await prisma.honeymoonPackage.findFirst({
    where: { vendorId: voyage.id, deletedAt: null },
  });
  if (!existingHoneymoon) {
    await prisma.honeymoonPackage.create({
      data: {
        vendorId: voyage.id,
        name: loc('Maldives overwater week', 'أسبوع المالديف فوق الماء'),
        description: loc('Seven nights, seaplane transfers, and half board.', 'سبع ليالٍ، انتقالات بالطائرة المائية، ونصف إقامة.'),
        destination: loc('Maldives', 'المالديف'),
        nights: 7,
        priceAmount: 18900,
        coverKey: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=1400&q=80',
        galleryKeys: ['https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=1400&q=80'],
        inclusions: ['seaplane', 'half-board', 'spa-credit'],
      },
    });
  }

  const bannerCount = await prisma.banner.count({ where: { deletedAt: null } });
  if (bannerCount === 0) {
    await prisma.banner.createMany({
      data: [
        {
          title: loc('Plan your wedding with Zaya', 'خطط لزفافك معزايا'),
          subtitle: loc('Venues, vendors, travel — one inquiry flow.', 'قاعات، موردون، سفر — مسار طلب واحد.'),
          imageKey: 'banners/home-hero.jpg',
          linkUrl: '/discover',
          placement: BannerPlacement.HOME_HERO,
          sortOrder: 0,
          isActive: true,
        },
        {
          title: loc('Corporate offsites', 'خلوات الشركات'),
          subtitle: loc('Halls and AV partners ready this quarter.', 'قاعات وشركاء صوت وصورة جاهزون هذا الربع.'),
          imageKey: 'banners/corporate.jpg',
          linkUrl: '/categories/corporate',
          placement: BannerPlacement.DISCOVERY,
          sortOrder: 1,
          isActive: true,
        },
      ],
    });
  }

  await seedRichCatalog({
    guestId: guest.id,
    palms,
    lumen,
    voyage,
    serviceCategoryIds,
  });

  await seedDemoJourney({
    guestId: guest.id,
    palmsUserId: vendors[0]!.user.id,
    palmsVendorId: palms.id,
    lumenVendorId: lumen.id,
    voyageVendorId: voyage.id,
    venue: venues[0]!,
  });

  const settings: Array<{ key: string; group: string; value: unknown }> = [
    { key: 'platform.name', group: 'general', value: loc('Zaya Events', 'زايا إيفنتس') },
    { key: 'platform.defaultCurrency', group: 'payments', value: 'AED' },
    { key: 'general.currency', group: 'general', value: 'AED' },
    { key: 'general.siteName', group: 'general', value: 'Zaya Events' },
    { key: 'platform.supportedLocales', group: 'i18n', value: ['en', 'ar'] },
    { key: 'bookings.inquiryTtlHours', group: 'bookings', value: 72 },
    { key: 'commission.defaultRate', group: 'payments', value: 10 },
    { key: 'calls.tokenTtlSeconds', group: 'agora', value: 3600 },
  ];

  for (const setting of settings) {
    await prisma.setting.upsert({
      where: { key: setting.key },
      update: { value: setting.value as object },
      create: { key: setting.key, group: setting.group, value: setting.value as object },
    });
  }

  // eslint-disable-next-line no-console
  console.log(
    `Seed complete. Admin ${admin.email}; customer ${guestEmail}; venues ${venues.length}; vendors ${vendors.length}.`,
  );
}

async function seedRichCatalog(input: {
  guestId: string;
  palms: { id: string };
  lumen: { id: string };
  voyage: { id: string };
  serviceCategoryIds: Record<string, string>;
}): Promise<void> {
  const extraVendors = [
    {
      email: 'bloom@vendors.zayaevents.com',
      firstName: 'Hana',
      lastName: 'Saif',
      businessName: loc('Bloom Atelier', 'أتيليه بلوم'),
      description: loc('Floral installations for weddings and galas.', 'تنسيقات زهور للزفاف والمناسبات.'),
      city: 'Dubai',
    },
    {
      email: 'beats@vendors.zayaevents.com',
      firstName: 'Yusuf',
      lastName: 'Rahman',
      businessName: loc('Desert Beats', 'ديزرت بيتس'),
      description: loc('DJs and live percussion for receptions.', 'دي جي وإيقاع حي للاستقبالات.'),
      city: 'Abu Dhabi',
    },
  ] as const;

  const extraVendorRows: Array<{ vendorId: string }> = [];
  const vendorPassword = process.env.SEED_VENDOR_PASSWORD ?? 'ChangeMeVendor!123';
  const vendorHash = await bcrypt.hash(vendorPassword, Number.parseInt(process.env.BCRYPT_ROUNDS ?? '12', 10));
  for (const spec of extraVendors) {
    const user = await prisma.user.upsert({
      where: { email: spec.email },
      update: {},
      create: {
        email: spec.email,
        passwordHash: vendorHash,
        role: Role.VENDOR,
        status: UserStatus.ACTIVE,
        firstName: spec.firstName,
        lastName: spec.lastName,
        displayName: `${spec.firstName} ${spec.lastName}`,
        locale: 'en',
        emailVerifiedAt: new Date(),
      },
    });
    const vendor = await prisma.vendor.upsert({
      where: { userId: user.id },
      update: { status: VendorStatus.APPROVED },
      create: {
        userId: user.id,
        businessName: spec.businessName,
        description: spec.description,
        status: VendorStatus.APPROVED,
        commissionRate: 12,
        city: spec.city,
        country: 'AE',
        phone: '+971500000111',
      },
    });
    extraVendorRows.push({ vendorId: vendor.id });
  }

  const listings: Array<{
    vendorId: string;
    slugKey: string;
    category: string;
    title: { en: string; ar: string };
    description: { en: string; ar: string };
    city: string;
    price: number;
    cover: string;
    rating: number;
    reviews: number;
  }> = [
    {
      vendorId: input.palms.id,
      slugKey: 'palms-catering-terrace',
      category: 'catering',
      title: loc('Garden terrace catering', 'تموين تراس الحديقة'),
      description: loc('Live stations and a dessert atelier for 80–300 guests.', 'محطات حية وورشة حلويات لـ 80 إلى 300 ضيف.'),
      city: 'Dubai',
      price: 95,
      cover: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=1400&q=80',
      rating: 8.9,
      reviews: 64,
    },
    {
      vendorId: input.lumen.id,
      slugKey: 'lumen-engagement-story',
      category: 'videography',
      title: loc('Engagement story film', 'فيلم قصة الخطوبة'),
      description: loc('Half-day cinematic coverage with drone B-roll.', 'تغطية سينمائية لنصف يوم مع لقطات درون.'),
      city: 'Abu Dhabi',
      price: 4200,
      cover: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1400&q=80',
      rating: 9.4,
      reviews: 41,
    },
    {
      vendorId: input.lumen.id,
      slugKey: 'lumen-bridal-prep',
      category: 'photography',
      title: loc('Bridal prep album', 'ألبوم تحضير العروس'),
      description: loc('Getting-ready photos, family formals, and a same-week preview.', 'صور التحضير والعائلة ومعاينة خلال الأسبوع.'),
      city: 'Sharjah',
      price: 2800,
      cover: 'https://images.unsplash.com/photo-1511285560929-80b456fe3cdb?auto=format&fit=crop&w=1400&q=80',
      rating: 9.0,
      reviews: 53,
    },
    {
      vendorId: extraVendorRows[0]?.vendorId ?? input.lumen.id,
      slugKey: 'bloom-aisle-arch',
      category: 'florist',
      title: loc('Aisle and stage florals', 'زهور الممر والمسرح'),
      description: loc('Seasonal arch, table meadows, and toss petals.', 'قوس موسمي ومروج طاولات وبتلات.'),
      city: 'Dubai',
      price: 7500,
      cover: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=1400&q=80',
      rating: 8.7,
      reviews: 29,
    },
    {
      vendorId: extraVendorRows[1]?.vendorId ?? input.voyage.id,
      slugKey: 'beats-reception-set',
      category: 'dj',
      title: loc('Reception DJ + sax', 'دي جي الاستقبال مع ساكس'),
      description: loc('Four-hour set, wireless mics, and a sax guest.', 'مجموعة أربع ساعات وميكروفونات لاسلكية وضيف ساكس.'),
      city: 'Abu Dhabi',
      price: 3200,
      cover: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1400&q=80',
      rating: 8.6,
      reviews: 37,
    },
    {
      vendorId: extraVendorRows[0]?.vendorId ?? input.palms.id,
      slugKey: 'bloom-centerpieces',
      category: 'decoration',
      title: loc('Ballroom tablescape styling', 'تنسيق طاولات القاعة'),
      description: loc('Linens, candles, and statement centerpieces.', 'مفارش وشموع وقطع وسط الطاولة.'),
      city: 'Dubai',
      price: 5400,
      cover: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1400&q=80',
      rating: 8.5,
      reviews: 22,
    },
  ];

  for (const item of listings) {
    const categoryId = input.serviceCategoryIds[item.category];
    if (!categoryId) {
      continue;
    }
    const existing = await prisma.listing.findFirst({
      where: { vendorId: item.vendorId, coverKey: item.cover, deletedAt: null },
    });
    if (existing) {
      continue;
    }
    const listing = await prisma.listing.create({
      data: {
        vendorId: item.vendorId,
        categoryId,
        title: item.title,
        description: item.description,
        city: item.city,
        country: 'AE',
        coverKey: item.cover,
        galleryKeys: [item.cover],
        startingPrice: item.price,
        ratingAvg: item.rating,
        ratingCount: item.reviews,
        isPublished: true,
      },
    });
    await prisma.listingPackage.create({
      data: {
        listingId: listing.id,
        name: loc('Signature package', 'باقة مميزة'),
        description: loc('Most booked option for weekend events.', 'الخيار الأكثر حجزاً لمناسبات نهاية الأسبوع.'),
        priceAmount: item.price,
        durationHours: 8,
      },
    });
  }

  const extraCars = [
    {
      name: loc('Rolls-Royce Phantom arrival', 'وصول رولز رويس فانتوم'),
      description: loc('White Phantom with ribbon and chauffeur.', 'فانتوم بيضاء مع شريط وسائق.'),
      make: 'Rolls-Royce',
      model: 'Phantom',
      cover: 'https://images.unsplash.com/photo-1563720360172-67b8f3dce741?auto=format&fit=crop&w=1400&q=80',
      rate: 2800,
    },
    {
      name: loc('Vintage Beetle photo car', 'سيارة بيتل كلاسيكية للصور'),
      description: loc('Two-hour photo loop around the Corniche.', 'جولة صور لساعتين على الكورنيش.'),
      make: 'Volkswagen',
      model: 'Beetle',
      cover: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1400&q=80',
      rate: 650,
    },
  ];
  for (const car of extraCars) {
    const exists = await prisma.car.findFirst({ where: { vendorId: input.voyage.id, coverKey: car.cover, deletedAt: null } });
    if (exists) {
      continue;
    }
    await prisma.car.create({
      data: {
        vendorId: input.voyage.id,
        name: car.name,
        description: car.description,
        make: car.make,
        model: car.model,
        year: 2023,
        seats: 4,
        transmission: 'AUTOMATIC',
        dailyRate: car.rate,
        coverKey: car.cover,
        galleryKeys: [car.cover],
        isPublished: true,
      },
    });
  }

  const extraStays = [
    {
      name: loc('Ras Al Khaimah beach bungalow', 'بنغالو شاطئ رأس الخيمة'),
      description: loc('Private bungalow with terrace, kitchen, and beach access.', 'بنغالو خاص مع تراس ومطبخ ومدخل للشاطئ.'),
      cover: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=1400&q=80',
      rate: 2400,
      type: 'BUNGALOW' as const,
      city: 'Ras Al Khaimah',
    },
    {
      name: loc('Jumeirah bridal suite', 'جناح العروس في جميرا'),
      description: loc('King suite with spa credit and late checkout.', 'جناح كينغ مع رصيد سبا ومغادرة متأخرة.'),
      cover: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1400&q=80',
      rate: 3100,
    },
    {
      name: loc('Al Ain desert camp night', 'ليلة مخيم العين'),
      description: loc('Private tent, stargazing, and breakfast.', 'خيمة خاصة ورصد نجوم وإفطار.'),
      cover: 'https://images.unsplash.com/photo-1501117716987-c8e1ecb2101f?auto=format&fit=crop&w=1400&q=80',
      rate: 1800,
    },
  ];
  for (const stay of extraStays) {
    const exists = await prisma.accommodation.findFirst({
      where: { vendorId: input.voyage.id, coverKey: stay.cover, deletedAt: null },
    });
    if (exists) {
      continue;
    }
    await prisma.accommodation.create({
      data: {
        vendorId: input.voyage.id,
        name: stay.name,
        description: stay.description,
        type: 'type' in stay && stay.type ? stay.type : 'HOTEL_ROOM',
        address: loc('United Arab Emirates', 'الإمارات العربية المتحدة'),
        city: 'city' in stay && stay.city ? stay.city : 'Dubai',
        country: 'AE',
        latitude: 25.2,
        longitude: 55.27,
        maxGuests: 2,
        bedrooms: 1,
        bathrooms: 1,
        nightlyRate: stay.rate,
        amenities: ['breakfast', 'spa'],
        coverKey: stay.cover,
        galleryKeys: [stay.cover],
        isPublished: true,
      },
    });
  }

  const extraHoneymoon = [
    {
      name: loc('Santorini cliff three nights', 'ثلاث ليالٍ على منحدر سانتوريني'),
      description: loc('Cave suite, sunset dinner, and airport transfers.', 'جناح كهف وعشاء غروب وانتقالات المطار.'),
      dest: loc('Santorini', 'سانتوريني'),
      cover: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=1400&q=80',
      nights: 3,
      price: 9800,
    },
    {
      name: loc('Amalfi driving week', 'أسبوع قيادة أمالفي'),
      description: loc('Convertible, boutique hotels, and tasting lunches.', 'سيارة مكشوفة وفنادق بوتيك وغداء تذوق.'),
      dest: loc('Amalfi Coast', 'ساحل أمالفي'),
      cover: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1400&q=80',
      nights: 7,
      price: 16400,
    },
  ];
  for (const trip of extraHoneymoon) {
    const exists = await prisma.honeymoonPackage.findFirst({
      where: { vendorId: input.voyage.id, coverKey: trip.cover, deletedAt: null },
    });
    if (exists) {
      continue;
    }
    await prisma.honeymoonPackage.create({
      data: {
        vendorId: input.voyage.id,
        name: trip.name,
        description: trip.description,
        destination: trip.dest,
        nights: trip.nights,
        priceAmount: trip.price,
        coverKey: trip.cover,
        galleryKeys: [trip.cover],
        inclusions: ['transfers', 'breakfast'],
        isPublished: true,
      },
    });
  }

  const extraVenues = [
    {
      name: loc('Ras Al Khaimah mountain lodge', 'نزل جبل رأس الخيمة'),
      description: loc('Indoor-outdoor lodge for 60–160 guests.', 'نزل داخلي وخارجي لـ 60 إلى 160 ضيفاً.'),
      city: 'Ras Al Khaimah',
      lat: 25.8007,
      lng: 55.9762,
      cover: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1400&q=80',
      min: 60,
      max: 160,
      rating: 8.3,
      reviews: 45,
    },
    {
      name: loc('Al Ain oasis courtyard', 'فناء واحة العين'),
      description: loc('Palm courtyard for family gatherings.', 'فناء نخيل للتجمعات العائلية.'),
      city: 'Al Ain',
      lat: 24.2075,
      lng: 55.7447,
      cover: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1400&q=80',
      min: 30,
      max: 120,
      rating: 8.1,
      reviews: 33,
    },
  ];
  for (const item of extraVenues) {
    const existing = await prisma.venue.findFirst({
      where: { vendorId: input.palms.id, city: item.city, deletedAt: null },
    });
    if (existing) {
      continue;
    }
    const venue = await prisma.venue.create({
      data: {
        vendorId: input.palms.id,
        name: item.name,
        description: item.description,
        address: loc(`${item.city}, United Arab Emirates`, `${item.city}، الإمارات`),
        city: item.city,
        country: 'AE',
        latitude: item.lat,
        longitude: item.lng,
        capacityMin: item.min,
        capacityMax: item.max,
        amenities: ['parking', 'av'],
        galleryKeys: [item.cover],
        coverKey: item.cover,
        ratingAvg: item.rating,
        ratingCount: item.reviews,
        isPublished: true,
      },
    });
    await prisma.venuePackage.create({
      data: {
        venueId: venue.id,
        name: loc('Evening hire', 'استئجار مسائي'),
        description: loc('Six-hour exclusive use.', 'استخدام حصري لست ساعات.'),
        priceAmount: 9000,
        guestCountMin: item.min,
        guestCountMax: item.max,
        durationHours: 6,
      },
    });
  }

  const birthday = await prisma.eventCategory.findUnique({ where: { slug: 'birthday' } });
  if (birthday) {
    const exists = await prisma.event.findFirst({
      where: { customerId: input.guestId, categoryId: birthday.id, deletedAt: null },
    });
    if (!exists) {
      await prisma.event.create({
        data: {
          customerId: input.guestId,
          categoryId: birthday.id,
          title: loc('Noor 30th garden party', 'حفلة حديقة نور الثلاثين'),
          description: loc('Sunset gathering for 70 guests.', 'تجمع عند الغروب لـ 70 ضيفاً.'),
          eventDate: new Date(Date.now() + 1000 * 60 * 60 * 24 * 20),
          guestCount: 70,
          city: 'Dubai',
          country: 'AE',
          budgetMin: 8000,
          budgetMax: 18000,
          status: 'planning',
        },
      });
    }
  }
}

async function seedDemoJourney(input: {
  guestId: string;
  palmsUserId: string;
  palmsVendorId: string;
  lumenVendorId: string;
  voyageVendorId: string;
  venue: { id: string };
}): Promise<void> {
  const wedding = await prisma.eventCategory.findUnique({ where: { slug: 'wedding' } });
  if (!wedding) {
    return;
  }

  let event = await prisma.event.findFirst({ where: { customerId: input.guestId, deletedAt: null } });
  event ??= await prisma.event.create({
    data: {
      customerId: input.guestId,
      categoryId: wedding.id,
      title: loc('Layla & Karim wedding weekend', 'عطلة زفاف ليلى وكريم'),
      description: loc('Ceremony at Palms Ballroom, dinner for 180 guests.', 'المراسم في قاعة النخيل، عشاء لـ 180 ضيفاً.'),
      eventDate: new Date(Date.now() + 1000 * 60 * 60 * 24 * 45),
      guestCount: 180,
      city: 'Dubai',
      country: 'AE',
      budgetMin: 40000,
      budgetMax: 85000,
      status: 'planning',
    },
  });

  const pkg = await prisma.venuePackage.findFirst({ where: { venueId: input.venue.id, deletedAt: null } });
  const listing = await prisma.listing.findFirst({ where: { vendorId: input.lumenVendorId, deletedAt: null } });
  const car = await prisma.car.findFirst({ where: { vendorId: input.voyageVendorId, deletedAt: null } });
  const stay = await prisma.accommodation.findFirst({ where: { vendorId: input.voyageVendorId, deletedAt: null } });
  const honeymoon = await prisma.honeymoonPackage.findFirst({ where: { vendorId: input.voyageVendorId, deletedAt: null } });

  const start = new Date(Date.now() + 1000 * 60 * 60 * 24 * 45);
  const end = new Date(start.getTime() + 1000 * 60 * 60 * 8);

  const bookings = [
    {
      bookingNumber: 'ZY-1001',
      type: BookingType.VENUE,
      status: BookingStatus.CONFIRMED,
      vendorId: input.palmsVendorId,
      venueId: input.venue.id,
      venuePackageId: pkg?.id,
      listingId: null as string | null,
      carId: null as string | null,
      accommodationId: null as string | null,
      honeymoonId: null as string | null,
      subtotalAmount: 18000,
      commissionAmount: 1800,
      depositAmount: 5000,
      balanceAmount: 13000,
      totalAmount: 18000,
    },
    {
      bookingNumber: 'ZY-1002',
      type: BookingType.LISTING,
      status: BookingStatus.PENDING,
      vendorId: input.lumenVendorId,
      venueId: null,
      venuePackageId: null,
      listingId: listing?.id ?? null,
      carId: null,
      accommodationId: null,
      honeymoonId: null,
      subtotalAmount: 8500,
      commissionAmount: 850,
      depositAmount: 2000,
      balanceAmount: 6500,
      totalAmount: 8500,
    },
    {
      bookingNumber: 'ZY-1003',
      type: BookingType.CAR,
      status: BookingStatus.INQUIRY,
      vendorId: input.voyageVendorId,
      venueId: null,
      venuePackageId: null,
      listingId: null,
      carId: car?.id ?? null,
      accommodationId: null,
      honeymoonId: null,
      subtotalAmount: 1200,
      commissionAmount: 120,
      depositAmount: 0,
      balanceAmount: 1200,
      totalAmount: 1200,
    },
    {
      bookingNumber: 'ZY-1004',
      type: BookingType.ACCOMMODATION,
      status: BookingStatus.CONFIRMED,
      vendorId: input.voyageVendorId,
      venueId: null,
      venuePackageId: null,
      listingId: null,
      carId: null,
      accommodationId: stay?.id ?? null,
      honeymoonId: null,
      subtotalAmount: 2200,
      commissionAmount: 220,
      depositAmount: 500,
      balanceAmount: 1700,
      totalAmount: 2200,
    },
    {
      bookingNumber: 'ZY-1005',
      type: BookingType.HONEYMOON,
      status: BookingStatus.PENDING,
      vendorId: input.voyageVendorId,
      venueId: null,
      venuePackageId: null,
      listingId: null,
      carId: null,
      accommodationId: null,
      honeymoonId: honeymoon?.id ?? null,
      subtotalAmount: 18900,
      commissionAmount: 1890,
      depositAmount: 4000,
      balanceAmount: 14900,
      totalAmount: 18900,
    },
  ];

  for (const row of bookings) {
    await prisma.booking.upsert({
      where: { bookingNumber: row.bookingNumber },
      update: { status: row.status, totalAmount: row.totalAmount },
      create: {
        bookingNumber: row.bookingNumber,
        type: row.type,
        status: row.status,
        customerId: input.guestId,
        vendorId: row.vendorId,
        eventId: event.id,
        venueId: row.venueId,
        venuePackageId: row.venuePackageId,
        listingId: row.listingId,
        carId: row.carId,
        accommodationId: row.accommodationId,
        honeymoonId: row.honeymoonId,
        startAt: start,
        endAt: end,
        guestCount: 180,
        subtotalAmount: row.subtotalAmount,
        commissionAmount: row.commissionAmount,
        depositAmount: row.depositAmount,
        balanceAmount: row.balanceAmount,
        totalAmount: row.totalAmount,
        notes: loc('Demo reservation for product walkthrough', 'حجز تجريبي لجولة المنتج'),
      },
    });
  }

  const visitExists = await prisma.venueVisit.findFirst({
    where: { customerId: input.guestId, venueId: input.venue.id, deletedAt: null },
  });
  if (!visitExists) {
    await prisma.venueVisit.create({
      data: {
        customerId: input.guestId,
        venueId: input.venue.id,
        scheduledAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7),
        notes: loc('Prefer late afternoon light for photos', 'يفضّل ضوء العصر للصور'),
      },
    });
  }

  await prisma.favorite.upsert({
    where: {
      userId_resourceType_resourceId: {
        userId: input.guestId,
        resourceType: FavoriteResourceType.VENUE,
        resourceId: input.venue.id,
      },
    },
    update: {},
    create: {
      userId: input.guestId,
      resourceType: FavoriteResourceType.VENUE,
      resourceId: input.venue.id,
    },
  });

  const chat = await prisma.conversation.findFirst({
    where: {
      type: ConversationType.CUSTOMER_VENDOR,
      participantAId: input.guestId,
      participantBId: input.palmsUserId,
    },
  });
  if (!chat) {
    const conversation = await prisma.conversation.create({
      data: {
        type: ConversationType.CUSTOMER_VENDOR,
        participantAId: input.guestId,
        participantBId: input.palmsUserId,
        lastMessageAt: new Date(),
      },
    });
    await prisma.message.create({
      data: {
        conversationId: conversation.id,
        senderId: input.palmsUserId,
        body: 'Welcome to Palms Ballroom — we held 18 April for your viewing. Shall we add a tasting?',
      },
    });
  }

  const photo = await prisma.listing.findFirst({ where: { vendorId: input.lumenVendorId, deletedAt: null } });
  if (photo) {
    await prisma.listing.update({
      where: { id: photo.id },
      data: {
        coverKey: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1400&q=80',
        galleryKeys: ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1400&q=80'],
        ratingAvg: 9.2,
        ratingCount: 88,
      },
    });
  }
}

main()
  .catch((error: unknown) => {
    // eslint-disable-next-line no-console
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
