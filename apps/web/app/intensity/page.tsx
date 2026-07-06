"use client";

import { useRouter } from "next/navigation";
import { Activity, AlertTriangle } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { getNextRouteByEmotionScore, loadFlowState, updateFlowState } from "@/lib/session/flow-store";

export default function IntensityPage() {
  const router = useRouter();
  const previousInputRoute = loadFlowState().inputType === "voice" ? "/voice" : "/input";

  function getScoreClass(score: number) {
    if (score >= 7) {
      return "border-[#F1C4B2] bg-[#FFF1EA] text-[#994838] hover:border-[#D88973]";
    }

    if (score >= 4) {
      return "border-slate-300 bg-white text-slate-900 hover:border-slate-500";
    }

    return "border-slate-200 bg-white text-[#46564E] hover:border-slate-400";
  }

  function handleSelectScore(score: number) {
    updateFlowState({ emotionScoreBefore: score, emotionScoreAfter: undefined });
    router.push(getNextRouteByEmotionScore(score));
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-7 px-5 py-6">
      <StepNav backHref={previousInputRoute} />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <Activity className="h-5 w-5" aria-hidden="true" />
          2단계 · 감정 세기
        </div>
        <h1 className="text-3xl font-black leading-tight">지금 몇 점인가요?</h1>
        <p className="text-lg font-medium text-[#46564E]">생각하지 말고, 몸으로 느껴지는 숫자를 눌러주세요.</p>
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
      <div className="space-y-3 rounded-lg border border-slate-200 bg-white p-5 text-slate-800 shadow-sm">
        <div className="flex gap-2">
          <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-[#C56F5C]" aria-hidden="true" />
          <p className="font-bold">7점 이상이면 먼저 60초만 멈춥니다.</p>
        </div>
        <p className="text-sm font-medium text-slate-600">0 = 괜찮음 · 10 = 바로 폭발할 것 같음</p>
      </div>
    </main>
  );
}
