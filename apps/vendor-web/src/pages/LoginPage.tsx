import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { api, unwrap } from '@/lib/api';
import { setSession } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});
type Form = z.infer<typeof schema>;

export function LoginPage() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const form = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { email: 'palms@vendors.zayaevents.com', password: 'ChangeMeVendor!123' },
  });

  async function onSubmit(values: Form): Promise<void> {
    try {
      const data = await unwrap<{
        user: { id: string; email: string; role: string; firstName: string; lastName: string };
        tokens: { accessToken: string; refreshToken: string };
      }>(api.post('/api/v1/auth/login', values));
      if (data.user.role !== 'VENDOR') {
        toast.error(t('auth.invalidRole'));
        return;
      }
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
          <h1 className="text-4xl font-extrabold leading-tight">Fill your calendar with the right events.</h1>
          <p className="text-white/80">Manage listings, availability, booking requests, and guest messages — without seeing platform commissions.</p>
        </div>
        <p className="text-sm text-white/70">Demo: palms@vendors.zayaevents.com</p>
      </div>
      <div className="flex items-center justify-center bg-[#f5f7fa] p-6">
        <form className="w-full max-w-md space-y-5 rounded-2xl border bg-white p-8 shadow-xl shadow-blue-900/5" onSubmit={form.handleSubmit((v) => void onSubmit(v))}>
          <div>
            <p className="text-xs font-bold uppercase tracking-widest text-[#0071c2]">Vendors</p>
            <h2 className="mt-1 text-2xl font-extrabold">{t('app.name')}</h2>
            <p className="mt-1 text-sm text-muted-foreground">{t('auth.vendorOnly')}</p>
          </div>
          <div className="space-y-1">
            <Label>{t('auth.email')}</Label>
            <Input type="email" className="h-11" {...form.register('email')} />
          </div>
          <div className="space-y-1">
            <Label>{t('auth.password')}</Label>
            <Input type="password" className="h-11" {...form.register('password')} />
          </div>
          <Button className="h-11 w-full" variant="cta" type="submit" disabled={form.formState.isSubmitting}>
            {t('auth.login')}
          </Button>
          <Link className="block text-center text-sm font-medium text-[#0071c2]" to="/register">
            {t('auth.register')}
          </Link>
          <Button type="button" variant="ghost" className="w-full" onClick={() => void i18n.changeLanguage(i18n.language.startsWith('ar') ? 'en' : 'ar')}>
            {i18n.language.startsWith('ar') ? 'English' : 'العربية'}
          </Button>
        </form>
      </div>
    </div>
  );
}
