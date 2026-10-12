declare module 'agora-access-token' {
  export const RtcRole: {
    PUBLISHER: 1;
    SUBSCRIBER: 2;
  };

  export class RtcTokenBuilder {
    static buildTokenWithUid(
      appId: string,
      appCertificate: string,
      channelName: string,
      uid: number,
      role: 1 | 2,
      privilegeExpiredTs: number,
    ): string;
  }
}

export {};
