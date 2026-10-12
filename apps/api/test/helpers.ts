export function uniqueEmail(prefix: string): string {
  return `${prefix}.${Date.now()}.${Math.floor(Math.random() * 10_000)}@test.zaya.local`;
}

export function accessToken(res: { body: { data?: { tokens?: { accessToken?: string } } } }): string {
  const token = res.body.data?.tokens?.accessToken;
  if (!token) {
    throw new Error('Expected tokens.accessToken in response');
  }
  return token;
}
