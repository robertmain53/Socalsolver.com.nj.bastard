import AuthorSchema from './AuthorSchema'
export default function AuthorCard({ author }) {
  return (
    <aside className="p-4 border rounded bg-gray-50 mt-8">
      <AuthorSchema {...author} />
      <h3 className="font-semibold">{author.name}</h3>
      <p className="text-sm">{author.bio}</p>
    </aside>
  )
}
