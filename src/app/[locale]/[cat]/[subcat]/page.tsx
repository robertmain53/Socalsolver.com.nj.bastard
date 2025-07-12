// src/app/[locale]/[cat]/[subcat]/page.tsx
import { getCategoryData } from '@/lib/loadCategory'
import { getCalculatorsByCategory } from '@/lib/calculator-registry'
import { notFound } from 'next/navigation'
import CalculatorCard from '@/components/CalculatorCard'
import Link from 'next/link'

export default async function SubCategoryPage({ params }) {
  const { locale, cat, subcat } = params
  const data = await getCategoryData(locale)
  const catObj = data[cat]
  const subObj = catObj?.children?.[subcat]
  if (!subObj) return notFound()

  const calculators = getCalculatorsByCategory(`${cat}/${subcat}`, locale)

  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-2">{subObj.title}</h1>
      <p className="text-gray-600 mb-6">{subObj.description}</p>

      {/* Sub‑subcategories */}
      {subObj.children && Object.keys(subObj.children).length > 0 && (
        <div className="mb-8">
          <h2 className="text-xl font-semibold mb-2">Topics</h2>
          <ul className="list-disc list-inside text-blue-700">
            {Object.entries(subObj.children).map(([slug, child]) => (
              <li key={slug}>
                <Link href={`/${locale}/${cat}/${subcat}/${slug}`}>{child.title}</Link>
              </li>
            ))}
          </ul>
        </div>
      )}

      {calculators.length === 0 ? (
        <p>No calculators in this section.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {calculators.map(calc => (
            <CalculatorCard key={calc.slug} calculator={calc} locale={locale} />
          ))}
        </div>
      )}
    </div>
  )
}
