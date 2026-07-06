"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { RotateCcw } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { loadFlowState, updateFlowState } from "@/lib/session/flow-store";

export default function ReassessPage() {
  const router = useRouter();
  const [beforeScore, setBeforeScore] = useState<number | undefined>();

  function getScoreClass(score: number) {
    if (score >= 7) {
      return "border-[#F1C4B2] bg-[#FFF1EA] text-[#994838] hover:border-[#D88973]";
    }

    if (score >= 4) {
      return "border-slate-300 bg-white text-slate-900 hover:border-slate-500";
    }

    return "border-slate-200 bg-white text-[#46564E] hover:border-slate-400";
  }

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      setBeforeScore(loadFlowState().emotionScoreBefore);
    }, 0);

    return () => window.clearTimeout(timeout);
  }, []);

  function handleSelectScore(score: number) {
    updateFlowState({ emotionScoreAfter: score });
    router.push("/analysis");
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-7 px-5 py-6">
      <StepNav backHref="/break" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <RotateCcw className="h-5 w-5" aria-hidden="true" />
          4단계 · 다시 확인
        </div>
        <h1 className="text-3xl font-black leading-tight">조금 내려왔나요?</h1>
        <p className="text-lg font-medium leading-7 text-[#46564E]">
          처음 감정 점수는 {beforeScore ?? "-"}점이었어요. 지금은 몇 점인가요?
        </p>
      </header>
      <div className="grid grid-cols-3 gap-3 sm:grid-cols-6">
        {Array.from({ length: 11 }, (_, score) => (
          <button
            type="button"
            onClick={() => handleSelectScore(score)}
            key={score}
            className={`flex aspect-square min-h-20 items-center justify-center rounded-lg border-2 text-3xl font-black shadow-sm transition ${getScoreClass(score)}`}
          >
            {score}
          </button>
        ))}
      </div>
    </main>
  );
}
