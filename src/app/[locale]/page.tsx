// File: src/app/[locale]/page.tsx

import { getTranslations } from '@/lib/i18n';
import { getCategoryTree } from '@/lib/category-data';
import CategoryGrid from '@/components/CategoryGrid';
import HeroSection from '@/components/HeroSection';
import { Metadata } from 'next';

export async function generateMetadata({ params }: { params: { locale: string } }): Promise<Metadata> {
  const t = await getTranslations(params.locale);
  return {
    title: t.metaTitle || 'SoCalSolver - Smart Calculators for Life',
    description: t.metaDescription || 'Explore powerful calculators in Finance, Health, Math, and more — in your language.'
  };
}

export default async function Home({ params }: { params: { locale: string } }) {
  const t = await getTranslations(params.locale);
  const categories = await getCategoryTree(params.locale);

  return (
    <main className="p-6 space-y-12">
      <HeroSection title={t.heroTitle} subtitle={t.heroSubtitle} locale={params.locale} />
      <CategoryGrid categories={categories} locale={params.locale} />
    </main>
  );
}

