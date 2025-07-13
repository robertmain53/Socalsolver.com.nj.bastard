'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
export default function Header() {
  const locale = (usePathname().split('/')[1] || 'en') as string
  return (
    <header className="px-6 py-4 border-b flex gap-6">
      <Link href={`/${locale}`} className="font-bold">SoCalSolver</Link>
    </header>
  )
}
