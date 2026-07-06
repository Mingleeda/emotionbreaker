export type ResourceType = "video" | "meditation" | "book" | "article" | "exercise";

export type ResourceRecommendation = {
  id: string;
  title: string;
  type: ResourceType;
  durationMinutes?: number;
  url?: string;
  description?: string;
  reason?: string;
  source?: string;
};
