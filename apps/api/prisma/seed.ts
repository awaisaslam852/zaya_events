import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import dotenv from 'dotenv';
import {
  PrismaClient,
  Role,
  UserStatus,
  VendorStatus,
  BannerPlacement,
  BookingType,
  BookingStatus,
  FavoriteResourceType,
  ConversationType,
  PaymentKind,
  PaymentStatus,
  InvoiceStatus,
  CommissionStatus,
  PayoutStatus,
  CrmSubjectType,
  CrmInteractionType,
  CarTransmission,
  AccommodationType,
} from '@prisma/client';
import bcrypt from 'bcryptjs';
import { splitCommission } from '../src/lib/commission-split.js';

for (const candidate of [resolve(process.cwd(), '../../.env'), resolve(process.cwd(), '.env')]) {
  if (existsSync(candidate)) {
    dotenv.config({ path: candidate });
  }
}

const prisma = new PrismaClient();
const loc = (en: string, ar: string) => ({ en, ar });
const days = (n: number) => new Date(Date.now() + n * 24 * 60 * 60 * 1000);
const DEMO_PASSWORD = 'ZayaDemo!2026';
const SUPER_EMAIL = process.env.SEED_ADMIN_EMAIL ?? 'admin@zayaevents.com';
const SUPER_PASSWORD = process.env.SEED_ADMIN_PASSWORD ?? 'ChangeMeAdmin!123';

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

type Person = {
  email: string;
  firstName: string;
  lastName: string;
  phone: string;
  city: string;
};

type Desk = {
  code: 'AE' | 'SA' | 'PK';
  currency: string;
  countryEn: string;
  countryAr: string;
  admin: Person;
  customers: Person[];
  venueVendor: Person & {
    businessEn: string;
    businessAr: string;
    aboutEn: string;
    aboutAr: string;
    venues: Array<{
      nameEn: string;
      nameAr: string;
      descEn: string;
      descAr: string;
      city: string;
      lat: number;
      lng: number;
      min: number;
      max: number;
      price: number;
      cover: string;
      rating: number;
      reviews: number;
    }>;
  };
  studioVendor: Person & {
    businessEn: string;
    businessAr: string;
    aboutEn: string;
    aboutAr: string;
    listings: Array<{
      category: string;
      titleEn: string;
      titleAr: string;
      descEn: string;
      descAr: string;
      city: string;
      price: number;
      cover: string;
      rating: number;
      reviews: number;
    }>;
  };
  travelVendor: Person & {
    businessEn: string;
    businessAr: string;
    aboutEn: string;
    aboutAr: string;
    cars: Array<{ nameEn: string; nameAr: string; descEn: string; descAr: string; make: string; model: string; rate: number; cover: string }>;
    stay: { nameEn: string; nameAr: string; descEn: string; descAr: string; city: string; rate: number; cover: string; type: AccommodationType };
    honeymoon: { nameEn: string; nameAr: string; descEn: string; descAr: string; destEn: string; destAr: string; nights: number; price: number; cover: string };
  };
};

const DESKS: Desk[] = [
  {
    code: 'AE',
    currency: 'AED',
    countryEn: 'United Arab Emirates',
    countryAr: 'الإمارات العربية المتحدة',
    admin: {
      email: 'uae.admin@zayaevents.com',
      firstName: 'Aisha',
      lastName: 'Al Mansoori',
      phone: '+971501110001',
      city: 'Dubai',
    },
    customers: [
      { email: 'amira.uae@zayaevents.com', firstName: 'Amira', lastName: 'Haddad', phone: '+971501110101', city: 'Dubai' },
      { email: 'karim.uae@zayaevents.com', firstName: 'Karim', lastName: 'Nasser', phone: '+971501110102', city: 'Abu Dhabi' },
      { email: 'lina.uae@zayaevents.com', firstName: 'Lina', lastName: 'Farouk', phone: '+971501110103', city: 'Sharjah' },
    ],
    venueVendor: {
      email: 'venues.uae@zayaevents.com',
      firstName: 'Layla',
      lastName: 'Hassan',
      phone: '+971501110201',
      city: 'Dubai',
      businessEn: 'Palms Venue Collective',
      businessAr: 'مجموعة قاعات النخيل',
      aboutEn: 'Grand wedding halls and garden pavilions across Dubai and Abu Dhabi.',
      aboutAr: 'قاعات زفاف كبرى وأجنحة حدائق في دبي وأبوظبي.',
      venues: [
        {
          nameEn: 'Palms Ballroom Downtown',
          nameAr: 'قاعة النخيل داون تاون',
          descEn: 'Marble ballroom with a garden terrace for 80–400 guests, bridal suite, and in-house lighting.',
          descAr: 'قاعة رخامية مع تراس حديقة تتسع من 80 إلى 400 ضيف مع جناح عروس وإضاءة.',
          city: 'Dubai',
          lat: 25.2048,
          lng: 55.2708,
          min: 80,
          max: 400,
          price: 28000,
          cover: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1600&q=80',
          rating: 9.2,
          reviews: 186,
        },
        {
          nameEn: 'Saadiyat Orchid Hall',
          nameAr: 'قاعة أوركيد السعديات',
          descEn: 'Beach-side hall for ceremonies and corporate galas, with valet and sea-view foyer.',
          descAr: 'قاعة قرب الشاطئ للمراسم وحفلات الشركات مع خدمة صف السيارات.',
          city: 'Abu Dhabi',
          lat: 24.4539,
          lng: 54.3773,
          min: 60,
          max: 280,
          price: 22000,
          cover: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1600&q=80',
          rating: 8.9,
          reviews: 124,
        },
      ],
    },
    studioVendor: {
      email: 'studio.uae@zayaevents.com',
      firstName: 'Omar',
      lastName: 'Farid',
      phone: '+971501110202',
      city: 'Dubai',
      businessEn: 'Lumen Studio',
      businessAr: 'ستوديو لومين',
      aboutEn: 'Cinematic photography, films, and floral styling for Gulf weddings.',
      aboutAr: 'تصوير سينمائي وأفلام وتنسيق زهور لحفلات الخليج.',
      listings: [
        {
          category: 'photography',
          titleEn: 'Full-day wedding film & album',
          titleAr: 'فيلم وألبوم زفاف ليوم كامل',
          descEn: 'Two shooters, highlight film, 400 edited photos, and a same-week preview gallery.',
          descAr: 'مصوران وفيلم أبرز اللحظات و400 صورة معدّلة ومعاينة خلال الأسبوع.',
          city: 'Dubai',
          price: 8500,
          cover: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=1600&q=80',
          rating: 9.4,
          reviews: 92,
        },
        {
          category: 'florist',
          titleEn: 'Aisle arch and tablescape florals',
          titleAr: 'قوس الممر وزهور الطاولات',
          descEn: 'Seasonal arch, meadow centerpieces, and toss petals for 150–250 guests.',
          descAr: 'قوس موسمي ومروج وسط الطاولة وبتلات لـ 150 إلى 250 ضيفاً.',
          city: 'Dubai',
          price: 7200,
          cover: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=1600&q=80',
          rating: 8.8,
          reviews: 47,
        },
        {
          category: 'catering',
          titleEn: 'Live-station reception menu',
          titleAr: 'قائمة استقبال بمحطات حية',
          descEn: 'Arabic and international live stations, dessert atelier, and service staff.',
          descAr: 'محطات عربية وعالمية وورشة حلويات وطاقم خدمة.',
          city: 'Abu Dhabi',
          price: 185,
          cover: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=1600&q=80',
          rating: 9.0,
          reviews: 61,
        },
      ],
    },
    travelVendor: {
      email: 'travel.uae@zayaevents.com',
      firstName: 'Noor',
      lastName: 'Al Mazrouei',
      phone: '+971501110203',
      city: 'Dubai',
      businessEn: 'Voyage Atelier',
      businessAr: 'أتيليه فوياج',
      aboutEn: 'Bridal cars, overnight suites, and honeymoon packages from Dubai.',
      aboutAr: 'سيارات العروس وأجنحة لليلة وبرامج شهر عسل من دبي.',
      cars: [
        {
          nameEn: 'Mercedes S-Class chauffeur',
          nameAr: 'مرسيدس إس كلاس مع سائق',
          descEn: 'White S-Class with professional chauffeur for ceremony transfers.',
          descAr: 'إس كلاس بيضاء مع سائق محترف لتنقلات المراسم.',
          make: 'Mercedes-Benz',
          model: 'S-Class',
          rate: 1400,
          cover: 'https://images.unsplash.com/photo-1549924231-f129b911e442?auto=format&fit=crop&w=1600&q=80',
        },
        {
          nameEn: 'Rolls-Royce Phantom arrival',
          nameAr: 'وصول رولز رويس فانتوم',
          descEn: 'Ribboned Phantom for the couple’s grand entrance.',
          descAr: 'فانتوم مزينة بشريط لدخول العروسين.',
          make: 'Rolls-Royce',
          model: 'Phantom',
          rate: 3200,
          cover: 'https://images.unsplash.com/photo-1563720360172-67b8f3dce741?auto=format&fit=crop&w=1600&q=80',
        },
      ],
      stay: {
        nameEn: 'Palm Suite overnight',
        nameAr: 'جناح النخلة لليلة واحدة',
        descEn: 'Sea-view king suite with breakfast and late checkout after the reception.',
        descAr: 'جناح كينغ بإطلالة بحرية مع إفطار ومغادرة متأخرة.',
        city: 'Dubai',
        rate: 2400,
        cover: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?auto=format&fit=crop&w=1600&q=80',
        type: AccommodationType.HOTEL_ROOM,
      },
      honeymoon: {
        nameEn: 'Maldives overwater week',
        nameAr: 'أسبوع المالديف فوق الماء',
        descEn: 'Seven nights in an overwater villa, seaplane transfers, and half board.',
        descAr: 'سبع ليالٍ في فيلا فوق الماء مع طائرة مائية ونصف إقامة.',
        destEn: 'Maldives',
        destAr: 'المالديف',
        nights: 7,
        price: 18900,
        cover: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=1600&q=80',
      },
    },
  },
  {
    code: 'SA',
    currency: 'SAR',
    countryEn: 'Saudi Arabia',
    countryAr: 'المملكة العربية السعودية',
    admin: {
      email: 'ksa.admin@zayaevents.com',
      firstName: 'Fahad',
      lastName: 'Al Qahtani',
      phone: '+966501110001',
      city: 'Riyadh',
    },
    customers: [
      { email: 'hanan.ksa@zayaevents.com', firstName: 'Hanan', lastName: 'Al Rashid', phone: '+966501110101', city: 'Riyadh' },
      { email: 'yusuf.ksa@zayaevents.com', firstName: 'Yusuf', lastName: 'Al Harbi', phone: '+966501110102', city: 'Jeddah' },
      { email: 'maryam.ksa@zayaevents.com', firstName: 'Maryam', lastName: 'Al Dosari', phone: '+966501110103', city: 'Dammam' },
    ],
    venueVendor: {
      email: 'venues.ksa@zayaevents.com',
      firstName: 'Faisal',
      lastName: 'Al Otaibi',
      phone: '+966501110201',
      city: 'Riyadh',
      businessEn: 'Najd Palaces',
      businessAr: 'قصور نجد',
      aboutEn: 'Private palaces and ballrooms for Riyadh and Jeddah celebrations.',
      aboutAr: 'قصور وقاعات خاصة لمناسبات الرياض وجدة.',
      venues: [
        {
          nameEn: 'Diriyah Royal Hall',
          nameAr: 'قاعة الدرعية الملكية',
          descEn: 'Private palace hall for 120–500 guests with majlis, valet, and catering kitchen.',
          descAr: 'قاعة قصر خاص لـ 120 إلى 500 ضيف مع مجلس وخدمة صف سيارات.',
          city: 'Riyadh',
          lat: 24.7136,
          lng: 46.6753,
          min: 120,
          max: 500,
          price: 45000,
          cover: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1600&q=80',
          rating: 9.3,
          reviews: 158,
        },
        {
          nameEn: 'Corniche Pearl Ballroom',
          nameAr: 'قاعة لؤلؤة الكورنيش',
          descEn: 'Red Sea view ballroom for Jeddah weddings and gala dinners.',
          descAr: 'قاعة بإطلالة على البحر الأحمر لزفاف جدة والعشاء الرسمي.',
          city: 'Jeddah',
          lat: 21.5433,
          lng: 39.1728,
          min: 80,
          max: 320,
          price: 36000,
          cover: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1600&q=80',
          rating: 9.0,
          reviews: 101,
        },
      ],
    },
    studioVendor: {
      email: 'studio.ksa@zayaevents.com',
      firstName: 'Reem',
      lastName: 'Al Ghamdi',
      phone: '+966501110202',
      city: 'Riyadh',
      businessEn: 'Al Noor Films',
      businessAr: 'أفلام النور',
      aboutEn: 'Wedding films, beauty teams, and stage production in Saudi cities.',
      aboutAr: 'أفلام زفاف وفرق تجميل وإنتاج مسرح في مدن السعودية.',
      listings: [
        {
          category: 'videography',
          titleEn: 'Two-day wedding cinema',
          titleAr: 'سينما زفاف ليومين',
          descEn: 'Henna and reception coverage, drone, and a 12-minute family film.',
          descAr: 'تغطية الحناء والاستقبال ودرون وفيلم عائلي 12 دقيقة.',
          city: 'Riyadh',
          price: 14000,
          cover: 'https://images.unsplash.com/photo-1606800052052-a08af7148866?auto=format&fit=crop&w=1600&q=80',
          rating: 9.5,
          reviews: 73,
        },
        {
          category: 'makeup',
          titleEn: 'Bridal beauty atelier',
          titleAr: 'أتيليه تجميل العروس',
          descEn: 'Trial, wedding-day makeup, hair, and two bridesmaids.',
          descAr: 'تجربة ومكياج يوم الزفاف وتصفيف وشابتان.',
          city: 'Jeddah',
          price: 4800,
          cover: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1600&q=80',
          rating: 9.1,
          reviews: 88,
        },
        {
          category: 'production',
          titleEn: 'Stage lighting and LED wall',
          titleAr: 'إضاءة مسرح وجدار LED',
          descEn: 'Full production crew, LED wall, and wireless audio for 300 guests.',
          descAr: 'طاقم إنتاج كامل وجدار LED وصوت لاسلكي لـ 300 ضيف.',
          city: 'Riyadh',
          price: 16000,
          cover: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1600&q=80',
          rating: 8.7,
          reviews: 39,
        },
      ],
    },
    travelVendor: {
      email: 'travel.ksa@zayaevents.com',
      firstName: 'Majed',
      lastName: 'Al Harbi',
      phone: '+966501110203',
      city: 'Jeddah',
      businessEn: 'Desert Trail Travel',
      businessAr: 'مسار الصحراء للسفر',
      aboutEn: 'Chauffeured cars, Red Sea stays, and honeymoon escapes from Jeddah.',
      aboutAr: 'سيارات مع سائق وإقامة البحر الأحمر ورحلات شهر عسل من جدة.',
      cars: [
        {
          nameEn: 'Cadillac Escalade family transfer',
          nameAr: 'كاديلاك إسكاليد لنقل العائلة',
          descEn: 'Seven-seat Escalade with driver for family airport and hall transfers.',
          descAr: 'إسكاليد بسبع مقاعد مع سائق لتنقلات المطار والقاعة.',
          make: 'Cadillac',
          model: 'Escalade',
          rate: 1800,
          cover: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1600&q=80',
        },
        {
          nameEn: 'BMW 7 Series couple car',
          nameAr: 'بي إم دبليو الفئة السابعة للعروسين',
          descEn: 'Black 7 Series with white interior for the couple’s arrival.',
          descAr: 'الفئة السابعة سوداء مع داخل أبيض لوصول العروسين.',
          make: 'BMW',
          model: '740i',
          rate: 1600,
          cover: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1600&q=80',
        },
      ],
      stay: {
        nameEn: 'Obhur beach villa weekend',
        nameAr: 'فيلا شاطئ أبحر لنهاية الأسبوع',
        descEn: 'Private Red Sea villa with pool, chef kitchen, and four bedrooms.',
        descAr: 'فيلا خاصة على البحر الأحمر مع مسبح ومطبخ شيف وأربع غرف.',
        city: 'Jeddah',
        rate: 5200,
        cover: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=1600&q=80',
        type: AccommodationType.VILLA,
      },
      honeymoon: {
        nameEn: 'Santorini cliff three nights',
        nameAr: 'ثلاث ليالٍ على منحدر سانتوريني',
        descEn: 'Cave suite, sunset dinner, and private transfers after the wedding week.',
        descAr: 'جناح كهف وعشاء غروب وانتقالات خاصة بعد أسبوع الزفاف.',
        destEn: 'Santorini',
        destAr: 'سانتوريني',
        nights: 3,
        price: 12800,
        cover: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=1600&q=80',
      },
    },
  },
  {
    code: 'PK',
    currency: 'PKR',
    countryEn: 'Pakistan',
    countryAr: 'باكستان',
    admin: {
      email: 'pk.admin@zayaevents.com',
      firstName: 'Sana',
      lastName: 'Malik',
      phone: '+923001110001',
      city: 'Lahore',
    },
    customers: [
      { email: 'ayesha.pk@zayaevents.com', firstName: 'Ayesha', lastName: 'Khan', phone: '+923001110101', city: 'Lahore' },
      { email: 'bilal.pk@zayaevents.com', firstName: 'Bilal', lastName: 'Ahmed', phone: '+923001110102', city: 'Islamabad' },
      { email: 'fatima.pk@zayaevents.com', firstName: 'Fatima', lastName: 'Raza', phone: '+923001110103', city: 'Karachi' },
    ],
    venueVendor: {
      email: 'venues.pk@zayaevents.com',
      firstName: 'Hamza',
      lastName: 'Sheikh',
      phone: '+923001110201',
      city: 'Lahore',
      businessEn: 'Royal Gardens Events',
      businessAr: 'رويال غاردنز للفعاليات',
      aboutEn: 'Lawn and banquet halls for Lahore, Islamabad, and Karachi weddings.',
      aboutAr: 'حدائق وقاعات ولائم لزفاف لاهور وإسلام آباد وكراتشي.',
      venues: [
        {
          nameEn: 'DHA Royal Lawn',
          nameAr: 'حديقة دي إتش إيه الملكية',
          descEn: 'Covered lawn for 200–700 guests with bridal suite, valet, and stage.',
          descAr: 'حديقة مغطاة لـ 200 إلى 700 ضيف مع جناح عروس ومسرح.',
          city: 'Lahore',
          lat: 31.4697,
          lng: 74.4081,
          min: 200,
          max: 700,
          price: 1200000,
          cover: 'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?auto=format&fit=crop&w=1600&q=80',
          rating: 9.1,
          reviews: 210,
        },
        {
          nameEn: 'Clifton Sea View Banquet',
          nameAr: 'قاعة كليفتون بإطلالة البحر',
          descEn: 'Karachi banquet with sea-view terrace for mehndi and walima.',
          descAr: 'قاعة كراتشي مع تراس بحري للحناء والوليمة.',
          city: 'Karachi',
          lat: 24.8138,
          lng: 67.0305,
          min: 150,
          max: 500,
          price: 1050000,
          cover: 'https://images.unsplash.com/photo-1510070009289-b5bc34383727?auto=format&fit=crop&w=1600&q=80',
          rating: 8.8,
          reviews: 142,
        },
      ],
    },
    studioVendor: {
      email: 'studio.pk@zayaevents.com',
      firstName: 'Nadia',
      lastName: 'Iqbal',
      phone: '+923001110202',
      city: 'Lahore',
      businessEn: 'Frame & Light Studio',
      businessAr: 'ستوديو فريم آند لايت',
      aboutEn: 'Mehndi, baraat, and walima photography with décor and catering partners.',
      aboutAr: 'تصوير الحناء والبارات والوليمة مع شركاء ديكور وتموين.',
      listings: [
        {
          category: 'photography',
          titleEn: 'Three-event wedding coverage',
          titleAr: 'تغطية زفاف لثلاث مناسبات',
          descEn: 'Mehndi, baraat, and walima with two photographers and a cinematic edit.',
          descAr: 'حناء وبارات ووليمة مع مصورين وتعديل سينمائي.',
          city: 'Lahore',
          price: 500000,
          cover: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1600&q=80',
          rating: 9.3,
          reviews: 167,
        },
        {
          category: 'decoration',
          titleEn: 'Mehndi garden décor',
          titleAr: 'ديكور حديقة الحناء',
          descEn: 'Fresh florals, fairy lights, and a colourful stage for 300 guests.',
          descAr: 'زهور وإضاءة ومسرح ملون لـ 300 ضيف.',
          city: 'Lahore',
          price: 420000,
          cover: 'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=1600&q=80',
          rating: 8.9,
          reviews: 84,
        },
        {
          category: 'dj',
          titleEn: 'Baraat DJ and dhol',
          titleAr: 'دي جي البارات والدهول',
          descEn: 'Four-hour DJ set with live dhol for the baraat procession.',
          descAr: 'دي جي أربع ساعات مع دهول حي لموكب البارات.',
          city: 'Islamabad',
          price: 180000,
          cover: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1600&q=80',
          rating: 8.6,
          reviews: 58,
        },
      ],
    },
    travelVendor: {
      email: 'travel.pk@zayaevents.com',
      firstName: 'Ali',
      lastName: 'Raza',
      phone: '+923001110203',
      city: 'Islamabad',
      businessEn: 'Silk Route Journeys',
      businessAr: 'رحلات طريق الحرير',
      aboutEn: 'Wedding cars, Murree stays, and honeymoon trips from Islamabad.',
      aboutAr: 'سيارات زفاف وإقامة مري ورحلات شهر عسل من إسلام آباد.',
      cars: [
        {
          nameEn: 'Mercedes E-Class baraat car',
          nameAr: 'مرسيدس إي كلاس لموكب البارات',
          descEn: 'Decorated E-Class with chauffeur for the baraat arrival.',
          descAr: 'إي كلاس مزينة مع سائق لوصول البارات.',
          make: 'Mercedes-Benz',
          model: 'E-Class',
          rate: 65000,
          cover: 'https://images.unsplash.com/photo-1617531653332-bd46c24f2068?auto=format&fit=crop&w=1600&q=80',
        },
        {
          nameEn: 'Land Cruiser family convoy',
          nameAr: 'موكب لاند كروزر للعائلة',
          descEn: 'Two Land Cruisers for family transfers between hall and hotel.',
          descAr: 'لاند كروزران لتنقلات العائلة بين القاعة والفندق.',
          make: 'Toyota',
          model: 'Land Cruiser',
          rate: 80000,
          cover: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1600&q=80',
        },
      ],
      stay: {
        nameEn: 'Murree pine chalet',
        nameAr: 'شاليه صنوبر مري',
        descEn: 'Two-bedroom hillside chalet with fireplace and valley views.',
        descAr: 'شاليه بغرفتين على التل مع مدفأة وإطلالة واد.',
        city: 'Murree',
        rate: 55000,
        cover: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1600&q=80',
        type: AccommodationType.CHALET,
      },
      honeymoon: {
        nameEn: 'Amalfi driving week',
        nameAr: 'أسبوع قيادة أمالفي',
        descEn: 'Seven nights of boutique hotels, a convertible, and tasting lunches.',
        descAr: 'سبع ليالٍ في فنادق بوتيك وسيارة مكشوفة وغداء تذوق.',
        destEn: 'Amalfi Coast',
        destAr: 'ساحل أمالفي',
        nights: 7,
        price: 1800000,
        cover: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=1600&q=80',
      },
    },
  },
];

async function wipeOperationalData(): Promise<void> {
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE
      "Message",
      "Conversation",
      "Call",
      "CrmNote",
      "CrmInteraction",
      "CrmFollowUp",
      "Notification",
      "Payment",
      "Invoice",
      "Commission",
      "CountryCommissionPolicy",
      "Payout",
      "BookingStatusHistory",
      "Booking",
      "VenueVisit",
      "Favorite",
      "RefreshToken",
      "PasswordResetToken",
      "DeviceToken",
      "Upload",
      "AdminAuditLog",
      "ListingPackage",
      "Listing",
      "VenuePackage",
      "VenueAvailability",
      "Venue",
      "CarAvailability",
      "Car",
      "AccommodationAvailability",
      "Accommodation",
      "HoneymoonPackage",
      "Availability",
      "Representative",
      "FlightBooking",
      "HotelBooking",
      "Event",
      "Banner",
      "Vendor",
      "User"
    RESTART IDENTITY CASCADE
  `);
}

async function seedDesk(
  desk: Desk,
  passwordHash: string,
  categories: { wedding: string; engagement: string; birthday: string; corporate: string; family: string },
  serviceIds: Record<string, string>,
  bookingSeq: { n: number },
) {
  const admin = await prisma.user.create({
    data: {
      email: desk.admin.email,
      passwordHash,
      role: Role.ADMIN,
      status: UserStatus.ACTIVE,
      isSuperAdmin: false,
      allowedCountries: [desk.code],
      firstName: desk.admin.firstName,
      lastName: desk.admin.lastName,
      displayName: `${desk.admin.firstName} ${desk.admin.lastName}`,
      phone: desk.admin.phone,
      locale: 'en',
      country: desk.code,
      emailVerifiedAt: new Date(),
    },
  });

  const customers = [];
  for (const spec of desk.customers) {
    customers.push(
      await prisma.user.create({
        data: {
          email: spec.email,
          passwordHash,
          role: Role.CUSTOMER,
          status: UserStatus.ACTIVE,
          firstName: spec.firstName,
          lastName: spec.lastName,
          displayName: `${spec.firstName} ${spec.lastName}`,
          phone: spec.phone,
          locale: 'en',
          country: desk.code,
          emailVerifiedAt: new Date(),
        },
      }),
    );
  }

  async function createVendor(
    spec: Person & { businessEn: string; businessAr: string; aboutEn: string; aboutAr: string },
    commissionRate = 12,
  ) {
    const user = await prisma.user.create({
      data: {
        email: spec.email,
        passwordHash,
        role: Role.VENDOR,
        status: UserStatus.ACTIVE,
        firstName: spec.firstName,
        lastName: spec.lastName,
        displayName: `${spec.firstName} ${spec.lastName}`,
        phone: spec.phone,
        locale: 'en',
        country: desk.code,
        emailVerifiedAt: new Date(),
      },
    });
    const vendor = await prisma.vendor.create({
      data: {
        userId: user.id,
        businessName: loc(spec.businessEn, spec.businessAr),
        description: loc(spec.aboutEn, spec.aboutAr),
        legalName: spec.businessEn,
        status: VendorStatus.APPROVED,
        commissionRate,
        city: spec.city,
        country: desk.code,
        phone: spec.phone,
        website: `https://www.zayaevents.com/partners/${desk.code.toLowerCase()}`,
        ratingAvg: 9.0,
        ratingCount: 40,
      },
    });
    return { user, vendor };
  }

  const venuesPartner = await createVendor(desk.venueVendor, 12);
  const studioPartner = await createVendor(desk.studioVendor, 10);
  const travelPartner = await createVendor(desk.travelVendor, 12);

  const venues = [];
  for (const item of desk.venueVendor.venues) {
    const venue = await prisma.venue.create({
      data: {
        vendorId: venuesPartner.vendor.id,
        name: loc(item.nameEn, item.nameAr),
        description: loc(item.descEn, item.descAr),
        address: loc(`${item.city}, ${desk.countryEn}`, `${item.city}، ${desk.countryAr}`),
        city: item.city,
        country: desk.code,
        latitude: item.lat,
        longitude: item.lng,
        capacityMin: item.min,
        capacityMax: item.max,
        startingPrice: item.price,
        currency: desk.currency,
        pricingModel: 'HYBRID',
        amenities: ['parking', 'bridal-suite', 'av', 'valet', 'catering-kitchen'],
        coverKey: item.cover,
        galleryKeys: [item.cover],
        ratingAvg: item.rating,
        ratingCount: item.reviews,
        isPublished: true,
      },
    });
    const pkg = await prisma.venuePackage.create({
      data: {
        venueId: venue.id,
        name: loc('Signature reception', 'استقبال مميز'),
        description: loc('Exclusive evening hire with lighting and coordination.', 'استئجار مسائي حصري مع إضاءة وتنسيق.'),
        priceAmount: item.price,
        currency: desk.currency,
        guestCountMin: item.min,
        guestCountMax: item.max,
        durationHours: 8,
        pricingUnit: 'EVENT',
      },
    });
    venues.push({ venue, pkg, item });
  }

  const listings = [];
  for (const item of desk.studioVendor.listings) {
    const categoryId = serviceIds[item.category];
    if (!categoryId) {
      continue;
    }
    const listing = await prisma.listing.create({
      data: {
        vendorId: studioPartner.vendor.id,
        categoryId,
        title: loc(item.titleEn, item.titleAr),
        description: loc(item.descEn, item.descAr),
        city: item.city,
        country: desk.code,
        coverKey: item.cover,
        galleryKeys: [item.cover],
        startingPrice: item.price,
        currency: desk.currency,
        ratingAvg: item.rating,
        ratingCount: item.reviews,
        isPublished: true,
      },
    });
    const pkg = await prisma.listingPackage.create({
      data: {
        listingId: listing.id,
        name: loc('Most booked package', 'الباقة الأكثر حجزاً'),
        description: loc('Weekend signature option with senior team.', 'خيار نهاية الأسبوع مع الفريق الأول.'),
        priceAmount: item.price,
        currency: desk.currency,
        durationHours: 10,
      },
    });
    listings.push({ listing, pkg });
  }

  const cars = [];
  for (const item of desk.travelVendor.cars) {
    cars.push(
      await prisma.car.create({
        data: {
          vendorId: travelPartner.vendor.id,
          name: loc(item.nameEn, item.nameAr),
          description: loc(item.descEn, item.descAr),
          make: item.make,
          model: item.model,
          year: 2024,
          seats: 4,
          transmission: CarTransmission.AUTOMATIC,
          dailyRate: item.rate,
          currency: desk.currency,
          coverKey: item.cover,
          galleryKeys: [item.cover],
          isPublished: true,
        },
      }),
    );
  }

  const staySpec = desk.travelVendor.stay;
  const stay = await prisma.accommodation.create({
    data: {
      vendorId: travelPartner.vendor.id,
      name: loc(staySpec.nameEn, staySpec.nameAr),
      description: loc(staySpec.descEn, staySpec.descAr),
      type: staySpec.type,
      address: loc(`${staySpec.city}, ${desk.countryEn}`, `${staySpec.city}، ${desk.countryAr}`),
      city: staySpec.city,
      country: desk.code,
      latitude: venues[0]?.item.lat ?? 0,
      longitude: venues[0]?.item.lng ?? 0,
      maxGuests: 4,
      bedrooms: 2,
      bathrooms: 2,
      nightlyRate: staySpec.rate,
      currency: desk.currency,
      amenities: ['breakfast', 'parking', 'wifi'],
      coverKey: staySpec.cover,
      galleryKeys: [staySpec.cover],
      isPublished: true,
    },
  });

  const tripSpec = desk.travelVendor.honeymoon;
  const honeymoon = await prisma.honeymoonPackage.create({
    data: {
      vendorId: travelPartner.vendor.id,
      name: loc(tripSpec.nameEn, tripSpec.nameAr),
      description: loc(tripSpec.descEn, tripSpec.descAr),
      destination: loc(tripSpec.destEn, tripSpec.destAr),
      nights: tripSpec.nights,
      priceAmount: tripSpec.price,
      currency: desk.currency,
      coverKey: tripSpec.cover,
      galleryKeys: [tripSpec.cover],
      inclusions: ['transfers', 'breakfast', 'concierge'],
      isPublished: true,
    },
  });

  const [c1, c2, c3] = customers;
  const weddingEvent = await prisma.event.create({
    data: {
      customerId: c1.id,
      categoryId: categories.wedding,
      title: loc(`${c1.firstName} wedding weekend`, `عطلة زفاف ${c1.firstName}`),
      description: loc(`Ceremony and dinner for 180 guests in ${desk.customers[0].city}.`, `مراسم وعشاء لـ 180 ضيفاً في ${desk.customers[0].city}.`),
      eventDate: days(42),
      guestCount: 180,
      city: desk.customers[0].city,
      country: desk.code,
      budgetMin: venues[0].item.price,
      budgetMax: venues[0].item.price * 2,
      currency: desk.currency,
      status: 'planning',
    },
  });
  const secondEvent = await prisma.event.create({
    data: {
      customerId: c2.id,
      categoryId: desk.code === 'SA' ? categories.corporate : categories.engagement,
      title: loc(`${c2.firstName} celebration`, `مناسبة ${c2.firstName}`),
      description: loc('Intimate gathering with photography and a chauffeur arrival.', 'تجمع خاص مع تصوير ووصول بسائق.'),
      eventDate: days(28),
      guestCount: 80,
      city: desk.customers[1].city,
      country: desk.code,
      budgetMin: 3000,
      budgetMax: 12000,
      currency: desk.currency,
      status: 'planning',
    },
  });
  const thirdEvent = await prisma.event.create({
    data: {
      customerId: c3.id,
      categoryId: desk.code === 'SA' ? categories.family : categories.birthday,
      title: loc(`${c3.firstName} family weekend`, `عطلة عائلة ${c3.firstName}`),
      description: loc('Stay and honeymoon planning after the family party.', 'إقامة وتخطيط شهر عسل بعد الحفل العائلي.'),
      eventDate: days(21),
      guestCount: 40,
      city: desk.customers[2].city,
      country: desk.code,
      budgetMin: 1500,
      budgetMax: 8000,
      currency: desk.currency,
      status: 'planning',
    },
  });

  async function booking(input: {
    type: BookingType;
    status: BookingStatus;
    customerId: string;
    vendorId: string;
    eventId: string;
    venueId?: string;
    venuePackageId?: string;
    listingId?: string;
    listingPackageId?: string;
    carId?: string;
    accommodationId?: string;
    honeymoonId?: string;
    amount: number;
    vendorRate?: number;
    startOffset: number;
    guests: number;
  }) {
    bookingSeq.n += 1;
    const number = `ZY-${desk.code}-${String(bookingSeq.n).padStart(3, '0')}`;
    const deposit = input.status === BookingStatus.INQUIRY ? 0 : Math.round(input.amount * 0.3);
    const split = splitCommission({
      bookingAmount: input.amount,
      vendorRate: input.vendorRate ?? 12,
      hqShareRate: 30,
    });
    const commission = split.amount;
    const row = await prisma.booking.create({
      data: {
        bookingNumber: number,
        type: input.type,
        status: input.status,
        customerId: input.customerId,
        vendorId: input.vendorId,
        eventId: input.eventId,
        venueId: input.venueId,
        venuePackageId: input.venuePackageId,
        listingId: input.listingId,
        listingPackageId: input.listingPackageId,
        carId: input.carId,
        accommodationId: input.accommodationId,
        honeymoonId: input.honeymoonId,
        startAt: days(input.startOffset),
        endAt: days(input.startOffset),
        guestCount: input.guests,
        currency: desk.currency,
        subtotalAmount: input.amount,
        commissionAmount: commission,
        depositAmount: deposit,
        balanceAmount: input.amount - deposit,
        totalAmount: input.amount,
        notes: loc('Presentation booking for client walkthrough', 'حجز للعرض أمام العميل'),
      },
    });
    await prisma.bookingStatusHistory.create({
      data: { bookingId: row.id, toStatus: input.status, actorId: admin.id, reason: 'seed' },
    });
    if (input.status === BookingStatus.CONFIRMED || input.status === BookingStatus.PAID) {
      const payment = await prisma.payment.create({
        data: {
          bookingId: row.id,
          userId: input.customerId,
          kind: PaymentKind.DEPOSIT,
          status: PaymentStatus.SUCCEEDED,
          amount: deposit || input.amount,
          currency: desk.currency,
          providerRef: `pay_${number}`,
        },
      });
      await prisma.invoice.create({
        data: {
          invoiceNumber: `INV-${number}`,
          bookingId: row.id,
          paymentId: payment.id,
          userId: input.customerId,
          status: InvoiceStatus.PAID,
          subtotalAmount: input.amount,
          vatRate: 5,
          vatAmount: Math.round(input.amount * 0.05),
          totalAmount: Math.round(input.amount * 1.05),
          currency: desk.currency,
          lines: [{ description: number, amount: input.amount }],
        },
      });
      await prisma.commission.create({
        data: {
          bookingId: row.id,
          vendorId: input.vendorId,
          country: desk.code,
          rate: split.vendorRate,
          amount: split.amount,
          hqRate: split.hqShareRate,
          hqAmount: split.hqAmount,
          deskAmount: split.deskAmount,
          currency: desk.currency,
          status: CommissionStatus.ACCRUED,
        },
      });
    }
    return row;
  }

  const venueBook = await booking({
    type: BookingType.VENUE,
    status: BookingStatus.CONFIRMED,
    customerId: c1.id,
    vendorId: venuesPartner.vendor.id,
    eventId: weddingEvent.id,
    venueId: venues[0].venue.id,
    venuePackageId: venues[0].pkg.id,
    amount: venues[0].item.price,
    vendorRate: 12,
    startOffset: 42,
    guests: 180,
  });
  await booking({
    type: BookingType.LISTING,
    status: BookingStatus.PENDING,
    customerId: c1.id,
    vendorId: studioPartner.vendor.id,
    eventId: weddingEvent.id,
    listingId: listings[0]?.listing.id,
    listingPackageId: listings[0]?.pkg.id,
    amount: desk.studioVendor.listings[0].price,
    vendorRate: 10,
    startOffset: 42,
    guests: 180,
  });
  await booking({
    type: BookingType.LISTING,
    status: BookingStatus.CONFIRMED,
    customerId: c2.id,
    vendorId: studioPartner.vendor.id,
    eventId: secondEvent.id,
    listingId: listings[1]?.listing.id ?? listings[0]?.listing.id,
    listingPackageId: listings[1]?.pkg.id ?? listings[0]?.pkg.id,
    amount: desk.studioVendor.listings[1]?.price ?? desk.studioVendor.listings[0].price,
    vendorRate: 10,
    startOffset: 28,
    guests: 80,
  });
  await booking({
    type: BookingType.CAR,
    status: BookingStatus.INQUIRY,
    customerId: c2.id,
    vendorId: travelPartner.vendor.id,
    eventId: secondEvent.id,
    carId: cars[0]?.id,
    amount: desk.travelVendor.cars[0].rate,
    vendorRate: 12,
    startOffset: 28,
    guests: 4,
  });
  await booking({
    type: BookingType.ACCOMMODATION,
    status: BookingStatus.CONFIRMED,
    customerId: c3.id,
    vendorId: travelPartner.vendor.id,
    eventId: thirdEvent.id,
    accommodationId: stay.id,
    amount: staySpec.rate,
    vendorRate: 12,
    startOffset: 21,
    guests: 2,
  });
  await booking({
    type: BookingType.HONEYMOON,
    status: BookingStatus.PENDING,
    customerId: c3.id,
    vendorId: travelPartner.vendor.id,
    eventId: thirdEvent.id,
    honeymoonId: honeymoon.id,
    amount: tripSpec.price,
    vendorRate: 12,
    startOffset: 50,
    guests: 2,
  });

  await prisma.payout.create({
    data: {
      vendorId: venuesPartner.vendor.id,
      amount: Math.round(venues[0].item.price * 0.88),
      currency: desk.currency,
      status: PayoutStatus.PAID,
      processedAt: new Date(),
    },
  });

  await prisma.venueVisit.create({
    data: {
      customerId: c1.id,
      venueId: venues[0].venue.id,
      eventId: weddingEvent.id,
      scheduledAt: days(7),
      notes: loc('Prefer late afternoon light for photos.', 'يفضّل ضوء العصر للصور.'),
    },
  });

  await prisma.favorite.create({
    data: {
      userId: c1.id,
      resourceType: FavoriteResourceType.VENUE,
      resourceId: venues[0].venue.id,
    },
  });

  const vendorChat = await prisma.conversation.create({
    data: {
      type: ConversationType.CUSTOMER_VENDOR,
      participantAId: c1.id,
      participantBId: venuesPartner.user.id,
      bookingId: venueBook.id,
      lastMessageAt: new Date(),
    },
  });
  await prisma.message.create({
    data: {
      conversationId: vendorChat.id,
      senderId: venuesPartner.user.id,
      body: `Welcome to ${desk.venueVendor.businessEn}. We held the hall for your viewing this week.`,
    },
  });
  const support = await prisma.conversation.create({
    data: {
      type: ConversationType.CUSTOMER_ADMIN,
      participantAId: c2.id,
      participantBId: admin.id,
      lastMessageAt: new Date(),
    },
  });
  await prisma.message.create({
    data: {
      conversationId: support.id,
      senderId: c2.id,
      body: `Hello, can the ${desk.countryEn} desk confirm photographer availability for next month?`,
    },
  });
  await prisma.message.create({
    data: {
      conversationId: support.id,
      senderId: admin.id,
      body: 'Yes — the studio is available. I will send the package options today.',
    },
  });

  await prisma.crmNote.create({
    data: {
      authorId: admin.id,
      subjectType: CrmSubjectType.USER,
      subjectId: c1.id,
      body: `${c1.firstName} is planning a 180-guest wedding. Hall is confirmed; photography still pending.`,
    },
  });
  await prisma.crmInteraction.create({
    data: {
      actorId: admin.id,
      subjectType: CrmSubjectType.VENDOR,
      subjectId: venuesPartner.vendor.id,
      type: CrmInteractionType.CALL,
      summary: `Walked through weekend availability for ${desk.countryEn} desk.`,
    },
  });

  return { admin, customers, vendors: [venuesPartner, studioPartner, travelPartner] };
}

async function main(): Promise<void> {
  const rounds = Number.parseInt(process.env.BCRYPT_ROUNDS ?? '12', 10);
  const demoHash = await bcrypt.hash(DEMO_PASSWORD, rounds);
  const superHash = await bcrypt.hash(SUPER_PASSWORD, rounds);

  await wipeOperationalData();

  for (const [index, category] of EVENT_CATEGORIES.entries()) {
    await prisma.eventCategory.upsert({
      where: { slug: category.slug },
      update: { name: category.name, description: category.description, icon: category.icon, sortOrder: index, deletedAt: null, isActive: true },
      create: { ...category, sortOrder: index },
    });
  }
  const serviceIds: Record<string, string> = {};
  for (const [index, category] of SERVICE_CATEGORIES.entries()) {
    const row = await prisma.serviceCategory.upsert({
      where: { slug: category.slug },
      update: { name: category.name, description: category.description, icon: category.icon, sortOrder: index, deletedAt: null, isActive: true },
      create: { ...category, sortOrder: index },
    });
    serviceIds[category.slug] = row.id;
  }

  const wedding = await prisma.eventCategory.findUniqueOrThrow({ where: { slug: 'wedding' } });
  const engagement = await prisma.eventCategory.findUniqueOrThrow({ where: { slug: 'engagement' } });
  const birthday = await prisma.eventCategory.findUniqueOrThrow({ where: { slug: 'birthday' } });
  const corporate = await prisma.eventCategory.findUniqueOrThrow({ where: { slug: 'corporate' } });
  const family = await prisma.eventCategory.findUniqueOrThrow({ where: { slug: 'family' } });

  await prisma.user.create({
    data: {
      email: SUPER_EMAIL,
      passwordHash: superHash,
      role: Role.ADMIN,
      status: UserStatus.ACTIVE,
      isSuperAdmin: true,
      firstName: 'Zaya',
      lastName: 'Admin',
      displayName: 'Zaya Admin',
      locale: 'en',
      emailVerifiedAt: new Date(),
    },
  });

  await prisma.banner.createMany({
    data: [
      {
        title: loc('Plan every celebration with Zaya', 'خطط لكل مناسبة معزايا'),
        subtitle: loc('Venues, vendors, cars, stays, and honeymoons — one desk per country.', 'قاعات وموردون وسيارات وإقامة وشهر عسل — مكتب لكل دولة.'),
        imageKey: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1800&q=80',
        linkUrl: '/discover',
        placement: BannerPlacement.HOME_HERO,
        sortOrder: 0,
        isActive: true,
      },
      {
        title: loc('Country desks for UAE, Saudi, and Pakistan', 'مكاتب دول الإمارات والسعودية وباكستان'),
        subtitle: loc('Each desk runs its own customers, vendors, and currency.', 'كل مكتب يدير عملاءه ومورديه وعملته.'),
        imageKey: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1800&q=80',
        linkUrl: '/customer/venues',
        placement: BannerPlacement.DISCOVERY,
        sortOrder: 1,
        isActive: true,
      },
    ],
  });

  const settings: Array<{ key: string; group: string; value: unknown }> = [
    { key: 'platform.name', group: 'general', value: loc('Zaya Events', 'زايا إيفنتس') },
    { key: 'platform.defaultCurrency', group: 'payments', value: 'AED' },
    { key: 'general.currency', group: 'general', value: 'AED' },
    { key: 'general.siteName', group: 'general', value: 'Zaya Events' },
    { key: 'platform.supportedLocales', group: 'i18n', value: ['en', 'ar'] },
    { key: 'bookings.inquiryTtlHours', group: 'bookings', value: 72 },
    { key: 'commission.defaultRate', group: 'payments', value: 12 },
    { key: 'calls.tokenTtlSeconds', group: 'agora', value: 3600 },
  ];
  for (const setting of settings) {
    await prisma.setting.upsert({
      where: { key: setting.key },
      update: { value: setting.value as object },
      create: { key: setting.key, group: setting.group, value: setting.value as object },
    });
  }

  const seq = { n: 0 };
  const cats = {
    wedding: wedding.id,
    engagement: engagement.id,
    birthday: birthday.id,
    corporate: corporate.id,
    family: family.id,
  };
  for (const desk of DESKS) {
    await prisma.countryCommissionPolicy.upsert({
      where: { country: desk.code },
      update: { hqShareRate: 30, defaultVendorRate: 12 },
      create: { country: desk.code, hqShareRate: 30, defaultVendorRate: 12 },
    });
    await seedDesk(desk, demoHash, cats, serviceIds, seq);
  }

  // eslint-disable-next-line no-console
  console.log(`
Presentation seed ready. Old dummy records were removed.

Super admin (full platform)
  ${SUPER_EMAIL}
  ${SUPER_PASSWORD}

Shared password for every country admin, customer, and vendor:
  ${DEMO_PASSWORD}

UAE desk — Aisha Al Mansoori
  Admin     uae.admin@zayaevents.com
  Customers amira.uae@zayaevents.com | karim.uae@zayaevents.com | lina.uae@zayaevents.com
  Vendors   venues.uae@zayaevents.com | studio.uae@zayaevents.com | travel.uae@zayaevents.com
  Currency  AED

Saudi desk — Fahad Al Qahtani
  Admin     ksa.admin@zayaevents.com
  Customers hanan.ksa@zayaevents.com | yusuf.ksa@zayaevents.com | maryam.ksa@zayaevents.com
  Vendors   venues.ksa@zayaevents.com | studio.ksa@zayaevents.com | travel.ksa@zayaevents.com
  Currency  SAR

Pakistan desk — Sana Malik
  Admin     pk.admin@zayaevents.com
  Customers ayesha.pk@zayaevents.com | bilal.pk@zayaevents.com | fatima.pk@zayaevents.com
  Vendors   venues.pk@zayaevents.com | studio.pk@zayaevents.com | travel.pk@zayaevents.com
  Currency  PKR
`);
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
