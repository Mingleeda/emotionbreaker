import OpenAI from "openai";

export function getOpenAiApiKey() {
  return process.env.OPENAI_API_KEY;
}

export function createOpenAiClient() {
  const apiKey = getOpenAiApiKey();

  if (!apiKey) {
    return null;
  }

  return new OpenAI({ apiKey });
}
