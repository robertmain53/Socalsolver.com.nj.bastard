// src/app/[locale]/[cat]/page.tsx
import { getCategoryData } from '@/lib/loadCategory'
import { getCalculatorsByCategory } from '@/lib/calculator-registry'
import { notFound } from 'next/navigation'
import CalculatorCard from '@/components/CalculatorCard'
import Link from 'next/link'

export default async function CategoryPage({ params }) {
  const data = await getCategoryData(params.locale)
  const cat = data[params.cat]
  if (!cat) return notFound()

  const calculators = getCalculatorsByCategory(params.cat, params.locale)

  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-2">{cat.title}</h1>
      <p className="text-gray-600 mb-6">{cat.description}</p>

      {cat.children && Object.keys(cat.children).length > 0 && (
        <div className="mb-8">
          <h2 className="text-xl font-semibold mb-2">Subcategories</h2>
          <ul className="list-disc list-inside text-blue-700">
            {Object.entries(cat.children).map(([slug, sub]) => (
              <li key={slug}>
                <Link href={`/${params.locale}/${params.cat}/${slug}`}>{sub.title}</Link>
              </li>
            ))}
          </ul>
        </div>
      )}

      {calculators.length === 0 ? (
        <p>No calculators found in this category.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {calculators.map(calc => (
            <CalculatorCard key={calc.slug} calculator={calc} locale={params.locale} />
          ))}
        </div>
      )}
    </div>
  )
}
