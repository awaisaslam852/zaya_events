import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

const apiRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = resolve(apiRoot, '../..');

for (const file of [resolve(repoRoot, '.env'), resolve(apiRoot, '.env')]) {
  if (existsSync(file)) {
    dotenv.config({ path: file });
  }
}

if (!process.env.DATABASE_URL) {
  console.error(
    'DATABASE_URL is missing. From the repo root run: cp .env.example .env\nPrisma looks at the root .env (not apps/api/.env).',
  );
  process.exit(1);
}

const prismaCli = resolve(apiRoot, 'node_modules/prisma/build/index.js');
const child = spawn(process.execPath, [prismaCli, ...process.argv.slice(2)], {
  cwd: apiRoot,
  env: process.env,
  stdio: 'inherit',
});
child.on('exit', (code, signal) => {
  if (signal) {
    process.exit(1);
  }
  process.exit(code ?? 1);
});
