import { NextResponse } from "next/server";
import { createOpenAiClient } from "@/lib/openai/client";

export const runtime = "nodejs";

const maxAudioSizeBytes = 25 * 1024 * 1024;

export async function POST(request: Request) {
  let formData: FormData;

  try {
    formData = await request.formData();
  } catch {
    return NextResponse.json({ error: "Audio file is required." }, { status: 400 });
  }

  const file = formData.get("file");

  if (!(file instanceof File)) {
    return NextResponse.json({ error: "Audio file is required." }, { status: 400 });
  }

  if (file.size > maxAudioSizeBytes) {
    return NextResponse.json({ error: "Audio file is too large." }, { status: 413 });
  }

  const openai = createOpenAiClient();

  if (!openai) {
    return NextResponse.json(
      { error: "OPENAI_API_KEY is not configured." },
      { status: 500 },
    );
  }

  try {
    const transcription = await openai.audio.transcriptions.create({
      file,
      model: "gpt-4o-transcribe",
      response_format: "json",
      language: "ko",
    });

    return NextResponse.json({ text: transcription.text });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Transcription failed.";

    return NextResponse.json({ error: message }, { status: 500 });
  }
}
