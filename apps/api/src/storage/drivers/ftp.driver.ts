import { Readable } from 'node:stream';
import { Client } from 'basic-ftp';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import type { StorageProvider, StoredObject, UploadParams } from '../storage.interface.js';
import { buildObjectKey, joinUrl } from '../key.js';

export class FtpStorageDriver implements StorageProvider {
  private async withClient<T>(fn: (client: Client) => Promise<T>): Promise<T> {
    if (!env.FTP_HOST || !env.FTP_USER) {
      throw new AppError(500, 'STORAGE_MISCONFIGURED', 'FTP storage is not configured');
    }
    const client = new Client();
    await client.access({
      host: env.FTP_HOST,
      port: env.FTP_PORT,
      user: env.FTP_USER,
      password: env.FTP_PASSWORD,
      secure: env.FTP_SECURE,
    });
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }

  async upload(params: UploadParams): Promise<StoredObject> {
    const key = buildObjectKey(params.filename, params.folder);
    const remotePath = `${env.FTP_BASE_PATH.replace(/\/+$/, '')}/${key}`;
    await this.withClient(async (client) => {
      const dir = remotePath.slice(0, remotePath.lastIndexOf('/'));
      await client.ensureDir(dir);
      await client.uploadFrom(Readable.from(params.buffer), remotePath);
    });
    return {
      key,
      url: this.getUrl(key),
      contentType: params.contentType,
      size: params.buffer.byteLength,
    };
  }

  async delete(key: string): Promise<void> {
    const remotePath = `${env.FTP_BASE_PATH.replace(/\/+$/, '')}/${key}`;
    await this.withClient(async (client) => {
      await client.remove(remotePath).catch(() => undefined);
    });
  }

  getUrl(key: string): string {
    return joinUrl(`${env.STORAGE_PUBLIC_URL}/uploads`, key);
  }
}
