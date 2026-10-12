import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import type { StorageProvider, StoredObject, UploadParams } from '../storage.interface.js';
import { buildObjectKey, joinUrl } from '../key.js';

type CustomUploadResponse = {
  key?: string;
  url?: string;
};

export class CustomStorageDriver implements StorageProvider {
  async upload(params: UploadParams): Promise<StoredObject> {
    if (!env.CUSTOM_STORAGE_UPLOAD_URL) {
      throw new AppError(500, 'STORAGE_MISCONFIGURED', 'Custom storage upload URL is not configured');
    }
    const key = buildObjectKey(params.filename, params.folder);
    const response = await fetch(env.CUSTOM_STORAGE_UPLOAD_URL, {
      method: 'POST',
      headers: {
        'content-type': 'application/octet-stream',
        'x-api-key': env.CUSTOM_STORAGE_API_KEY,
        'x-file-key': key,
        'x-file-name': params.filename,
        'x-content-type': params.contentType,
      },
      body: params.buffer,
    });
    if (!response.ok) {
      throw new AppError(502, 'STORAGE_UPSTREAM_ERROR', `Custom storage upload failed (${response.status})`);
    }
    let payload: CustomUploadResponse = {};
    const text = await response.text();
    if (text.length > 0) {
      payload = JSON.parse(text) as CustomUploadResponse;
    }
    const storedKey = payload.key ?? key;
    return {
      key: storedKey,
      url: payload.url ?? this.getUrl(storedKey),
      contentType: params.contentType,
      size: params.buffer.byteLength,
    };
  }

  async delete(key: string): Promise<void> {
    if (!env.CUSTOM_STORAGE_DELETE_URL) {
      throw new AppError(500, 'STORAGE_MISCONFIGURED', 'Custom storage delete URL is not configured');
    }
    const url = `${env.CUSTOM_STORAGE_DELETE_URL.replace(/\/+$/, '')}/${encodeURIComponent(key)}`;
    const response = await fetch(url, {
      method: 'DELETE',
      headers: { 'x-api-key': env.CUSTOM_STORAGE_API_KEY },
    });
    if (!response.ok && response.status !== 404) {
      throw new AppError(502, 'STORAGE_UPSTREAM_ERROR', `Custom storage delete failed (${response.status})`);
    }
  }

  getUrl(key: string): string {
    return joinUrl(`${env.STORAGE_PUBLIC_URL}/uploads`, key);
  }
}
