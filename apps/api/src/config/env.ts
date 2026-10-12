import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { z } from 'zod';
import dotenv from 'dotenv';

const envCandidates = [
  resolve(process.cwd(), '../../.env'),
  resolve(process.cwd(), '.env'),
  resolve(process.cwd(), '../.env'),
];
for (const candidate of envCandidates) {
  if (existsSync(candidate)) {
    dotenv.config({ path: candidate });
  }
}
dotenv.config();

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(4000),
  API_URL: z.string().url().default('http://localhost:4000'),
  ADMIN_WEB_URL: z.string().url().default('http://localhost:5173'),
  VENDOR_WEB_URL: z.string().url().default('http://localhost:5174'),
  CUSTOMER_APP_DEEP_LINK: z.string().default('zaya://reset-password'),
  CORS_ORIGINS: z
    .string()
    .default(
      'http://localhost:5173,http://localhost:5174,http://localhost:8080,http://127.0.0.1:8080',
    ),
  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().min(1),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('30d'),
  BCRYPT_ROUNDS: z.coerce.number().int().min(10).max(15).default(12),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(60_000),
  RATE_LIMIT_MAX: z.coerce.number().int().positive().default(120),
  STORAGE_DRIVER: z.enum(['local', 'sftp', 'ftp', 'spaces', 'custom']).default('local'),
  STORAGE_PUBLIC_URL: z.string().default('http://localhost:4000'),
  STORAGE_LOCAL_DIR: z.string().default('./uploads'),
  SFTP_HOST: z.string().optional().default(''),
  SFTP_PORT: z.coerce.number().int().default(22),
  SFTP_USER: z.string().optional().default(''),
  SFTP_PASSWORD: z.string().optional().default(''),
  SFTP_BASE_PATH: z.string().default('/uploads'),
  FTP_HOST: z.string().optional().default(''),
  FTP_PORT: z.coerce.number().int().default(21),
  FTP_USER: z.string().optional().default(''),
  FTP_PASSWORD: z.string().optional().default(''),
  FTP_SECURE: z
    .string()
    .optional()
    .default('false')
    .transform((value) => value === 'true'),
  FTP_BASE_PATH: z.string().default('/uploads'),
  SPACES_ENDPOINT: z.string().optional().default(''),
  SPACES_PORT: z.coerce.number().int().default(443),
  SPACES_USE_SSL: z
    .string()
    .optional()
    .default('true')
    .transform((value) => value !== 'false'),
  SPACES_BUCKET: z.string().optional().default(''),
  SPACES_ACCESS_KEY: z.string().optional().default(''),
  SPACES_SECRET_KEY: z.string().optional().default(''),
  SPACES_REGION: z.string().default('us-east-1'),
  SPACES_PUBLIC_URL: z.string().optional().default(''),
  CUSTOM_STORAGE_UPLOAD_URL: z.string().optional().default(''),
  CUSTOM_STORAGE_DELETE_URL: z.string().optional().default(''),
  CUSTOM_STORAGE_API_KEY: z.string().optional().default(''),
  AGORA_APP_ID: z.string().optional().default(''),
  AGORA_APP_CERTIFICATE: z.string().optional().default(''),
  AGORA_TOKEN_EXPIRES_IN: z.coerce.number().int().positive().default(3600),
  SMTP_HOST: z.string().default('localhost'),
  SMTP_PORT: z.coerce.number().int().default(1025),
  SMTP_SECURE: z
    .string()
    .optional()
    .default('false')
    .transform((value) => value === 'true'),
  SMTP_USER: z.string().optional().default(''),
  SMTP_PASS: z.string().optional().default(''),
  SMTP_FROM: z.string().default('Zaya Events <noreply@zayaevents.local>'),
  STRIPE_SECRET_KEY: z.string().optional().default(''),
  STRIPE_WEBHOOK_SECRET: z.string().optional().default(''),
  VAT_RATE: z.coerce.number().min(0).max(100).default(5),
  WHATSAPP_NOTIFY_ENABLED: z
    .string()
    .optional()
    .default('true')
    .transform((value) => value !== 'false'),
  FCM_PROJECT_ID: z.string().optional().default(''),
  FCM_CLIENT_EMAIL: z.string().optional().default(''),
  FCM_PRIVATE_KEY: z.string().optional().default(''),
  WHATSAPP_TOKEN: z.string().optional().default(''),
  WHATSAPP_PHONE_NUMBER_ID: z.string().optional().default(''),
  WHATSAPP_API_VERSION: z.string().optional().default('v21.0'),
  CALLS_WHATSAPP_ENABLED: z
    .string()
    .optional()
    .default('false')
    .transform((value) => value === 'true'),
  OPENAI_API_KEY: z.string().optional().default(''),
  OPENAI_MODEL: z.string().optional().default('gpt-4o-mini'),
  GOOGLE_MAPS_API_KEY: z.string().optional().default(''),
  STRIPE_PUBLISHABLE_KEY: z.string().optional().default(''),
  FLIGHTS_PROVIDER: z.enum(['mock', 'amadeus']).default('mock'),
  HOTELS_PROVIDER: z.enum(['mock', 'bookingcom']).default('mock'),
  WHATSAPP_PROVIDER: z.enum(['mock', 'cloud']).default('mock'),
  OPENAI_PROVIDER: z.enum(['mock', 'openai']).default('mock'),
  MAPS_PROVIDER: z.enum(['mock', 'google']).default('mock'),
  AMADEUS_CLIENT_ID: z.string().optional().default(''),
  AMADEUS_CLIENT_SECRET: z.string().optional().default(''),
  AMADEUS_HOSTNAME: z.enum(['test', 'production']).default('test'),
  DUFFEL_ACCESS_TOKEN: z.string().optional().default(''),
  BOOKINGCOM_API_KEY: z.string().optional().default(''),
  BOOKINGCOM_AFFILIATE_ID: z.string().optional().default(''),
  EXPEDIA_API_KEY: z.string().optional().default(''),
  EXPEDIA_SHARED_SECRET: z.string().optional().default(''),
});

export type Env = z.infer<typeof envSchema>;

function loadEnv(): Env {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const details = parsed.error.flatten().fieldErrors;
    throw new Error(`Invalid environment: ${JSON.stringify(details)}`);
  }
  return parsed.data;
}

export const env = loadEnv();

export const corsOrigins = env.CORS_ORIGINS.split(',')
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);
