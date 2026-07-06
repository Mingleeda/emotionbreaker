import OpenAI from "openai";

const OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1";
const DEFAULT_MODEL = "google/gemini-2.5-flash";

export function getOpenRouterModel() {
  return process.env.OPENROUTER_MODEL || DEFAULT_MODEL;
}

export function createOpenRouterClient() {
  const apiKey = process.env.OPENROUTER_API_KEY;

  if (!apiKey) {
    return null;
  }

  return new OpenAI({
    apiKey,
    baseURL: OPENROUTER_BASE_URL,
    timeout: 12_000,
    maxRetries: 1,
    defaultHeaders: {
      "HTTP-Referer": "https://emotionbreaker.app",
      "X-Title": "Emotion Breaker (60s before send)",
    },
  });
}
