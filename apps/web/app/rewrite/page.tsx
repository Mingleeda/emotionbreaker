"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Check, Copy, MessageCircle, Quote, Video } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { createMockSuggestedMessages, getMessageSituation, loadFlowState, updateFlowState } from "@/lib/session/flow-store";
import type { SuggestedMessages } from "@/types/session";

const toneLabels = {
  soft: "부드럽게",
  firm: "단호하게",
  short: "짧게",
};

export default function RewritePage() {
  const [messages, setMessages] = useState<SuggestedMessages>();
  const [copiedTone, setCopiedTone] = useState<string>();

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      const state = loadFlowState();
      const nextMessages = createMockSuggestedMessages(state);
      updateFlowState({ rewrittenMessages: nextMessages });
      setMessages(nextMessages);
    }, 0);

    return () => window.clearTimeout(timeout);
  }, []);

  async function handleCopy(tone: string, text: string) {
    await navigator.clipboard.writeText(text);
    setCopiedTone(tone);
  }

  if (!messages) {
    return null;
  }

  const state = loadFlowState();
  const reflectedText = getMessageSituation(state);
  const messageEntries = [
    ["soft", messages.soft],
    ["firm", messages.firm],
    ["short", messages.short],
  ] as const;

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-5 px-5 py-6 pb-28">
      <StepNav backHref="/analysis" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <MessageCircle className="h-5 w-5" aria-hidden="true" />
          6단계 · 보낼 말
        </div>
        <h1 className="text-3xl font-black leading-tight">세게 나가지 않고, 분명하게 말해요.</h1>
        <p className="text-lg font-medium text-[#46564E]">방금 적은 상황을 반영해서 상대에게 보낼 말로 바꿨어요.</p>
      </header>
      {reflectedText ? (
        <section className="rounded-lg border border-slate-200 bg-white p-4 text-slate-900">
          <div className="flex items-center gap-2 text-sm font-black">
            <Quote className="h-5 w-5" aria-hidden="true" />
            반영한 상황
          </div>
          <p className="mt-2 text-base font-semibold leading-7">{reflectedText}</p>
        </section>
      ) : null}
      {messageEntries.map(([tone, text]) => (
        <section key={tone} className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <h2 className="text-xl font-black text-slate-950">{toneLabels[tone]}</h2>
          <p className="mt-3 text-lg font-medium leading-8 text-[#46564E]">{text}</p>
          <button
            type="button"
            onClick={() => handleCopy(tone, text)}
            className="mt-5 flex min-h-12 items-center justify-center gap-2 rounded-lg border-2 border-slate-300 px-4 py-2 font-bold"
          >
            {copiedTone === tone ? <Check className="h-5 w-5" aria-hidden="true" /> : <Copy className="h-5 w-5" aria-hidden="true" />}
            {copiedTone === tone ? "복사됨" : "복사하기"}
          </button>
        </section>
      ))}
      <div className="fixed inset-x-0 bottom-0 border-t border-slate-200 bg-[#FBF8F4]/95 px-5 py-4 backdrop-blur">
        <div className="mx-auto max-w-2xl">
          <Link href="/resources" className="flex min-h-16 items-center justify-center gap-2 rounded-lg border-2 border-slate-300 bg-white px-5 text-xl font-bold">
            <Video className="h-6 w-6" aria-hidden="true" />
            도움 자료는 원할 때만 보기
          </Link>
        </div>
      </div>
    </main>
  );
}
