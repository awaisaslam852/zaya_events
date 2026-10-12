import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { mediaUrl } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent } from '@/components/ui/dialog';
import { toast } from 'sonner';

type Uploaded = { key: string; url: string };

async function uploadFile(folder: string, file: File): Promise<Uploaded> {
  const form = new FormData();
  form.append('file', file);
  form.append('folder', folder);
  return unwrap<Uploaded>(api.post('/api/v1/uploads', form));
}

export function FileUpload({
  label,
  folder,
  onUploaded,
}: {
  label: string;
  folder: string;
  onUploaded: (file: Uploaded) => void;
}) {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);

  async function onChange(fileList: FileList | null): Promise<void> {
    const file = fileList?.[0];
    if (!file) {
      return;
    }
    setBusy(true);
    try {
      const data = await uploadFile(folder, file);
      onUploaded(data);
      toast.success(t('common.uploaded'));
    } catch (error) {
      toast.error(error instanceof Error ? error.message : t('common.error'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="space-y-1">
      <p className="text-sm font-medium">{label}</p>
      <div className="flex items-center gap-2">
        <Input type="file" accept="image/*" disabled={busy} onChange={(e) => void onChange(e.target.files)} />
        <Button type="button" variant="outline" disabled={busy}>
          {busy ? t('common.uploading') : t('common.upload')}
        </Button>
      </div>
    </div>
  );
}

export function GalleryUpload({
  label,
  folder,
  keys,
  onChange,
}: {
  label: string;
  folder: string;
  keys: string[];
  onChange: (keys: string[]) => void;
}) {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);

  async function onChangeFiles(fileList: FileList | null): Promise<void> {
    if (!fileList?.length) {
      return;
    }
    setBusy(true);
    try {
      const uploaded: string[] = [];
      for (const file of Array.from(fileList)) {
        const data = await uploadFile(folder, file);
        uploaded.push(data.url || data.key);
      }
      onChange([...keys, ...uploaded]);
      toast.success(t('common.uploaded'));
    } catch (error) {
      toast.error(error instanceof Error ? error.message : t('common.error'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="space-y-2">
      <p className="text-sm font-medium">{label}</p>
      <Input
        type="file"
        accept="image/*"
        multiple
        disabled={busy}
        onChange={(e) => void onChangeFiles(e.target.files)}
      />
      <p className="text-xs text-muted-foreground">{busy ? t('common.uploading') : t('common.photosHint')}</p>
      {keys.length > 0 ? (
        <div className="grid grid-cols-3 gap-2">
          {keys.map((src) => (
            <div key={src} className="relative overflow-hidden rounded-md border">
              <button type="button" className="block h-24 w-full" onClick={() => setPreview(src)}>
                <img src={mediaUrl(src)} alt="" className="h-24 w-full object-cover" />
              </button>
              <button
                type="button"
                className="absolute end-1 top-1 rounded bg-black/70 px-1.5 text-xs text-white"
                onClick={() => onChange(keys.filter((item) => item !== src))}
              >
                ×
              </button>
            </div>
          ))}
        </div>
      ) : null}
      <Dialog open={Boolean(preview)} onOpenChange={(open) => !open && setPreview(null)}>
        <DialogContent className="max-w-4xl overflow-auto p-2">
          {preview ? <img src={mediaUrl(preview)} alt="" className="max-h-[80vh] w-full object-contain" /> : null}
        </DialogContent>
      </Dialog>
    </div>
  );
}
