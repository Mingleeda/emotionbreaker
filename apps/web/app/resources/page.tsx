"use client";

import { useState } from "react";
import { BookOpen, Check, HeartPulse, Video, Wind } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { getMockResources, updateFlowState } from "@/lib/session/flow-store";
import type { ResourceRecommendation, ResourceType } from "@/types/resource";

const resourceOptions: Array<{ label: string; value?: ResourceType; icon: typeof Video }> = [
  { label: "짧은 영상", value: "video", icon: Video },
  { label: "호흡/명상", value: "meditation", icon: Wind },
  { label: "책 추천", value: "book", icon: BookOpen },
  { label: "지금은 괜찮아요", icon: Check },
];

export default function ResourcesPage() {
  const [resources, setResources] = useState<ResourceRecommendation[]>([]);
  const [declined, setDeclined] = useState(false);

  function handleSelect(type?: ResourceType) {
    if (!type) {
      setDeclined(true);
      setResources([]);
      return;
    }

    updateFlowState({ requestedResourceType: type });
    setDeclined(false);
    setResources(getMockResources(type));
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-5 px-5 py-6">
      <StepNav backHref="/rewrite" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <HeartPulse className="h-5 w-5" aria-hidden="true" />
          선택 사항
        </div>
        <h1 className="text-3xl font-black leading-tight">도움 자료가 필요하면 고르세요.</h1>
        <p className="text-lg font-medium leading-7 text-[#46564E]">자동으로 보여주지 않아요. 지금 필요할 때만 열어볼게요.</p>
      </header>
      <div className="grid gap-3">
        {resourceOptions.map((option) => {
          const Icon = option.icon;

          return (
          <button
            key={option.label}
            type="button"
            onClick={() => handleSelect(option.value)}
            className="flex min-h-16 items-center gap-3 rounded-lg border-2 border-slate-200 bg-white px-5 text-left text-xl font-bold shadow-sm transition hover:border-slate-400"
          >
            <Icon className="h-6 w-6 text-[#C56F5C]" aria-hidden="true" />
            {option.label}
          </button>
          );
        })}
      </div>
      {declined ? <p className="rounded-lg border border-slate-200 bg-white p-5 text-lg font-medium text-[#46564E] shadow-sm">좋아요. 필요할 때 다시 요청해도 괜찮아요.</p> : null}
      {resources.map((resource) => (
        <article key={resource.id} className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <p className="text-sm font-bold uppercase text-[#C56F5C]">{resource.type}</p>
          <h2 className="mt-2 text-2xl font-black">{resource.title}</h2>
          {resource.durationMinutes ? <p className="mt-1 text-sm font-semibold text-slate-600">{resource.durationMinutes}분</p> : null}
          {resource.description ? <p className="mt-3 text-lg font-medium leading-8 text-[#46564E]">{resource.description}</p> : null}
          {resource.reason ? <p className="mt-3 rounded-lg bg-[#EEF4EB] p-3 text-sm font-semibold text-[#46564E]">{resource.reason}</p> : null}
        </article>
      ))}
    </main>
  );
}
