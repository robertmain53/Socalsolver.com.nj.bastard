'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const labels: Record<string, string> = { en: 'Home', fr: 'Accueil', es: 'Inicio', it: 'Home' };

export default function Header() {
  const path = usePathname();
  const locale = path.split('/')[1] || 'en';
  return (
    <header className="py-4 border-b flex gap-6 px-4">
      <Link href={`/${locale}`} className="font-bold text-lg">SoCalSolver</Link>
      <Link href={`/${locale}`} className="text-sm font-medium hover:text-blue-600">
        {labels[locale] || 'Home'}
      </Link>
    </header>
  );
}
