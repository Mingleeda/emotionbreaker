import { NextResponse } from "next/server";

export async function POST() {
  return NextResponse.json(
    { error: "Session resource log API is not implemented yet." },
    { status: 501 },
  );
}
