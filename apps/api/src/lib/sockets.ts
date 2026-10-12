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
    logger.debug({ namespace, userId, event }, 'socket emit skipped (io not ready)');
    return;
  }
  nsp.to(`user:${userId}`).emit(event, payload);
}
