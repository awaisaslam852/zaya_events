import { useFieldArray, useFormContext } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export function CustomFieldsBuilder() {
  const { t } = useTranslation();
  const { control, register } = useFormContext();
  const { fields, append, remove } = useFieldArray({ control, name: 'customFields' });

  return (
    <div className="space-y-3 rounded-md border p-3">
      <div className="flex items-center justify-between">
        <Label>customFields</Label>
        <Button
          type="button"
          size="sm"
          variant="outline"
          onClick={() =>
            append({
              key: '',
              label: { en: '', ar: '' },
              type: 'text',
              required: false,
              options: [],
            })
          }
        >
          {t('common.create')}
        </Button>
      </div>
      {fields.map((field, index) => (
        <div key={field.id} className="grid gap-2 rounded border p-2 md:grid-cols-2">
          <Input placeholder="key" {...register(`customFields.${index}.key`)} />
          <select className="h-10 rounded-md border px-2 text-sm" {...register(`customFields.${index}.type`)}>
            <option value="text">text</option>
            <option value="number">number</option>
            <option value="select">select</option>
            <option value="boolean">boolean</option>
          </select>
          <Input placeholder={t('common.english')} {...register(`customFields.${index}.label.en`)} />
          <Input dir="rtl" placeholder={t('common.arabic')} {...register(`customFields.${index}.label.ar`)} />
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" {...register(`customFields.${index}.required`)} />
            required
          </label>
          <Button type="button" size="sm" variant="destructive" onClick={() => remove(index)}>
            {t('common.delete')}
          </Button>
        </div>
      ))}
    </div>
  );
}
