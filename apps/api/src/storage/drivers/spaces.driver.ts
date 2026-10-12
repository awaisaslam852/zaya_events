import { Client } from 'minio';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import type { StorageProvider, StoredObject, UploadParams } from '../storage.interface.js';
import { buildObjectKey, joinUrl } from '../key.js';

export class SpacesStorageDriver implements StorageProvider {
  private readonly client: Client;
  private readonly bucket: string;

  constructor() {
    if (!env.SPACES_ENDPOINT || !env.SPACES_BUCKET || !env.SPACES_ACCESS_KEY || !env.SPACES_SECRET_KEY) {
      throw new AppError(
        500,
        'STORAGE_MISCONFIGURED',
        'Spaces/MinIO storage requires endpoint, bucket, and credentials',
      );
    }
    this.bucket = env.SPACES_BUCKET;
    this.client = new Client({
      endPoint: env.SPACES_ENDPOINT.replace(/^https?:\/\//, ''),
      port: env.SPACES_PORT,
      useSSL: env.SPACES_USE_SSL,
      accessKey: env.SPACES_ACCESS_KEY,
      secretKey: env.SPACES_SECRET_KEY,
      region: env.SPACES_REGION,
    });
  }

  async upload(params: UploadParams): Promise<StoredObject> {
    const key = buildObjectKey(params.filename, params.folder);
    await this.client.putObject(this.bucket, key, params.buffer, params.buffer.byteLength, {
      'Content-Type': params.contentType,
    });
    return {
      key,
      url: this.getUrl(key),
      contentType: params.contentType,
      size: params.buffer.byteLength,
    };
  }

  async delete(key: string): Promise<void> {
    await this.client.removeObject(this.bucket, key);
  }

  getUrl(key: string): string {
    const publicBase = env.SPACES_PUBLIC_URL || env.STORAGE_PUBLIC_URL;
    return joinUrl(publicBase, key);
  }
}
