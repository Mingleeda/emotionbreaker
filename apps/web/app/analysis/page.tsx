"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArrowRight, Ban, Brain, Heart, ListChecks, MessageCircle, Target } from "lucide-react";
import { RiskNotice } from "@/components/emotion/RiskNotice";
import { StepNav } from "@/components/layout/StepNav";
import { createMockAnalysis, loadFlowState, updateFlowState } from "@/lib/session/flow-store";
import { detectRiskLevel } from "@/lib/safety/risk-detection";
import type { EmotionAnalysisResult } from "@/types/emotion";

export default function AnalysisPage() {
  const [analysis, setAnalysis] = useState<EmotionAnalysisResult>();
  const [scoreSummary, setScoreSummary] = useState("");

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      const state = loadFlowState();
      const nextAnalysis = state.analysis ?? createMockAnalysis(state);
      const riskLevel = detectRiskLevel(state.originalText || state.sttText || "");
      const analysisWithRisk = { ...nextAnalysis, riskLevel };

      updateFlowState({ analysis: analysisWithRisk });
      setAnalysis(analysisWithRisk);

      if (typeof state.emotionScoreBefore === "number" && typeof state.emotionScoreAfter === "number") {
        setScoreSummary(`${state.emotionScoreBefore}점에서 ${state.emotionScoreAfter}점으로 확인했어요.`);
      }
    }, 0);

    return () => window.clearTimeout(timeout);
  }, []);

  if (!analysis) {
    return null;
  }

  if (analysis.riskLevel === "crisis") {
    return (
      <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-6 px-6 py-10">
        <StepNav backHref="/reassess" />
        <header className="space-y-3">
          <p className="text-sm font-semibold text-[#B85F4D]">도움이 먼저 필요해요</p>
          <h1 className="text-3xl font-bold">지금은 혼자 버티지 않는 게 중요해요.</h1>
        </header>
        <RiskNotice />
      </main>
    );
  }

  const sections = [
    { title: "감정", body: [analysis.primaryEmotion, ...analysis.secondaryEmotions].join(", "), icon: Heart },
    { title: "사실", body: analysis.fact, icon: ListChecks },
    { title: "내 해석", body: analysis.interpretation, icon: Brain },
    { title: "진짜 욕구", body: analysis.desire, icon: Target },
    { title: "지금 하지 않을 것", body: analysis.notRecommendedAction, icon: Ban },
    { title: "지금 할 수 있는 것", body: analysis.recommendedAction, icon: MessageCircle },
  ];

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-5 px-5 py-6 pb-28">
      <StepNav backHref="/reassess" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <Brain className="h-5 w-5" aria-hidden="true" />
          5단계 · 마음 정리
        </div>
        <h1 className="text-3xl font-black leading-tight">바로 보내기 전에, 이렇게 나눠볼게요.</h1>
        {scoreSummary ? <p className="text-lg font-medium text-[#46564E]">{scoreSummary}</p> : null}
      </header>
      <section className="rounded-lg border-2 border-[#25342D] bg-[#25342D] p-5 text-white shadow-sm">
        <h2 className="text-xl font-black">먼저 할 일</h2>
        <p className="mt-2 text-lg font-medium leading-7 text-slate-100">{analysis.recommendedAction}</p>
      </section>
      {sections.map((section) => {
        const Icon = section.icon;

        return (
        <section key={section.title} className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center gap-2">
            <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-[#EEF4EB] text-slate-600">
              <Icon className="h-5 w-5" aria-hidden="true" />
            </span>
            <h2 className="font-black text-slate-950">{section.title}</h2>
          </div>
          <p className="mt-3 text-lg font-medium leading-8 text-[#46564E]">{section.body}</p>
        </section>
        );
      })}
      <div className="fixed inset-x-0 bottom-0 border-t border-slate-200 bg-[#FBF8F4]/95 px-5 py-4 backdrop-blur">
        <div className="mx-auto grid max-w-2xl gap-3 sm:grid-cols-[1fr_auto]">
          <Link href="/rewrite" className="flex min-h-16 items-center justify-center gap-2 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white shadow-sm">
            보낼 말 추천받기
            <ArrowRight className="h-6 w-6" aria-hidden="true" />
          </Link>
          <Link href="/resources" className="flex min-h-16 items-center justify-center rounded-lg border-2 border-slate-300 bg-white px-5 text-lg font-bold">
            자료
          </Link>
        </div>
      </div>
    </main>
  );
}
