import type { ReactNode } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { setSession } from '@/lib/auth';
import { COUNTRIES } from '@/lib/countries';
import { LocalizedFields } from '@/components/LocalizedFields';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  phone: z.string().min(8),
  country: z.string().min(2),
  city: z.string().min(1),
  legalName: z.string().min(1),
  taxId: z.string().min(1),
  website: z.string().optional(),
  businessName: locSchema,
  description: locSchema.optional(),
});
type Form = z.infer<typeof schema>;

export function RegisterPage() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: {
      email: '',
      password: '',
      firstName: '',
      lastName: '',
      phone: '',
      country: 'AE',
      city: '',
      legalName: '',
      taxId: '',
      website: '',
      businessName: { en: '', ar: '' },
      description: { en: 'Wedding vendor', ar: 'مورد مناسبات' },
    },
  });

  async function onSubmit(values: Form): Promise<void> {
    try {
      const data = await unwrap<{
        user: { id: string; email: string; role: string; firstName: string; lastName: string };
        tokens: { accessToken: string; refreshToken: string };
      }>(
        api.post('/api/v1/auth/register', {
          ...values,
          website: values.website?.trim() || undefined,
          role: 'vendor',
          locale: i18n.language.startsWith('ar') ? 'ar' : 'en',
        }),
      );
      setSession({ accessToken: data.tokens.accessToken, refreshToken: data.tokens.refreshToken, user: data.user });
      navigate('/');
    } catch (error) {
      toast.error(error instanceof Error ? error.message : t('common.error'));
    }
  }

  return (
    <div className="grid min-h-screen lg:grid-cols-2" dir={i18n.language.startsWith('ar') ? 'rtl' : 'ltr'}>
      <div className="brand-hero relative hidden flex-col justify-between p-10 text-white lg:flex">
        <p className="text-sm font-semibold uppercase tracking-[0.25em] text-[#FEBB02]">Partner Hub</p>
        <div className="max-w-lg space-y-4">
          <h1 className="text-4xl font-extrabold leading-tight">Join Zaya as a verified vendor.</h1>
          <p className="text-white/80">Tell us about the business so guests can find the right halls, cars, stays, and services.</p>
        </div>
        <p className="text-sm text-white/70">Applications are reviewed before listings go live.</p>
      </div>
      <div className="flex items-center justify-center bg-[#f5f7fa] p-6">
        <FormProvider {...form}>
          <form
            className="w-full max-w-2xl space-y-4 rounded-2xl border bg-white p-8 shadow-xl shadow-blue-900/5"
            onSubmit={form.handleSubmit((v) => void onSubmit(v))}
          >
            <div>
              <p className="text-xs font-bold uppercase tracking-widest text-[#0071c2]">Vendors</p>
              <h2 className="mt-1 text-2xl font-extrabold text-[#003580]">{t('auth.register')}</h2>
            </div>
            <div className="grid gap-3 md:grid-cols-2">
              <Field label={t('auth.firstName')}>
                <Input {...form.register('firstName')} />
              </Field>
              <Field label={t('auth.lastName')}>
                <Input {...form.register('lastName')} />
              </Field>
              <Field label={t('auth.email')}>
                <Input type="email" {...form.register('email')} />
              </Field>
              <Field label={t('auth.password')}>
                <Input type="password" {...form.register('password')} />
              </Field>
              <Field label={t('auth.phone')}>
                <Input {...form.register('phone')} />
              </Field>
              <Field label={t('auth.country')}>
                <select className="h-10 w-full rounded-md border px-2 text-sm" {...form.register('country')}>
                  {COUNTRIES.map((row) => (
                    <option key={row.code} value={row.code}>
                      {row.name}
                    </option>
                  ))}
                </select>
              </Field>
              <Field label={t('common.city')}>
                <Input {...form.register('city')} />
              </Field>
              <Field label={t('auth.legalName')}>
                <Input {...form.register('legalName')} />
              </Field>
              <Field label={t('auth.taxId')}>
                <Input {...form.register('taxId')} />
              </Field>
              <Field label={t('auth.website')}>
                <Input {...form.register('website')} />
              </Field>
            </div>
            <LocalizedFields name="businessName" />
            <Button className="h-11 w-full" variant="cta" type="submit" disabled={form.formState.isSubmitting}>
              {t('auth.register')}
            </Button>
            <Link className="block text-center text-sm font-medium text-[#0071c2]" to="/login">
              {t('auth.login')}
            </Link>
          </form>
        </FormProvider>
      </div>
    </div>
  );
}

function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="space-y-1">
      <Label>{label}</Label>
      {children}
    </div>
  );
}
