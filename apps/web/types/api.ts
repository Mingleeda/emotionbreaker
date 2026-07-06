import type { EmotionAnalysisResult } from "./emotion";
import type { ResourceRecommendation } from "./resource";
import type { SuggestedMessages } from "./session";

export type AnalyzeEmotionResponse = EmotionAnalysisResult;

export type RewriteMessageResponse = SuggestedMessages;

export type TranscribeResponse = {
  text: string;
};

export type ResourcesResponse = {
  resources: ResourceRecommendation[];
};
