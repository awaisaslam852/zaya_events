const { tmpdir } = require('node:os');
const { join } = require('node:path');

process.env.NODE_ENV = 'test';
process.env.BCRYPT_ROUNDS = process.env.BCRYPT_ROUNDS || '10';
process.env.JWT_ACCESS_SECRET =
  process.env.JWT_ACCESS_SECRET && process.env.JWT_ACCESS_SECRET.length >= 32
    ? process.env.JWT_ACCESS_SECRET
    : 'test_access_secret_min_32_chars_xx';
process.env.JWT_REFRESH_SECRET =
  process.env.JWT_REFRESH_SECRET && process.env.JWT_REFRESH_SECRET.length >= 32
    ? process.env.JWT_REFRESH_SECRET
    : 'test_refresh_secret_min_32_chars_x';
process.env.DATABASE_URL =
  process.env.DATABASE_URL ||
  'postgresql://zaya:zaya_dev_password@localhost:5432/zaya_events?schema=public';
process.env.REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';
process.env.AGORA_APP_ID = process.env.AGORA_APP_ID || '0'.repeat(32);
process.env.AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || 'a'.repeat(32);
process.env.STORAGE_DRIVER = 'local';
process.env.STORAGE_PUBLIC_URL = process.env.STORAGE_PUBLIC_URL || 'http://localhost:4000';
process.env.STORAGE_LOCAL_DIR = process.env.STORAGE_LOCAL_DIR || join(tmpdir(), 'zaya-api-test-uploads');
process.env.FLIGHTS_PROVIDER = process.env.FLIGHTS_PROVIDER || 'mock';
process.env.HOTELS_PROVIDER = process.env.HOTELS_PROVIDER || 'mock';
process.env.WHATSAPP_PROVIDER = process.env.WHATSAPP_PROVIDER || 'mock';
process.env.OPENAI_PROVIDER = process.env.OPENAI_PROVIDER || 'mock';
process.env.MAPS_PROVIDER = process.env.MAPS_PROVIDER || 'mock';
