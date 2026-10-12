import SftpClient from 'ssh2-sftp-client';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import type { StorageProvider, StoredObject, UploadParams } from '../storage.interface.js';
import { buildObjectKey, joinUrl } from '../key.js';

export class SftpStorageDriver implements StorageProvider {
  private async withClient<T>(fn: (client: SftpClient) => Promise<T>): Promise<T> {
    if (!env.SFTP_HOST || !env.SFTP_USER) {
      throw new AppError(500, 'STORAGE_MISCONFIGURED', 'SFTP storage is not configured');
    }
    const client = new SftpClient();
    await client.connect({
      host: env.SFTP_HOST,
      port: env.SFTP_PORT,
      username: env.SFTP_USER,
      password: env.SFTP_PASSWORD,
    });
    try {
      return await fn(client);
    } finally {
      await client.end();
    }
  }

  async upload(params: UploadParams): Promise<StoredObject> {
    const key = buildObjectKey(params.filename, params.folder);
    const remotePath = `${env.SFTP_BASE_PATH.replace(/\/+$/, '')}/${key}`;
    await this.withClient(async (client) => {
      const dir = remotePath.slice(0, remotePath.lastIndexOf('/'));
      await client.mkdir(dir, true);
      await client.put(params.buffer, remotePath);
    });
    return {
      key,
      url: this.getUrl(key),
      contentType: params.contentType,
      size: params.buffer.byteLength,
    };
  }

  async delete(key: string): Promise<void> {
    const remotePath = `${env.SFTP_BASE_PATH.replace(/\/+$/, '')}/${key}`;
    await this.withClient(async (client) => {
      await client.delete(remotePath).catch(() => undefined);
    });
  }

  getUrl(key: string): string {
    return joinUrl(`${env.STORAGE_PUBLIC_URL}/uploads`, key);
  }
}
