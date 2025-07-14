import Link from 'next/link';
import { ChevronRightIcon } from 'lucide-react';
import type { CalculatorSEO } from '@/lib/seo';

interface Props {
  calculator: CalculatorSEO;
  locale: string;
}

export default function CalculatorBreadcrumbs({ calculator, locale }: Props) {
  // Derive category slug and names for breadcrumb (if available)
  const categorySlug = (calculator as any).category || calculator?.seo?.category;
  const categoryName = (calculator as any).categoryName || calculator?.seo?.category || 'Category';
  const calcTitle = (calculator as any).title || (calculator as any).name || calculator?.seo?.title || calculator?.seo?.name || calculator?.seo?.slug || 'Calculator';
  return (
    <nav className="flex mb-6" aria-label="Breadcrumb">
      <ol className="inline-flex items-center space-x-1 md:space-x-3">
        <li className="inline-flex items-center">
          <Link href={`/${locale}`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600">Home</Link>
        </li>
        <li>
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <Link href={`/${locale}/calculators`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 ml-1 md:ml-2">Calculators</Link>
          </div>
        </li>
        {categorySlug && (
          <li>
            <div className="flex items-center">
              <ChevronRightIcon className="w-4 h-4 text-gray-400" />
              <Link href={`/${locale}/${categorySlug}`} className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600 ml-1 md:ml-2">{categoryName}</Link>
            </div>
          </li>
        )}
        <li aria-current="page">
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <span className="inline-flex items-center text-sm font-medium text-gray-500 ml-1 md:ml-2">{calcTitle}</span>
          </div>
        </li>
      </ol>
    </nav>
  );
}
