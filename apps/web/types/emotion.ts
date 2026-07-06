export type InputType = "text" | "voice";

export type SelectedEmotion = "anger" | "anxiety" | "hurt" | "injustice" | "pause";

export type RiskLevel = "normal" | "caution" | "crisis";

export type EmotionAnalysisResult = {
  riskLevel: RiskLevel;
  primaryEmotion: string;
  secondaryEmotions: string[];
  fact: string;
  interpretation: string;
  desire: string;
  notRecommendedAction: string;
  recommendedAction: string;
  situationSummary: string;
};
