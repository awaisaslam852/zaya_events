import type { NextFunction, Request, Response } from 'express';
import { sendSuccess } from '../../lib/http.js';
import { UnauthorizedError } from '../../lib/errors.js';
import { authService } from './auth.service.js';
import type {
  ForgotPasswordInput,
  LoginInput,
  LogoutInput,
  ProfilePatchInput,
  RefreshInput,
  RegisterInput,
  ResetPasswordInput,
} from './auth.schema.js';

function requestMeta(req: Request): { userAgent?: string; ipAddress?: string } {
  return {
    userAgent: req.header('user-agent') ?? undefined,
    ipAddress: req.ip,
  };
}

export const authController = {
  async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await authService.register(req.body as RegisterInput, requestMeta(req));
      sendSuccess(res, result, 201);
    } catch (error) {
      next(error);
    }
  },

  async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await authService.login(req.body as LoginInput, requestMeta(req));
      sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  },

  async refresh(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const body = req.body as RefreshInput;
      const result = await authService.refresh(body.refreshToken, requestMeta(req));
      sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  },

  async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new UnauthorizedError();
      }
      const body = req.body as LogoutInput;
      await authService.logout(req.user.id, body.refreshToken);
      sendSuccess(res, { loggedOut: true });
    } catch (error) {
      next(error);
    }
  },

  async forgotPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      await authService.forgotPassword(req.body as ForgotPasswordInput);
      sendSuccess(res, { requested: true });
    } catch (error) {
      next(error);
    }
  },

  async resetPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      await authService.resetPassword(req.body as ResetPasswordInput);
      sendSuccess(res, { reset: true });
    } catch (error) {
      next(error);
    }
  },

  async me(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new UnauthorizedError();
      }
      const user = await authService.me(req.user.id);
      sendSuccess(res, { user });
    } catch (error) {
      next(error);
    }
  },

  async updateMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        throw new UnauthorizedError();
      }
      const user = await authService.updateProfile(req.user.id, req.body as ProfilePatchInput);
      sendSuccess(res, { user });
    } catch (error) {
      next(error);
    }
  },
};
