import { NextResponse } from "next/server";
import { analyzeEmotionWithAi } from "@/lib/ai/coach";
import { createMockAnalysis } from "@/lib/session/flow-store";
import { detectRiskLevel } from "@/lib/safety/risk-detection";
import type { EmotionFlowState } from "@/types/session";

export async function POST(request: Request) {
  const body = (await request.json()) as Partial<EmotionFlowState>;
  const text = body.originalText ?? body.sttText ?? "";
  const riskLevel = detectRiskLevel(text);

  if (!text.trim()) {
    return NextResponse.json({ error: "originalText is required." }, { status: 400 });
  }

  const mockAnalysis = {
    ...createMockAnalysis({
      originalText: text,
      sttText: body.sttText,
      inputType: body.inputType,
      selectedEmotion: body.selectedEmotion,
      emotionScoreBefore: body.emotionScoreBefore,
      emotionScoreAfter: body.emotionScoreAfter,
    }),
    riskLevel,
  };

  // 위험 표현이 감지되면 일반 AI 코칭을 중단하고 로컬 결과만 반환한다.
  if (riskLevel === "crisis") {
    return NextResponse.json({ ...mockAnalysis, source: "local" });
  }

  const aiAnalysis = await analyzeEmotionWithAi(
    {
      originalText: text,
      sttText: body.sttText,
      selectedEmotion: body.selectedEmotion,
      emotionScoreBefore: body.emotionScoreBefore,
      emotionScoreAfter: body.emotionScoreAfter,
    },
    riskLevel,
  );

  if (aiAnalysis) {
    return NextResponse.json({ ...aiAnalysis, source: "ai" });
  }

  return NextResponse.json({ ...mockAnalysis, source: "local" });
}
