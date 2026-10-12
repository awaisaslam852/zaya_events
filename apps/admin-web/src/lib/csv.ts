export function downloadCsv(filename: string, rows: Array<Record<string, unknown>>): void {
  const keys = Array.from(new Set(rows.flatMap((row) => Object.keys(row))));
  const escape = (value: unknown) => `"${String(value ?? '').replaceAll('"', '""')}"`;
  const lines = [keys.join(','), ...rows.map((row) => keys.map((key) => escape(row[key])).join(','))];
  const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}
