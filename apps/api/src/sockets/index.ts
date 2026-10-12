import type { Server as HttpServer } from 'node:http';
import { Server } from 'socket.io';
import { corsOptions } from '../lib/cors.js';
import { logger } from '../lib/logger.js';
import { setSocketServer } from '../lib/sockets.js';
import { verifyAccessToken } from '../modules/auth/auth.tokens.js';

export function bootstrapSockets(httpServer: HttpServer): Server {
  const io = new Server(httpServer, {
    cors: corsOptions,
  });
  setSocketServer(io);

  const authenticate = (socket: { handshake: { auth: Record<string, unknown>; query: Record<string, unknown> } }, next: (err?: Error) => void) => {
    const token =
      (typeof socket.handshake.auth.token === 'string' ? socket.handshake.auth.token : undefined) ??
      (typeof socket.handshake.query.token === 'string' ? socket.handshake.query.token : undefined);
    if (!token) {
      next(new Error('UNAUTHORIZED'));
      return;
    }
    try {
      const payload = verifyAccessToken(token);
      (socket as unknown as { data: { userId: string } }).data = { userId: payload.sub };
      next();
    } catch {
      next(new Error('UNAUTHORIZED'));
    }
  };

  const chat = io.of('/chat');
  chat.use(authenticate as never);
  chat.on('connection', (socket) => {
    const userId = (socket.data as { userId: string }).userId;
    void socket.join(`user:${userId}`);
    logger.info({ socketId: socket.id, userId }, 'chat namespace connected');
    socket.emit('chat:ready', { namespace: '/chat' });
    socket.on('disconnect', (reason) => {
      logger.info({ socketId: socket.id, reason }, 'chat namespace disconnected');
    });
  });

  const calls = io.of('/calls');
  calls.use(authenticate as never);
  calls.on('connection', (socket) => {
    const userId = (socket.data as { userId: string }).userId;
    void socket.join(`user:${userId}`);
    logger.info({ socketId: socket.id, userId }, 'calls namespace connected');
    socket.emit('calls:ready', { namespace: '/calls' });
    socket.on('disconnect', (reason) => {
      logger.info({ socketId: socket.id, reason }, 'calls namespace disconnected');
    });
  });

  return io;
}
