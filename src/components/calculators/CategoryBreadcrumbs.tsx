import Link from 'next/link';
import { ChevronRightIcon } from 'lucide-react';

interface Props {
  category: string;
  locale: string;
}

export default function CategoryBreadcrumbs({ category, locale }: Props) {
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
        <li aria-current="page">
          <div className="flex items-center">
            <ChevronRightIcon className="w-4 h-4 text-gray-400" />
            <span className="inline-flex items-center text-sm font-medium text-gray-500 ml-1 md:ml-2">{category}</span>
          </div>
        </li>
      </ol>
    </nav>
  );
}
