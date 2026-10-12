import { readFile, unlink } from 'node:fs/promises';
import path from 'node:path';
import { env } from '../src/config/env.js';
import { LocalStorageDriver } from '../src/storage/drivers/local.driver.js';

describe('local storage adapter', () => {
  it('writes bytes and returns a public /uploads URL', async () => {
    const driver = new LocalStorageDriver();
    const stored = await driver.upload({
      buffer: Buffer.from('hello-zaya'),
      filename: 'note.txt',
      contentType: 'text/plain',
      folder: 'tests',
    });
    expect(stored.key).toContain('tests/');
    expect(stored.url).toContain('/uploads/');
    expect(stored.size).toBe(10);
    const disk = await readFile(path.join(path.resolve(env.STORAGE_LOCAL_DIR), stored.key), 'utf8');
    expect(disk).toBe('hello-zaya');
    await driver.delete(stored.key);
    await unlink(path.join(path.resolve(env.STORAGE_LOCAL_DIR), stored.key)).catch(() => undefined);
  });
});
