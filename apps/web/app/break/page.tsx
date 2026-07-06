"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Check, Footprints, Pause, Play, Wind } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";

const steps = [
  { icon: Footprints, text: "발바닥이 바닥에 닿는 느낌을 느껴보세요." },
  { icon: Pause, text: "어깨 힘을 한 번 빼주세요." },
  { icon: Wind, text: "코로 4초 들이마시고, 입으로 6초 내쉬어보세요." },
  { icon: Check, text: "지금 당장 반응하지 않아도 괜찮다고 말해보세요." },
];

export default function BreakPage() {
  const [remainingSeconds, setRemainingSeconds] = useState(60);
  const [running, setRunning] = useState(false);

  useEffect(() => {
    if (!running || remainingSeconds <= 0) {
      return;
    }

    const timer = window.setTimeout(() => {
      setRemainingSeconds((seconds) => seconds - 1);
    }, 1000);

    return () => window.clearTimeout(timer);
  }, [remainingSeconds, running]);

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-6 px-5 py-6 pb-28">
      <StepNav backHref="/intensity" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <Pause className="h-5 w-5" aria-hidden="true" />
          3단계 · 멈춤
        </div>
        <h1 className="text-3xl font-black leading-tight">지금은 답장 금지.</h1>
        <p className="text-lg font-medium leading-7 text-[#46564E]">60초만 몸을 먼저 낮춰요. 판단은 그 다음입니다.</p>
      </header>
      <section className="rounded-lg border-2 border-slate-200 bg-white p-6 text-center shadow-sm">
        <p className="text-sm font-bold text-slate-600">남은 시간</p>
        <p className="mt-1 text-7xl font-black text-slate-950">{remainingSeconds}</p>
        <p className="mt-2 text-sm font-semibold text-slate-600">{running ? "천천히. 지금은 멈추는 중이에요." : "시작 버튼을 누르면 타이머가 내려갑니다."}</p>
      </section>
      <ol className="grid gap-3">
        {steps.map((step, index) => {
          const Icon = step.icon;

          return (
          <li key={step.text} className="flex gap-3 rounded-lg border border-slate-200 bg-white p-4 text-lg font-semibold shadow-sm">
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-[#ffe1dc] text-[#991b1b]">
              <Icon className="h-5 w-5" aria-hidden="true" />
            </span>
            <span>
              <span className="mr-2 text-sm font-black text-[#C56F5C]">{index + 1}</span>
              {step.text}
            </span>
          </li>
          );
        })}
      </ol>
      <div className="fixed inset-x-0 bottom-0 border-t border-slate-200 bg-[#FBF8F4]/95 px-5 py-4 backdrop-blur">
        <div className="mx-auto grid max-w-2xl gap-3 sm:grid-cols-2">
          <button
            type="button"
            onClick={() => setRunning(true)}
            className="flex min-h-16 items-center justify-center gap-2 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white shadow-sm"
          >
            <Play className="h-6 w-6" aria-hidden="true" />
            60초 시작
          </button>
          <Link href="/reassess" className="flex min-h-16 items-center justify-center rounded-lg border-2 border-slate-300 bg-white px-5 text-xl font-bold">
            다 했어요
          </Link>
        </div>
      </div>
    </main>
  );
}
