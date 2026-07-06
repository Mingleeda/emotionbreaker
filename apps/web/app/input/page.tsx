"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, MessageSquareText } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { loadFlowState, updateFlowState } from "@/lib/session/flow-store";

export default function InputPage() {
  const router = useRouter();
  const [text, setText] = useState("");

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      const state = loadFlowState();
      setText(state.originalText);
    }, 0);

    return () => window.clearTimeout(timeout);
  }, []);

  function handleNext() {
    if (!text.trim()) {
      return;
    }

    updateFlowState({
      inputType: "text",
      originalText: text.trim(),
      sttText: undefined,
    });
    router.push("/intensity");
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-5 px-5 py-6 pb-28">
      <StepNav backHref="/start" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <MessageSquareText className="h-5 w-5" aria-hidden="true" />
          1단계 · 털어놓기
        </div>
        <h1 className="text-3xl font-black leading-tight">있는 그대로 적어주세요.</h1>
        <p className="text-lg font-medium leading-7 text-[#46564E]">
          욕처럼 나와도 괜찮아요. 보내기 전에 차분한 말로 바꿔볼게요.
        </p>
      </header>
      <textarea
        value={text}
        onChange={(event) => setText(event.target.value)}
        className="min-h-[320px] rounded-lg border-2 border-slate-300 bg-white p-5 text-xl font-medium leading-8 shadow-sm outline-none placeholder:text-slate-400 focus:border-slate-400"
        placeholder="예: 상사가 회의 중에 내 말을 끊어서 너무 화가 나. 바로 따지고 싶어."
      />
      <div className="fixed inset-x-0 bottom-0 border-t border-slate-200 bg-[#FBF8F4]/95 px-5 py-4 backdrop-blur">
        <div className="mx-auto max-w-2xl">
          <button
            type="button"
            onClick={handleNext}
            disabled={!text.trim()}
            className="flex min-h-16 w-full items-center justify-center gap-2 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white shadow-sm disabled:cursor-not-allowed disabled:bg-slate-300"
          >
            감정 점수 고르기
            <ArrowRight className="h-6 w-6" aria-hidden="true" />
          </button>
        </div>
      </div>
    </main>
  );
}
