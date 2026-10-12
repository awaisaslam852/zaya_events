import { randomUUID } from 'node:crypto';
import path from 'node:path';

export function buildObjectKey(filename: string, folder?: string): string {
  const safe = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
  const ext = path.extname(safe);
  const base = path.basename(safe, ext) || 'file';
  const name = `${Date.now()}-${randomUUID()}-${base}${ext.toLowerCase()}`;
  if (!folder) {
    return name;
  }
  return `${folder.replace(/^\/+|\/+$/g, '')}/${name}`;
}

export function joinUrl(base: string, key: string): string {
  return `${base.replace(/\/+$/, '')}/${key.replace(/^\/+/, '')}`;
}
