import Link from 'next/link';
import type { CalculatorMeta } from '@/lib/calculator-registry';

type Props = {
  calculator: CalculatorMeta;          // ← adapt to whatever shape you store
  locale: string;
};

export default function CalculatorCard({ calculator, locale }: Props) {
  const { slug, title, description, icon } = calculator;

  return (
    <article className="rounded-2xl border p-4 shadow-sm transition hover:shadow-md">
      <Link href={`/${locale}/${slug}`} className="flex gap-3 items-start">
        {icon && <span className="text-3xl">{icon}</span>}
        <div>
          <h3 className="font-semibold">{title}</h3>
          {description && <p className="text-sm text-gray-600">{description}</p>}
        </div>
      </Link>
    </article>
  );
}
