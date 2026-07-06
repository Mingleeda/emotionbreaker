import { responseTones } from "@/lib/constants/tones";

export function ToneSelector() {
  return (
    <div className="flex flex-wrap gap-2">
      {responseTones.map((tone) => (
        <button key={tone.value} className="rounded-lg border border-slate-300 bg-white px-4 py-2 font-semibold">
          {tone.label}
        </button>
      ))}
    </div>
  );
}
