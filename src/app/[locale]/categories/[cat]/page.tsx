export default function CategoryPage({ params }: { params: { locale: string, cat: string } }) {
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-4">Category: {params.cat}</h1>
      <p>More content coming soon for locale: {params.locale}</p>
    </main>
  );
}
