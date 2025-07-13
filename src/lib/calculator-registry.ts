import fs from 'fs'
import path from 'path'

const calcDir = path.join(process.cwd(), 'generated', 'calculators')

export async function loadCalculator(slug: string) {
  try {
    const mod = await import(`../../generated/calculators/${slug}.js`)
    return mod.default || mod
  } catch {
    return null
  }
}

export function calculators(): string[] {
  return fs.existsSync(calcDir)
    ? fs.readdirSync(calcDir).filter(f => f.endsWith('.js')).map(f => f.replace('.js', ''))
    : []
}

// NEW: Used by category/subcategory pages
export function getCalculatorsByCategory(category: string): string[] {
  const all = calculators()
  return all.filter(slug => slug.includes(category)) // Adjust logic as needed
}
