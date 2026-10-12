import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { APP_CURRENCIES } from '@/lib/countries';
import { setAppCurrency } from '@/lib/currency';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/StatusBadge';
import { toast } from 'sonner';

const schema = z.object({
  key: z.string().min(1),
  group: z.string().min(1),
  value: z.string().min(1),
});
type Form = z.infer<typeof schema>;

type Setting = { id: string; key: string; group: string; value: unknown };
type IntegrationValue = boolean | { mode?: string; configured?: boolean };
type Integrations = Record<string, IntegrationValue>;

function isConfigured(value: IntegrationValue | undefined): boolean {
  if (typeof value === 'boolean') return value;
  return Boolean(value?.configured);
}

function integrationMode(value: IntegrationValue | undefined): string | undefined {
  if (!value || typeof value === 'boolean') return undefined;
  return value.mode;
}

export function SettingsPage() {
  const { t } = useTranslation();
  const qc = useQueryClient();
  const general = useForm<Form>({ resolver: zodResolver(schema), defaultValues: { key: 'general.siteName', group: 'general', value: 'Zaya Events' } });
  const notifications = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { key: 'notifications.emailEnabled', group: 'notifications', value: 'true' },
  });
  const communication = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { key: 'communication.whatsappEnabled', group: 'communication', value: 'false' },
  });
  const currency = useForm<{ currency: string }>({ defaultValues: { currency: 'AED' } });
  const list = useQuery({
    queryKey: ['settings'],
    queryFn: () => unwrap<{ items: Setting[] }>(api.get('/api/v1/settings')),
  });
  const integrations = useQuery({
    queryKey: ['settings-integrations'],
    queryFn: () => unwrap<Integrations>(api.get('/api/v1/settings/integrations')),
  });
  const publicSettings = useQuery({
    queryKey: ['settings-public'],
    queryFn: () => unwrap<{ currency: string }>(api.get('/api/v1/settings/public')),
  });
  useEffect(() => {
    const code = publicSettings.data?.currency;
    if (!code) {
      return;
    }
    currency.reset({ currency: code });
    setAppCurrency(code);
  }, [publicSettings.data?.currency, currency]);
  const saveCurrency = useMutation({
    mutationFn: (code: string) => unwrap(api.post('/api/v1/settings', { key: 'general.currency', group: 'general', value: code })),
    onSuccess: (_data, code) => {
      setAppCurrency(code);
      void qc.invalidateQueries({ queryKey: ['settings'] });
      void qc.invalidateQueries({ queryKey: ['settings-public'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const save = useMutation({
    mutationFn: (values: Form) => {
      let parsed: unknown = values.value;
      try {
        parsed = JSON.parse(values.value) as unknown;
      } catch {
        parsed = values.value;
      }
      return unwrap(api.post('/api/v1/settings', { key: values.key, group: values.group, value: parsed }));
    },
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['settings'] });
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-3xl font-extrabold text-[#003580]">{t('nav.settings')}</h1>
        <p className="text-sm text-muted-foreground">Platform keys, notification flags, and connected services.</p>
      </div>
    <div className="grid gap-4 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>{t('settings.currency')}</CardTitle>
        </CardHeader>
        <CardContent>
          <form
            className="space-y-3"
            onSubmit={currency.handleSubmit((v) => saveCurrency.mutate(v.currency))}
          >
            <p className="text-sm text-muted-foreground">{t('settings.currencyHint')}</p>
            <div>
              <Label>{t('settings.currency')}</Label>
              <select className="mt-1 h-10 w-full rounded-md border px-2 text-sm" {...currency.register('currency')}>
                {APP_CURRENCIES.map((code) => (
                  <option key={code} value={code}>
                    {code}
                  </option>
                ))}
              </select>
            </div>
            <Button type="submit" disabled={saveCurrency.isPending}>
              {t('common.save')}
            </Button>
          </form>
        </CardContent>
      </Card>
      <SettingForm title={t('settings.general')} form={general} onSave={(v) => save.mutate(v)} tSave={t('common.save')} />
      <SettingForm title={t('settings.notifications')} form={notifications} onSave={(v) => save.mutate(v)} tSave={t('common.save')} />
      <SettingForm title={t('settings.communication')} form={communication} onSave={(v) => save.mutate(v)} tSave={t('common.save')} />
      <Card>
        <CardHeader>
          <CardTitle>{t('settings.integrations')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-1 text-sm">
          {Object.entries(integrations.data ?? {}).map(([k, v]) => {
            const configured = isConfigured(v);
            const mode = integrationMode(v);
            return (
              <div key={k} className="flex items-center justify-between gap-3 rounded-lg border px-3 py-2">
                <div className="min-w-0">
                  <p className="font-medium capitalize">{k}</p>
                  {mode ? (
                    <p className="text-xs text-muted-foreground">
                      {t('settings.mode')}: {mode}
                    </p>
                  ) : null}
                </div>
                <StatusBadge status={configured ? 'ACTIVE' : 'CONFIGURATION_NEEDED'} />
              </div>
            );
          })}
        </CardContent>
      </Card>
      <Card className="lg:col-span-2">
        <CardHeader>
          <CardTitle>{t('nav.settings')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-1 text-sm">
          {(list.data?.items ?? []).map((row) => (
            <div key={row.id} className="rounded-lg bg-[#f5f7fa] px-3 py-2">
              <span className="text-xs text-muted-foreground">{row.group}</span>
              <p className="font-semibold">{row.key}</p>
              <p className="text-xs break-all">{JSON.stringify(row.value)}</p>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
    </div>
  );
}

function SettingForm({
  title,
  form,
  onSave,
  tSave,
}: {
  title: string;
  form: ReturnType<typeof useForm<Form>>;
  onSave: (v: Form) => void;
  tSave: string;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <form className="space-y-2" onSubmit={form.handleSubmit(onSave)}>
          <div>
            <Label>key</Label>
            <Input {...form.register('key')} />
          </div>
          <div>
            <Label>group</Label>
            <Input {...form.register('group')} />
          </div>
          <div>
            <Label>value</Label>
            <Input {...form.register('value')} />
          </div>
          <Button type="submit">{tSave}</Button>
        </form>
      </CardContent>
    </Card>
  );
}
