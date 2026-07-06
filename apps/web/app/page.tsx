"use client";

import Link from "next/link";
import { Keyboard, Mic, Pause, ShieldCheck, TimerReset } from "lucide-react";
import { updateFlowState } from "@/lib/session/flow-store";
import type { SelectedEmotion } from "@/types/emotion";

const quickEmotions: Array<{ label: string; value: SelectedEmotion }> = [
  { label: "화가 나요", value: "anger" },
  { label: "불안해요", value: "anxiety" },
  { label: "서운해요", value: "hurt" },
  { label: "억울해요", value: "injustice" },
  { label: "말하기 전에 정리하고 싶어요", value: "pause" },
  { label: "잠깐 진정하고 싶어요", value: "pause" },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-4xl flex-col px-5 py-5 sm:px-8 sm:py-8">
      <div className="flex flex-1 flex-col justify-center gap-7">
        <section className="space-y-5 rounded-lg border border-slate-200 bg-white px-5 py-6 shadow-sm sm:px-8 sm:py-8">
          <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
            <TimerReset className="h-5 w-5" aria-hidden="true" />
            보내기 전 60초
          </div>
          <h1 className="text-4xl font-black leading-tight tracking-normal text-slate-950 sm:text-6xl">
            보내기 전에
            <br />
            60초만 멈춰요.
          </h1>
          <p className="max-w-2xl text-xl font-medium leading-8 text-[#46564E]">
            화가 치밀거나 말이 세게 나올 것 같을 때, 먼저 멈추고 차분한 문장으로 바꿔볼게요.
          </p>
          <div className="flex items-center gap-2 rounded-lg bg-[#EEF4EB] px-4 py-3 text-sm font-semibold text-[#46564E]">
            <ShieldCheck className="h-5 w-5 shrink-0" aria-hidden="true" />
            상담이나 진단이 아니라, 지금 반응을 늦추는 도구예요.
          </div>
        </section>

        <section className="grid gap-3 sm:grid-cols-2">
          <Link
            href="/voice"
            className="flex min-h-20 items-center justify-center gap-3 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white shadow-sm transition hover:bg-[#1E2A24]"
          >
            <Mic className="h-6 w-6" aria-hidden="true" />
            말로 털어놓기
          </Link>
          <Link
            href="/input"
            className="flex min-h-20 items-center justify-center gap-3 rounded-lg border-2 border-slate-300 bg-white px-5 text-xl font-bold text-slate-950 shadow-sm transition hover:border-[#25342D]"
          >
            <Keyboard className="h-6 w-6" aria-hidden="true" />
            글로 적기
          </Link>
        </section>

        <section className="space-y-3">
          <div className="flex items-center gap-2 text-base font-bold text-slate-800">
            <Pause className="h-5 w-5 text-[#C56F5C]" aria-hidden="true" />
            지금 상태에 가까운 것
          </div>
          <div className="grid gap-2 sm:grid-cols-3">
            {quickEmotions.map(
              (emotion) => (
                <Link
                  key={emotion.label}
                  href="/start"
                  onClick={() => updateFlowState({ selectedEmotion: emotion.value })}
                  className="rounded-lg border border-slate-200 bg-white px-4 py-5 text-left text-base font-bold text-slate-900 shadow-sm transition hover:border-slate-400 hover:bg-slate-50"
                >
                  {emotion.label}
                </Link>
              ),
            )}
          </div>
        </section>
      </div>
    </main>
  );
}
