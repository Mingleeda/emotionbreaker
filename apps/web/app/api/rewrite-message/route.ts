import { NextResponse } from "next/server";
import { createMockSuggestedMessages } from "@/lib/session/flow-store";

export async function POST(request: Request) {
  const body = (await request.json()) as { originalMessage?: string };

  if (!body.originalMessage?.trim()) {
    return NextResponse.json({ error: "originalMessage is required." }, { status: 400 });
  }

  return NextResponse.json(createMockSuggestedMessages({ originalText: body.originalMessage }));
}
