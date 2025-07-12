// src/app/[locale]/[cat]/[subcat]/[subsubcat]/page.tsx
import { getCategoryData } from '@/lib/loadCategory'
import { getCalculatorsByCategory } from '@/lib/calculator-registry'
import { notFound } from 'next/navigation'
import CalculatorCard from '@/components/CalculatorCard'

export default async function SubSubCategoryPage({ params }) {
  const { locale, cat, subcat, subsubcat } = params
  const data = await getCategoryData(locale)
  const subsub = data?.[cat]?.children?.[subcat]?.children?.[subsubcat]
  if (!subsub) return notFound()

  const calculators = getCalculatorsByCategory(`${cat}/${subcat}/${subsubcat}`, locale)

  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-2">{subsub.title}</h1>
      <p className="text-gray-600 mb-6">{subsub.description}</p>

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
