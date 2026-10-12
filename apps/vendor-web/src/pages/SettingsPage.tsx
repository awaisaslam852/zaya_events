import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';
import { useEffect } from 'react';

const schema = z.object({
  email: z.boolean(),
  push: z.boolean(),
  whatsapp: z.boolean(),
});
type Form = z.infer<typeof schema>;

type Profile = { notificationPrefs?: Form };

export function SettingsPage() {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const form = useForm<Form>({ resolver: zodResolver(schema), defaultValues: { email: true, push: true, whatsapp: false } });
  const me = useQuery({ queryKey: ['vendor-me'], queryFn: () => unwrap<Profile>(api.get('/api/v1/vendors/me')) });

  useEffect(() => {
    if (me.data?.notificationPrefs) {
      form.reset(me.data.notificationPrefs);
    }
  }, [me.data, form]);

  const save = useMutation({
    mutationFn: (values: Form) => unwrap(api.patch('/api/v1/vendors/me', { notificationPrefs: values })),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['vendor-me'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="grid max-w-3xl gap-4 md:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>{t('settings.notifications')}</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-3" onSubmit={form.handleSubmit((v) => save.mutate(v))}>
            {(['email', 'push', 'whatsapp'] as const).map((key) => (
              <label key={key} className="flex items-center gap-2 text-sm">
                <input type="checkbox" {...form.register(key)} />
                {key}
              </label>
            ))}
            <Button type="submit">{t('common.save')}</Button>
          </form>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle>{t('settings.language')}</CardTitle>
        </CardHeader>
        <CardContent>
          <Button variant="outline" onClick={() => void i18n.changeLanguage(i18n.language.startsWith('ar') ? 'en' : 'ar')}>
            {i18n.language.startsWith('ar') ? 'English' : 'العربية'}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
