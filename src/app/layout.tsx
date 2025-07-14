import './globals.css'
import { ReactNode } from 'react'
import Header from '@/components/layout/Header'

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Header />
        {children}</body>
    </html>
  )
}
