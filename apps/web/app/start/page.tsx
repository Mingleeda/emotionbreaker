"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Keyboard, Mic, RotateCcw } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { loadFlowState, updateFlowState } from "@/lib/session/flow-store";
import type { SelectedEmotion } from "@/types/emotion";

const emotions: Array<{ label: string; value: SelectedEmotion }> = [
  { label: "화가 나요", value: "anger" },
  { label: "불안해요", value: "anxiety" },
  { label: "서운해요", value: "hurt" },
  { label: "억울해요", value: "injustice" },
  { label: "말하기 전에 정리하고 싶어요", value: "pause" },
  { label: "잠깐 진정하고 싶어요", value: "pause" },
];

const emotionLabelByValue: Record<SelectedEmotion, string> = {
  anger: "화가 나요",
  anxiety: "불안해요",
  hurt: "서운해요",
  injustice: "억울해요",
  pause: "잠깐 멈추고 싶어요",
};

export default function StartPage() {
  const [selectedEmotion, setSelectedEmotion] = useState<SelectedEmotion>();

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      setSelectedEmotion(loadFlowState().selectedEmotion);
    }, 0);

    return () => window.clearTimeout(timeout);
  }, []);

  function handleSelectEmotion(emotion: SelectedEmotion) {
    updateFlowState({ selectedEmotion: emotion });
    setSelectedEmotion(emotion);
  }

  if (selectedEmotion) {
    return (
      <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col justify-center gap-6 px-5 py-6">
        <StepNav backHref="/" backLabel="홈" />
        <header className="space-y-3 rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <p className="text-sm font-bold text-[#C56F5C]">지금 상태</p>
          <h1 className="text-4xl font-black leading-tight">{emotionLabelByValue[selectedEmotion]}</h1>
          <p className="text-lg font-medium leading-7 text-[#46564E]">
            어떻게 털어놓을까요? 말로 해도 되고, 글로 적어도 괜찮아요.
          </p>
        </header>

        <section className="grid gap-3">
          <Link
            href="/voice"
            className="flex min-h-20 items-center justify-center gap-3 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white shadow-sm"
          >
            <Mic className="h-6 w-6" aria-hidden="true" />
            말로 털어놓기
          </Link>
          <Link
            href="/input"
            className="flex min-h-20 items-center justify-center gap-3 rounded-lg border-2 border-slate-300 bg-white px-5 text-xl font-bold text-slate-950 shadow-sm"
          >
            <Keyboard className="h-6 w-6" aria-hidden="true" />
            글로 적기
          </Link>
        </section>

        <button
          type="button"
          onClick={() => {
            updateFlowState({ selectedEmotion: undefined });
            setSelectedEmotion(undefined);
          }}
          className="flex min-h-14 items-center justify-center gap-2 rounded-lg px-5 text-base font-bold text-[#46564E]"
        >
          <RotateCcw className="h-5 w-5" aria-hidden="true" />
          감정 다시 고르기
        </button>
      </main>
    );
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-6 px-5 py-6">
      <StepNav backHref="/" backLabel="홈" />
      <header className="space-y-3">
        <p className="text-sm font-bold text-[#C56F5C]">시작하기</p>
        <h1 className="text-3xl font-black leading-tight">지금 마음에 가까운 걸 골라주세요.</h1>
        <p className="text-lg font-medium text-[#46564E]">고른 다음, 말로 할지 글로 쓸지 선택할 수 있어요.</p>
      </header>
      <div className="grid gap-3">
        {emotions.map((emotion) => (
          <button
            type="button"
            key={emotion.label}
            onClick={() => handleSelectEmotion(emotion.value)}
            className="min-h-16 rounded-lg border-2 border-slate-200 bg-white px-5 py-4 text-left text-lg font-bold text-slate-900 shadow-sm transition hover:border-slate-400"
          >
            {emotion.label}
          </button>
        ))}
      </div>
    </main>
  );
}
