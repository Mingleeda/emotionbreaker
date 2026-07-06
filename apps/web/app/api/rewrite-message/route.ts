import { NextResponse } from "next/server";
import { rewriteMessagesWithAi } from "@/lib/ai/coach";
import { createMockSuggestedMessages } from "@/lib/session/flow-store";
import { detectRiskLevel } from "@/lib/safety/risk-detection";
import type { EmotionAnalysisResult, SelectedEmotion } from "@/types/emotion";

type RewriteRequestBody = {
  originalMessage?: string;
  selectedEmotion?: SelectedEmotion;
  analysis?: Partial<EmotionAnalysisResult>;
};

export async function POST(request: Request) {
  const body = (await request.json()) as RewriteRequestBody;
  const originalMessage = body.originalMessage?.trim() ?? "";

  if (!originalMessage) {
    return NextResponse.json({ error: "originalMessage is required." }, { status: 400 });
  }

  const mockMessages = createMockSuggestedMessages({ originalText: originalMessage });

  // 위험 표현이 감지되면 일반 AI 코칭을 중단하고 로컬 결과만 반환한다.
  if (detectRiskLevel(originalMessage) === "crisis") {
    return NextResponse.json({ ...mockMessages, source: "local" });
  }

  const aiMessages = await rewriteMessagesWithAi({
    originalMessage,
    selectedEmotion: body.selectedEmotion,
    analysis: body.analysis,
  });

  if (aiMessages) {
    return NextResponse.json({ ...aiMessages, source: "ai" });
  }

  return NextResponse.json({ ...mockMessages, source: "local" });
}
