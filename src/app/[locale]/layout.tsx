import Header from '@/components/layout/Header'
import Footer from '@/components/layout/Footer'

export default function LocaleLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col">
        <Header />
        <div className="flex-grow">{children}</div>
        <Footer />
      </body>
    </html>
  )
}
