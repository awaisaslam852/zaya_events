import { useFormContext } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';

export function LocalizedFields({ name, textarea = false, label }: { name: string; textarea?: boolean; label?: string }) {
  const { t, i18n } = useTranslation();
  const { setValue, watch } = useFormContext();
  const isAr = i18n.language.startsWith('ar');
  const value =
    (watch(`${name}.${isAr ? 'ar' : 'en'}`) as string | undefined) ??
    (watch(`${name}.en`) as string | undefined) ??
    '';
  const Field = textarea ? Textarea : Input;
  return (
    <div className="space-y-1">
      <Label className="capitalize">{label ?? name}</Label>
      <Field
        dir={isAr ? 'rtl' : 'ltr'}
        value={value}
        onChange={(event) => {
          const next = event.target.value;
          setValue(`${name}.en`, next, { shouldDirty: true, shouldValidate: true });
          setValue(`${name}.ar`, next, { shouldDirty: true, shouldValidate: true });
        }}
      />
      <p className="text-xs text-muted-foreground">{t('common.languageHint')}</p>
    </div>
  );
}
