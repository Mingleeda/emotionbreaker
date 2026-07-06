import Link from "next/link";

export function EmotionIntensityPicker() {
  return (
    <div className="grid grid-cols-4 gap-3 sm:grid-cols-6">
      {Array.from({ length: 11 }, (_, score) => (
        <Link
          href={score >= 4 ? "/break" : "/analysis"}
          key={score}
          className="flex aspect-square items-center justify-center rounded-lg border border-slate-200 bg-white text-2xl font-bold"
        >
          {score}
        </Link>
      ))}
    </div>
  );
}
