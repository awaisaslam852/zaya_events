import { buildFcmMessage } from '../src/integrations/fcm.js';

describe('incoming-call FCM payload', () => {
  it('sends Android a data-only high-priority call so a closed app can wake', () => {
    const { message } = buildFcmMessage({
      token: 'device-token',
      title: 'Incoming call',
      body: 'You have an incoming call on Zaya Events.',
      data: { type: 'incoming_call', callId: 'call-22', callerName: 'Layla' },
    });
    expect(message.notification).toBeUndefined();
    expect(message.android).toMatchObject({ priority: 'HIGH', ttl: '60s' });
    expect((message.android as { notification?: unknown }).notification).toBeUndefined();
    expect(message.data).toMatchObject({
      type: 'incoming_call',
      callId: 'call-22',
      callerName: 'Layla',
    });
    const aps = (message.apns as { payload: { aps: Record<string, unknown> } }).payload.aps;
    expect(aps['interruption-level']).toBe('time-sensitive');
    expect(aps.alert).toEqual({
      title: 'Incoming call',
      body: 'You have an incoming call on Zaya Events.',
    });
  });

  it('keeps a visible notification payload for non-call alerts', () => {
    const { message } = buildFcmMessage({
      token: 'device-token',
      title: 'Booking confirmed',
      body: 'Your booking is confirmed.',
      data: { type: 'booking', bookingId: 'booking-9' },
    });
    expect(message.notification).toEqual({
      title: 'Booking confirmed',
      body: 'Your booking is confirmed.',
    });
    expect((message.android as { notification: { channelId: string } }).notification.channelId).toBe('default');
  });
});
