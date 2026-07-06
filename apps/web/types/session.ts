import type { EmotionAnalysisResult, InputType, SelectedEmotion } from "./emotion";
import type { ResourceType } from "./resource";

export type SuggestedMessages = {
  soft: string;
  firm: string;
  short: string;
  polite?: string;
  warm?: string;
  work?: string;
  family?: string;
};

export type EmotionFlowState = {
  inputType?: InputType;
  selectedEmotion?: SelectedEmotion;
  originalText: string;
  sttText?: string;
  emotionScoreBefore?: number;
  emotionScoreAfter?: number;
  analysis?: EmotionAnalysisResult;
  rewrittenMessages?: SuggestedMessages;
  requestedResourceType?: ResourceType;
};
