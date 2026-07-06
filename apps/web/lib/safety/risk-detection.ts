import type { RiskLevel } from "@/types/emotion";

const crisisPatterns = [
  "죽고 싶어",
  "사라지고 싶어",
  "나를 해치고 싶어",
  "끝내고 싶어",
  "죽여버리고 싶어",
  "때리고 싶어",
  "가서 해치고 싶어",
  "지금 뛰어내릴 거야",
  "칼을 들고 있어",
  "지금 찾아갈 거야",
];

export function detectRiskLevel(text: string): RiskLevel {
  const normalized = text.replace(/\s+/g, " ").trim();

  if (crisisPatterns.some((pattern) => normalized.includes(pattern))) {
    return "crisis";
  }

  return "normal";
}
