import { env } from '../config/env.js';
import { CustomStorageDriver } from './drivers/custom.driver.js';
import { FtpStorageDriver } from './drivers/ftp.driver.js';
import { LocalStorageDriver } from './drivers/local.driver.js';
import { SftpStorageDriver } from './drivers/sftp.driver.js';
import { SpacesStorageDriver } from './drivers/spaces.driver.js';
import type { StorageProvider } from './storage.interface.js';

let cached: StorageProvider | undefined;

export function getStorageProvider(): StorageProvider {
  if (cached) {
    return cached;
  }
  switch (env.STORAGE_DRIVER) {
    case 'local':
      cached = new LocalStorageDriver();
      break;
    case 'sftp':
      cached = new SftpStorageDriver();
      break;
    case 'ftp':
      cached = new FtpStorageDriver();
      break;
    case 'spaces':
      cached = new SpacesStorageDriver();
      break;
    case 'custom':
      cached = new CustomStorageDriver();
      break;
    default: {
      const exhaustive: never = env.STORAGE_DRIVER;
      throw new Error(`Unsupported storage driver: ${String(exhaustive)}`);
    }
  }
  return cached;
}

export type { StorageProvider, StoredObject, UploadParams } from './storage.interface.js';
