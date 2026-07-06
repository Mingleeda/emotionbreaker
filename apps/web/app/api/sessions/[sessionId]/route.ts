import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json(
    { error: "Session detail API is not implemented yet." },
    { status: 501 },
  );
}

export async function DELETE() {
  return NextResponse.json(
    { error: "Session delete API is not implemented yet." },
    { status: 501 },
  );
}
