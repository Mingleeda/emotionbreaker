import { NextResponse } from "next/server";
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

  const analysis = {
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

  return NextResponse.json(analysis);
}
