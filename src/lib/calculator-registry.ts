// src/lib/calculator-registry.ts

export async function loadCalculator(slug: string): Promise<any | null> {
  try {
    const module = await import(`../../generated/calculators/${slug}.js`)
    return module?.default || module
  } catch (err: any) {
    console.error(`❌ Calculator module not found for slug: ${slug}`)
    return null
  }
}

