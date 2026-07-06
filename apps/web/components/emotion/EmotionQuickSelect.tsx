import Link from "next/link";
import { quickEmotions } from "@/lib/constants/emotions";

export function EmotionQuickSelect() {
  return (
    <div className="grid gap-2 sm:grid-cols-2">
      {quickEmotions.map((emotion) => (
        <Link
          key={emotion.value}
          href="/input"
          className="rounded-lg border border-slate-200 bg-white px-4 py-4 font-medium text-slate-800"
        >
          {emotion.label}
        </Link>
      ))}
    </div>
  );
}
