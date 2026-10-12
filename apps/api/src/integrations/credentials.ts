import { AppError } from '../lib/errors.js';

export function missingCredentials(provider: string, keys: string[]): never {
  throw new AppError(
    500,
    `${provider.toUpperCase()}_MISCONFIGURED`,
    `Real ${provider} provider is selected but credentials are missing. Set ${keys.join(', ')} in .env, or switch the provider back to mock.`,
  );
}

export function notWired(provider: string, operation: string, hint: string): never {
  throw new AppError(
    501,
    `${provider.toUpperCase()}_NOT_WIRED`,
    `TODO: ${operation}. Credentials are present. ${hint}`,
  );
}
