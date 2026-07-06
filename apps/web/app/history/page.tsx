export default function HistoryPage() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-6 px-6 py-10">
      <header className="space-y-3">
        <p className="text-sm font-semibold text-[#C56F5C]">기록</p>
        <h1 className="text-3xl font-bold">저장한 감정 세션</h1>
      </header>
      <section className="rounded-lg border border-dashed border-slate-300 bg-white p-6 text-[#46564E]">
        아직 저장된 기록이 없어요.
      </section>
    </main>
  );
}
