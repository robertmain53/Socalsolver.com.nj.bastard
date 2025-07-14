import { getDictionary } from '@/lib/i18n';

export default async function LocaleHome({ params }: { params: { locale: string } }) {
  const locale = params.locale || 'en';
  const t = await getDictionary(locale);

  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">{t.home?.title || 'Welcome to SoCalSolver'}</h1>
      <p className="text-lg mb-6">{t.home?.description || 'Smart calculators for every need.'}</p>
    </main>
  );
}
