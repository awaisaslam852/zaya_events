import { generateRtcToken } from '../src/modules/agora/agora.service.js';

describe('call token issuance', () => {
  it('issues publisher and subscriber tokens for booking and call channels', () => {
    const pub = generateRtcToken('booking_11111111-1111-4111-8111-111111111111', 42, 'PUBLISHER', 120);
    expect(pub.token.length).toBeGreaterThan(20);
    expect(pub.appId).toHaveLength(32);
    expect(pub.role).toBe('PUBLISHER');
    expect(pub.uid).toBe(42);

    const sub = generateRtcToken('call_aaa_bbb', 7, 'SUBSCRIBER', 120);
    expect(sub.token).not.toEqual(pub.token);
    expect(sub.role).toBe('SUBSCRIBER');
  });

  it('rejects channels outside booking_ / call_ prefixes', () => {
    expect(() => generateRtcToken('random-room', 1, 'PUBLISHER')).toThrow(/INVALID_CHANNEL|Channel must/);
  });
});
