import { getCategoryData } from '@/lib/category'
import { getCalculatorsByCategory } from '@/lib/calculator-registry'
import Link from 'next/link'
import CalculatorCard from '@/components/CalculatorCard'
import { notFound } from 'next/navigation'

type Props = {
  params: {
    locale: string
    cat: string
    subcat: string
  }
}

export default async function SubCategoryPage({ params }: Props) {
  const { locale, cat, subcat } = params
  const data: any = await getCategoryData(locale)
  const catObj = data?.[cat]
  if (!catObj) return notFound()

  const subObj = catObj.children?.[subcat]
  if (!subObj) return notFound()

  const calculators = getCalculatorsByCategory(`${cat}/${subcat}`)


  return (
    <div className="max-w-5xl mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-2">{subObj.title}</h1>
      <p className="text-gray-600 mb-6">{subObj.description}</p>

      {subObj.children && Object.keys(subObj.children).length > 0 && (
        <div className="mb-8">
          <h2 className="text-xl font-semibold mb-2">Topics</h2>
          <ul className="list-disc list-inside text-blue-700">
            {Object.entries(subObj.children).map(([slug, child]: any) => (
              <li key={slug}>
                <Link href={`/${locale}/${cat}/${subcat}/${slug}`}>
                  {child.title}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}

      {calculators.length === 0 ? (
        <p>No calculators in this section.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {calculators.map((calc: any) => (
            <CalculatorCard key={calc.slug} calculator={calc} locale={locale} />
          ))}
        </div>
      )}
    </div>
  )
}
