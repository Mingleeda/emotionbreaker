import { resourceTypes } from "@/lib/constants/resources";

export function ResourceTypePicker() {
  return (
    <div className="grid gap-3">
      {resourceTypes.map((resourceType) => (
        <button key={resourceType.value} className="min-h-14 rounded-lg border border-slate-200 bg-white px-5 text-left text-lg font-semibold">
          {resourceType.label}
        </button>
      ))}
    </div>
  );
}
