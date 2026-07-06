import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json(
    { error: "Session list API is not implemented yet." },
    { status: 501 },
  );
}

export async function POST() {
  return NextResponse.json(
    { error: "Session save API is not implemented yet." },
    { status: 501 },
  );
}
