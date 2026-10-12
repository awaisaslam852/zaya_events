import { useState } from 'react';
import { FormProvider, useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import { api, unwrap, type Paginated } from '@/lib/api';
import { asLoc, loc } from '@/lib/utils';
import { ListToolbar } from '@/components/ListToolbar';
import { LocalizedFields } from '@/components/LocalizedFields';
import { CustomFieldsBuilder } from '@/components/CustomFieldsBuilder';
import { EmptyHint } from '@/components/AdminChrome';
import { StatusBadge } from '@/components/StatusBadge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { toast } from 'sonner';

const locSchema = z.object({ en: z.string().min(1), ar: z.string().min(1) });
const schema = z.object({
  slug: z.string().min(2).regex(/^[a-z0-9-]+$/),
  name: locSchema,
  description: locSchema,
  icon: z.string().optional(),
  sortOrder: z.coerce.number(),
  isActive: z.boolean(),
  customFields: z.array(
    z.object({
      key: z.string().min(1),
      label: locSchema,
      type: z.enum(['text', 'number', 'select', 'boolean']),
      required: z.boolean(),
      options: z.array(locSchema).optional(),
    }),
  ),
});
type Form = z.infer<typeof schema>;

type Category = {
  id: string;
  slug: string;
  name: unknown;
  description?: unknown;
  icon?: string | null;
  sortOrder?: number;
  isActive: boolean;
  customFields?: unknown;
};

const emptyForm: Form = {
  slug: '',
  name: { en: '', ar: '' },
  description: { en: '', ar: '' },
  icon: '',
  sortOrder: 0,
  isActive: true,
  customFields: [],
};

function toForm(row: Category): Form {
  return {
    slug: row.slug,
    name: asLoc(row.name),
    description: asLoc(row.description),
    icon: row.icon ?? '',
    sortOrder: row.sortOrder ?? 0,
    isActive: row.isActive,
    customFields: Array.isArray(row.customFields) ? (row.customFields as Form['customFields']) : [],
  };
}

export function CategoriesPage({ kind }: { kind: 'event' | 'service' }) {
  const { t, i18n } = useTranslation();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const path = kind === 'event' ? '/api/v1/event-categories' : '/api/v1/service-categories';
  const key = kind === 'event' ? 'event-categories' : 'service-categories';
  const form = useForm<Form>({ resolver: zodResolver(schema), defaultValues: emptyForm });
  const list = useQuery({
    queryKey: [key, page, q],
    queryFn: () =>
      unwrap<Paginated<Category>>(api.get(path, { params: { page, pageSize: 20, q, includeInactive: 'true' } })),
  });
  const save = useMutation({
    mutationFn: (values: Form) =>
      editingId ? unwrap(api.patch(`${path}/${editingId}`, values)) : unwrap(api.post(path, values)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: [key] });
      setOpen(false);
      setEditingId(null);
      form.reset(emptyForm);
      toast.success(t('common.save'));
    },
    onError: (e: Error) => toast.error(e.message),
  });
  const toggle = useMutation({
    mutationFn: (row: Category) => unwrap(api.post(`${path}/${row.id}/${row.isActive ? 'disable' : 'enable'}`)),
    onSuccess: () => void qc.invalidateQueries({ queryKey: [key] }),
    onError: (e: Error) => toast.error(e.message),
  });
  const remove = useMutation({
    mutationFn: (id: string) => unwrap(api.delete(`${path}/${id}`)),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: [key] });
      toast.success(t('common.delete'));
    },
    onError: (e: Error) => toast.error(e.message),
  });

  async function openEdit(row: Category) {
    const full = await unwrap<Category>(api.get(`${path}/${row.id}`));
    setEditingId(full.id);
    form.reset(toForm(full));
    setOpen(true);
  }

  return (
    <div>
      <ListToolbar
        title={t(kind === 'event' ? 'nav.eventCategories' : 'nav.serviceCategories')}
        subtitle="Names, slugs, and custom fields used on the customer app."
        search={q}
        onSearch={(v) => {
          setQ(v);
          setPage(1);
        }}
        page={page}
        pageCount={list.data?.pageCount ?? 1}
        onPage={setPage}
        extra={
          <Dialog
            open={open}
            onOpenChange={(next) => {
              setOpen(next);
              if (!next) {
                setEditingId(null);
                form.reset(emptyForm);
              }
            }}
          >
            <DialogTrigger asChild>
              <Button
                onClick={() => {
                  setEditingId(null);
                  form.reset(emptyForm);
                }}
              >
                {t('common.create')}
              </Button>
            </DialogTrigger>
            <DialogContent className="max-h-[90vh] overflow-y-auto max-w-2xl">
              <DialogHeader>
                <DialogTitle>{editingId ? t('common.edit') : t('common.create')}</DialogTitle>
              </DialogHeader>
              <FormProvider {...form}>
                <form className="space-y-3" onSubmit={form.handleSubmit((v) => save.mutate(v))}>
                  <div>
                    <Label>slug</Label>
                    <Input {...form.register('slug')} />
                  </div>
                  <LocalizedFields name="name" />
                  <LocalizedFields name="description" textarea />
                  <Input placeholder="icon" {...form.register('icon')} />
                  <Input type="number" {...form.register('sortOrder')} />
                  <label className="flex items-center gap-2 text-sm">
                    <input type="checkbox" {...form.register('isActive')} />
                    {t('common.status')}
                  </label>
                  <CustomFieldsBuilder />
                  <Button type="submit">{t('common.save')}</Button>
                </form>
              </FormProvider>
            </DialogContent>
          </Dialog>
        }
      />
      {(list.data?.items ?? []).length === 0 ? (
        <EmptyHint>{t('common.empty')}</EmptyHint>
      ) : (
        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {(list.data?.items ?? []).map((row) => (
            <article key={row.id} className="rounded-2xl border bg-white p-4 shadow-sm">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{row.slug}</p>
                  <h2 className="text-lg font-extrabold text-[#003580]">{loc(row.name, i18n.language)}</h2>
                </div>
                <StatusBadge status={row.isActive ? 'ACTIVE' : 'INACTIVE'} />
              </div>
              <div className="mt-4 flex flex-wrap gap-2">
                <Button size="sm" variant="outline" onClick={() => void openEdit(row)}>
                  {t('common.edit')}
                </Button>
                <Button size="sm" variant="outline" onClick={() => toggle.mutate(row)}>
                  {row.isActive ? t('common.deactivate') : t('common.activate')}
                </Button>
                <Button
                  size="sm"
                  variant="destructive"
                  onClick={() => {
                    if (window.confirm(t('common.confirmDelete'))) {
                      remove.mutate(row.id);
                    }
                  }}
                >
                  {t('common.delete')}
                </Button>
              </div>
            </article>
          ))}
        </div>
      )}
    </div>
  );
}

export function EventCategoriesPage() {
  return <CategoriesPage kind="event" />;
}

export function ServiceCategoriesPage() {
  return <CategoriesPage kind="service" />;
}
