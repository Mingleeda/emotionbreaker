import { NextResponse } from "next/server";
import { getMockResources } from "@/lib/session/flow-store";
import type { ResourceType } from "@/types/resource";

const supportedResourceTypes: ResourceType[] = ["video", "meditation", "book", "article", "exercise"];

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const type = searchParams.get("type");

  if (!type || !supportedResourceTypes.includes(type as ResourceType)) {
    return NextResponse.json({ error: "A supported resource type is required." }, { status: 400 });
  }

  return NextResponse.json({ resources: getMockResources(type as ResourceType) });
}
