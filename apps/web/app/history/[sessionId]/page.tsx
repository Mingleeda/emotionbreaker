type SessionDetailPageProps = {
  params: Promise<{
    sessionId: string;
  }>;
};

export default async function SessionDetailPage({ params }: SessionDetailPageProps) {
  const { sessionId } = await params;

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-6 px-6 py-10">
      <header className="space-y-3">
        <p className="text-sm font-semibold text-[#C56F5C]">기록 상세</p>
        <h1 className="text-3xl font-bold">감정 세션</h1>
      </header>
      <section className="rounded-lg border border-slate-200 bg-white p-5">
        <p className="text-sm text-slate-600">Session ID</p>
        <p className="mt-2 font-mono text-sm">{sessionId}</p>
      </section>
    </main>
  );
}
