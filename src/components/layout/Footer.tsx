'use client'
import { usePathname } from 'next/navigation'
export default function Footer() {
  const locale = usePathname().split('/')[1] || 'en'
  const year = new Date().getFullYear()
  return (
    <footer className="py-6 text-center text-sm text-gray-500 border-t mt-16">
      © {year} SoCalSolver – {locale.toUpperCase()}
    </footer>
  )
}
