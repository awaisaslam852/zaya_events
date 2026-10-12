import { mkdir, unlink, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { env } from '../../config/env.js';
import type { StorageProvider, StoredObject, UploadParams } from '../storage.interface.js';
import { buildObjectKey, joinUrl } from '../key.js';

export class LocalStorageDriver implements StorageProvider {
  private readonly root: string;

  constructor() {
    this.root = path.resolve(env.STORAGE_LOCAL_DIR);
  }

  async upload(params: UploadParams): Promise<StoredObject> {
    const key = buildObjectKey(params.filename, params.folder);
    const filePath = path.join(this.root, key);
    await mkdir(path.dirname(filePath), { recursive: true });
    await writeFile(filePath, params.buffer);
    return {
      key,
      url: this.getUrl(key),
      contentType: params.contentType,
      size: params.buffer.byteLength,
    };
  }

  async delete(key: string): Promise<void> {
    const filePath = path.join(this.root, key);
    await unlink(filePath).catch((error: NodeJS.ErrnoException) => {
      if (error.code !== 'ENOENT') {
        throw error;
      }
    });
  }

  getUrl(key: string): string {
    return joinUrl(`${env.STORAGE_PUBLIC_URL}/uploads`, key);
  }
}
