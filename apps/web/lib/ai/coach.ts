import { createOpenRouterClient, getOpenRouterModel } from "@/lib/ai/openrouter";
import type { EmotionAnalysisResult, RiskLevel } from "@/types/emotion";
import type { EmotionFlowState, SuggestedMessages } from "@/types/session";

const SYSTEM_PROMPT = `너는 "보내기 전 60초"라는 감정 브레이크 서비스의 코치다.
사용자는 화, 불안, 서운함, 억울함 같은 감정이 격해진 상태에서 정리되지 않은 말을 털어놓는다.
규칙:
- 사용자를 판단하거나 훈계하지 않는다.
- 문장은 짧고 명확한 한국어 존댓말("~해요"체)로 쓴다.
- 상담이나 진단이 아니라, 지금 반응을 늦추는 것이 목적이다.
- 반드시 요청된 JSON 형식으로만 답한다. JSON 외의 텍스트를 출력하지 않는다.`;

const EMOTION_LABELS: Record<string, string> = {
  anger: "화남",
  anxiety: "불안",
  hurt: "서운함",
  injustice: "억울함",
  pause: "정리하고 싶은 마음",
};

function extractJson(text: string): Record<string, unknown> | null {
  const match = text.match(/\{[\s\S]*\}/);

  if (!match) {
    return null;
  }

  try {
    return JSON.parse(match[0]) as Record<string, unknown>;
  } catch (error) {
    console.error("[ai/coach] OpenRouter 호출 실패:", error);
    return null;
  }
}

function asTrimmedString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

export async function analyzeEmotionWithAi(
  state: Partial<EmotionFlowState>,
  riskLevel: RiskLevel,
): Promise<EmotionAnalysisResult | null> {
  const client = createOpenRouterClient();
  const text = (state.originalText ?? state.sttText ?? "").trim();

  if (!client || !text) {
    return null;
  }

  const emotionLabel = state.selectedEmotion ? EMOTION_LABELS[state.selectedEmotion] : null;
  const scoreLine =
    state.emotionScoreBefore != null
      ? `감정 점수(0~10): 처음 ${state.emotionScoreBefore}점${state.emotionScoreAfter != null ? `, 60초 멈춤 후 ${state.emotionScoreAfter}점` : ""}`
      : null;

  const userPrompt = [
    `사용자가 털어놓은 말: """${text}"""`,
    emotionLabel ? `사용자가 고른 감정: ${emotionLabel}` : null,
    scoreLine,
    "",
    "위 내용을 사실/해석/감정/욕구로 분리해서 아래 JSON 형식으로만 답해줘.",
    `{
  "primaryEmotion": "핵심 감정 한 단어",
  "secondaryEmotions": ["부수 감정 1~3개"],
  "fact": "실제로 일어난 일만 한 문장으로 (해석·평가 없이)",
  "interpretation": "사용자가 그 일을 어떻게 해석했는지 한 문장",
  "desire": "그 감정 아래에 있는 진짜 바람 한 문장",
  "notRecommendedAction": "지금 하면 후회할 행동 한 문장",
  "recommendedAction": "지금 하면 좋은 행동 한 문장",
  "situationSummary": "상황 전체 요약 한 문장"
}`,
  ]
    .filter((line) => line != null)
    .join("\n");

  try {
    const completion = await client.chat.completions.create({
      model: getOpenRouterModel(),
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
      max_tokens: 700,
      temperature: 0.4,
    });

    const parsed = extractJson(completion.choices[0]?.message?.content ?? "");

    if (!parsed) {
      return null;
    }

    const primaryEmotion = asTrimmedString(parsed.primaryEmotion);
    const fact = asTrimmedString(parsed.fact);
    const interpretation = asTrimmedString(parsed.interpretation);
    const desire = asTrimmedString(parsed.desire);
    const notRecommendedAction = asTrimmedString(parsed.notRecommendedAction);
    const recommendedAction = asTrimmedString(parsed.recommendedAction);
    const situationSummary = asTrimmedString(parsed.situationSummary);

    if (
      !primaryEmotion ||
      !fact ||
      !interpretation ||
      !desire ||
      !notRecommendedAction ||
      !recommendedAction ||
      !situationSummary
    ) {
      return null;
    }

    const secondaryEmotions = Array.isArray(parsed.secondaryEmotions)
      ? parsed.secondaryEmotions.filter((item): item is string => typeof item === "string" && !!item.trim()).slice(0, 3)
      : [];

    return {
      riskLevel,
      primaryEmotion,
      secondaryEmotions,
      fact,
      interpretation,
      desire,
      notRecommendedAction,
      recommendedAction,
      situationSummary,
    };
  } catch (error) {
    console.error("[ai/coach] OpenRouter 호출 실패:", error);
    return null;
  }
}

export async function rewriteMessagesWithAi(input: {
  originalMessage: string;
  selectedEmotion?: string;
  analysis?: Partial<EmotionAnalysisResult>;
}): Promise<SuggestedMessages | null> {
  const client = createOpenRouterClient();
  const text = input.originalMessage.trim();

  if (!client || !text) {
    return null;
  }

  const emotionLabel = input.selectedEmotion ? EMOTION_LABELS[input.selectedEmotion] : null;

  const userPrompt = [
    `사용자가 감정이 격해진 상태로 쓴 말: """${text}"""`,
    emotionLabel ? `사용자가 고른 감정: ${emotionLabel}` : null,
    input.analysis?.fact ? `정리된 사실: ${input.analysis.fact}` : null,
    input.analysis?.desire ? `진짜 바람: ${input.analysis.desire}` : null,
    "",
    "이 내용을 상대에게 실제로 보낼 수 있는 문장으로 바꿔줘.",
    "공격적이지 않으면서 내 감정과 요청이 분명히 전달되어야 해.",
    "아래 JSON 형식으로만 답해줘.",
    `{
  "soft": "부드러운 톤의 보낼 문장 (2~3문장)",
  "firm": "단호하지만 공격적이지 않은 톤의 보낼 문장 (2~3문장)",
  "short": "짧고 담백한 톤의 보낼 문장 (1~2문장)"
}`,
  ]
    .filter((line) => line != null)
    .join("\n");

  try {
    const completion = await client.chat.completions.create({
      model: getOpenRouterModel(),
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
      max_tokens: 600,
      temperature: 0.5,
    });

    const parsed = extractJson(completion.choices[0]?.message?.content ?? "");

    if (!parsed) {
      return null;
    }

    const soft = asTrimmedString(parsed.soft);
    const firm = asTrimmedString(parsed.firm);
    const short = asTrimmedString(parsed.short);

    if (!soft || !firm || !short) {
      return null;
    }

    return { soft, firm, short };
  } catch (error) {
    console.error("[ai/coach] OpenRouter 호출 실패:", error);
    return null;
  }
}
