import path from 'node:path';
import { fileURLToPath } from 'node:url';
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';
import type { Express } from 'express';
import { env } from '../config/env.js';

const here = path.dirname(fileURLToPath(import.meta.url));

const spec = swaggerJsdoc({
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'Zaya Events API',
      version: '0.1.0',
      description: 'Event planning, discovery, inquiry, booking, travel, and management API',
    },
    servers: [{ url: env.API_URL }],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
    },
  },
  apis: [
    path.join(here, '../modules/**/*.ts'),
    path.join(here, '../modules/**/*.js'),
  ],
});

export function mountSwagger(app: Express): void {
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(spec, { explorer: true }));
}
