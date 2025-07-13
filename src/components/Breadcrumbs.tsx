import Link from 'next/link'

export default function Breadcrumbs({ segments }: { segments: string[] }) {
  const locale = segments[0]
  const trail = segments.slice(1)
  let path = `/${locale}`
  return (
    <nav className="text-sm mb-4">
      <ol className="flex gap-1 text-blue-700 flex-wrap">
        <li><Link href={path}>Home</Link></li>
        {trail.map((seg, i) => {
          path += `/${seg}`
          return (
            <li key={i} className="flex gap-1">
              <span>/</span>
              <Link href={path}>{seg.replace(/-/g,' ')}</Link>
            </li>
          )
        })}
      </ol>
    </nav>
  )
}
