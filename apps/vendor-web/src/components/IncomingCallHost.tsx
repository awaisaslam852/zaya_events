import { useEffect, useMemo, useState } from 'react';
import AgoraRTC, {
  AgoraRTCProvider,
  LocalUser,
  RemoteUser,
  useJoin,
  useLocalCameraTrack,
  useLocalMicrophoneTrack,
  usePublish,
  useRemoteUsers,
} from 'agora-rtc-react';
import { io } from 'socket.io-client';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { getAccessToken } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

type Incoming = { callId: string; channelName: string; callerId: string };
type Rtc = { token: string; appId: string; channelName: string; uid: number };

export function IncomingCallHost() {
  const { t } = useTranslation();
  const [incoming, setIncoming] = useState<Incoming | null>(null);
  const [rtc, setRtc] = useState<Rtc | null>(null);
  const [activeCallId, setActiveCallId] = useState<string | null>(null);
  const [muted, setMuted] = useState(false);
  const [camOff, setCamOff] = useState(false);
  const apiUrl = import.meta.env.VITE_API_URL ?? 'http://localhost:4000';
  const socket = useMemo(
    () => io(`${apiUrl}/calls`, { auth: { token: getAccessToken() }, autoConnect: false }),
    [apiUrl],
  );

  useEffect(() => {
    socket.connect();
    socket.on('call:incoming', (payload: Incoming) => setIncoming(payload));
    socket.on('call:ended', () => {
      setIncoming(null);
      setRtc(null);
    });
    socket.on('call:rejected', () => setIncoming(null));
    socket.on('call:missed', () => setIncoming(null));
    return () => {
      socket.disconnect();
    };
  }, [socket]);

  async function accept(): Promise<void> {
    if (!incoming) {
      return;
    }
    try {
      await unwrap(api.post(`/api/v1/calls/${incoming.callId}/accept`));
      const token = await unwrap<Rtc>(api.get(`/api/v1/calls/${incoming.callId}/token`));
      setActiveCallId(incoming.callId);
      setRtc(token);
      setIncoming(null);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : t('common.error'));
    }
  }

  async function reject(): Promise<void> {
    if (!incoming) {
      return;
    }
    try {
      await unwrap(api.post(`/api/v1/calls/${incoming.callId}/reject`));
      setIncoming(null);
    } catch (e) {
      toast.error(e instanceof Error ? e.message : t('common.error'));
    }
  }

  async function end(): Promise<void> {
    if (activeCallId) {
      await unwrap(api.post(`/api/v1/calls/${activeCallId}/end`)).catch(() => undefined);
    }
    setActiveCallId(null);
    setRtc(null);
  }

  if (!incoming && !rtc) {
    return null;
  }

  return (
    <div className="fixed inset-x-0 top-3 z-50 mx-auto max-w-lg rounded-lg border bg-background p-4 shadow-lg">
      {incoming && !rtc ? (
        <div className="flex items-center justify-between gap-2">
          <p className="font-medium">{t('calls.incoming')}</p>
          <div className="flex gap-2">
            <Button size="sm" onClick={() => void accept()}>
              {t('calls.accept')}
            </Button>
            <Button size="sm" variant="destructive" onClick={() => void reject()}>
              {t('calls.reject')}
            </Button>
          </div>
        </div>
      ) : null}
      {rtc ? (
        <InCall rtc={rtc} muted={muted} camOff={camOff} onMute={() => setMuted((v) => !v)} onCam={() => setCamOff((v) => !v)} onEnd={() => void end()} />
      ) : null}
    </div>
  );
}

function InCall({
  rtc,
  muted,
  camOff,
  onMute,
  onCam,
  onEnd,
}: {
  rtc: Rtc;
  muted: boolean;
  camOff: boolean;
  onMute: () => void;
  onCam: () => void;
  onEnd: () => void;
}) {
  const { t } = useTranslation();
  const client = useMemo(() => AgoraRTC.createClient({ mode: 'rtc', codec: 'vp8' }), []);
  return (
    <AgoraRTCProvider client={client}>
      <CallTracks rtc={rtc} muted={muted} camOff={camOff} />
      <div className="mt-2 flex gap-2">
        <Button size="sm" variant="outline" onClick={onMute}>
          {t('calls.mute')}
        </Button>
        <Button size="sm" variant="outline" onClick={onCam}>
          {t('calls.camera')}
        </Button>
        <Button size="sm" variant="destructive" onClick={onEnd}>
          {t('calls.end')}
        </Button>
      </div>
    </AgoraRTCProvider>
  );
}

function CallTracks({ rtc, muted, camOff }: { rtc: Rtc; muted: boolean; camOff: boolean }) {
  const { t } = useTranslation();
  useJoin({ appid: rtc.appId, channel: rtc.channelName, token: rtc.token, uid: rtc.uid }, true);
  const { localMicrophoneTrack } = useLocalMicrophoneTrack(!muted);
  const { localCameraTrack } = useLocalCameraTrack(!camOff);
  usePublish([localMicrophoneTrack, localCameraTrack]);
  const remotes = useRemoteUsers();
  return (
    <div>
      <p className="mb-2 text-sm">{t('calls.inCall')}</p>
      <div className="grid grid-cols-2 gap-2">
        <div className="h-40 overflow-hidden rounded bg-black">
          <LocalUser audioTrack={localMicrophoneTrack} cameraOn={!camOff} micOn={!muted} videoTrack={localCameraTrack} />
        </div>
        {remotes.map((user) => (
          <div key={String(user.uid)} className="h-40 overflow-hidden rounded bg-black">
            <RemoteUser user={user} playVideo playAudio />
          </div>
        ))}
      </div>
    </div>
  );
}
