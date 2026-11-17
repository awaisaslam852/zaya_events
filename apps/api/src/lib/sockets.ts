import type { Namespace, Server } from 'socket.io';
import { logger } from './logger.js';

let ioRef: Server | undefined;

export function setSocketServer(io: Server): void {
  ioRef = io;
}

export function getSocketServer(): Server | undefined {
  return ioRef;
}

export function getChatNamespace(): Namespace | undefined {
  return ioRef?.of('/chat');
}

export function getCallsNamespace(): Namespace | undefined {
  return ioRef?.of('/calls');
}

export function emitToUser(namespace: '/chat' | '/calls', userId: string, event: string, payload: unknown): void {
  const nsp = namespace === '/chat' ? getChatNamespace() : getCallsNamespace();
  if (!nsp) {
    logger.warn({ namespace, userId, event }, 'socket emit skipped (io not ready)');
    return;
  }
  const room = `user:${userId}`;
  const listeners = nsp.adapter.rooms.get(room)?.size ?? 0;
  if (listeners === 0) {
    logger.warn({ namespace, userId, event }, 'socket emit with no connected listener');
  } else {
    logger.info({ namespace, userId, event, listeners }, 'socket emit');
  }
  nsp.to(room).emit(event, payload);
}
