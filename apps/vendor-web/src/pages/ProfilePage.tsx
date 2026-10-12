import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { LocalizedFields } from '@/components/LocalizedFields';
import { FileUpload } from '@/components/FileUpload';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';
import { useEffect } from 'react';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  businessName: locSchema,
  description: locSchema,
  city: z.string().optional(),
  country: z.string().optional(),
  phone: z.string().optional(),
  website: z.string().optional(),
  logoKey: z.string().optional(),
  coverKey: z.string().optional(),
  serviceAreas: z.string().optional(),
});
type Form = z.infer<typeof schema>;

type Profile = {
  businessName: { en: string; ar: string };
  description: { en: string; ar: string };
  city: string | null;
  country: string | null;
  phone: string | null;
  website: string | null;
  logoKey: string | null;
  coverKey: string | null;
  serviceAreas: unknown;
  galleryKeys: unknown;
};

export function ProfilePage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const form = useForm<Form>({ resolver: zodResolver(schema) });
  const me = useQuery({ queryKey: ['vendor-me'], queryFn: () => unwrap<Profile>(api.get('/api/v1/vendors/me')) });
  const gallery = (Array.isArray(me.data?.galleryKeys) ? me.data.galleryKeys : []) as string[];

  useEffect(() => {
    if (!me.data) {
      return;
    }
    const areas = Array.isArray(me.data.serviceAreas) ? (me.data.serviceAreas as string[]).join(', ') : '';
    form.reset({
      businessName: me.data.businessName,
      description: me.data.description,
      city: me.data.city ?? '',
      country: me.data.country ?? '',
      phone: me.data.phone ?? '',
      website: me.data.website ?? '',
      logoKey: me.data.logoKey ?? '',
      coverKey: me.data.coverKey ?? '',
      serviceAreas: areas,
    });
  }, [me.data, form]);

  const save = useMutation({
    mutationFn: (values: Form) =>
      unwrap(
        api.patch('/api/v1/vendors/me', {
          ...values,
          website: values.website || undefined,
          serviceAreas: (values.serviceAreas ?? '')
            .split(',')
            .map((s) => s.trim())
            .filter(Boolean),
        }),
      ),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['vendor-me'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });

  const addGallery = useMutation({
    mutationFn: (key: string) => unwrap(api.patch('/api/v1/vendors/me', { galleryKeys: [...gallery, key] })),
    onSuccess: () => void qc.invalidateQueries({ queryKey: ['vendor-me'] }),
  });

  return (
    <FormProvider {...form}>
      <form className="max-w-2xl space-y-3" onSubmit={form.handleSubmit((v) => save.mutate(v))}>
        <h1 className="text-2xl font-semibold">{t('nav.profile')}</h1>
        <LocalizedFields name="businessName" />
        <LocalizedFields name="description" textarea />
        <div className="grid gap-2 md:grid-cols-2">
          <div>
            <Label>{t('common.city')}</Label>
            <Input {...form.register('city')} />
          </div>
          <div>
            <Label>Country</Label>
            <Input {...form.register('country')} />
          </div>
          <div>
            <Label>{t('auth.phone')}</Label>
            <Input {...form.register('phone')} />
          </div>
          <div>
            <Label>Website</Label>
            <Input {...form.register('website')} />
          </div>
        </div>
        <Input placeholder="Dubai, Abu Dhabi" {...form.register('serviceAreas')} />
        <FileUpload label="Logo" folder="vendors" onUploaded={(f) => form.setValue('logoKey', f.key)} />
        <FileUpload label="Cover" folder="vendors" onUploaded={(f) => form.setValue('coverKey', f.key)} />
        <FileUpload label="Gallery" folder="vendors" onUploaded={(f) => addGallery.mutate(f.key)} />
        <p className="text-xs text-muted-foreground">{gallery.length} images</p>
        <Button type="submit">{t('common.save')}</Button>
      </form>
    </FormProvider>
  );
}
