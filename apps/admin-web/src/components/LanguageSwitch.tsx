import { useTranslation } from 'react-i18next';
import { cn } from '@/lib/utils';

const LANGS = [
  { code: 'en', label: 'English' },
  { code: 'ar', label: 'العربية' },
] as const;

export function LanguageSwitch({ className }: { className?: string }) {
  const { i18n, t } = useTranslation();
  const current = i18n.language.startsWith('ar') ? 'ar' : 'en';

  return (
    <div className={cn('inline-flex shrink-0 rounded-lg border bg-white p-0.5', className)} role="group" aria-label={t('common.locale')}>
      {LANGS.map((lang) => (
        <button
          key={lang.code}
          type="button"
          onClick={() => {
            if (current !== lang.code) {
              void i18n.changeLanguage(lang.code);
            }
          }}
          className={cn(
            'rounded-md px-2.5 py-1.5 text-xs font-bold',
            current === lang.code ? 'bg-[#003580] text-white' : 'text-slate-600 hover:bg-slate-50',
          )}
        >
          {lang.label}
        </button>
      ))}
    </div>
  );
}
