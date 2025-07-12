// src/lib/calculator-registry.ts
export async function loadCalculator(slug: string) {
  return await import(`../../generated/calculators/${slug}.js`);
}

