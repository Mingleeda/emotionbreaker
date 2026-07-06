"use client";

import { ArrowLeft, Home } from "lucide-react";
import { useRouter } from "next/navigation";
import { resetFlowState } from "@/lib/session/flow-store";

type StepNavProps = {
  backHref?: string;
  backLabel?: string;
  showHome?: boolean;
};

export function StepNav({ backHref, backLabel = "이전", showHome = true }: StepNavProps) {
  const router = useRouter();

  function handleBack() {
    if (backHref) {
      router.push(backHref);
      return;
    }

    router.back();
  }

  function handleHome() {
    resetFlowState();
    router.push("/");
  }

  return (
    <nav className="flex items-center justify-between gap-3" aria-label="단계 이동">
      <button
        type="button"
        onClick={handleBack}
        className="flex min-h-11 items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 text-sm font-black text-slate-800 shadow-sm"
      >
        <ArrowLeft className="h-5 w-5" aria-hidden="true" />
        {backLabel}
      </button>
      {showHome ? (
        <button
          type="button"
          onClick={handleHome}
          className="flex min-h-11 items-center gap-2 rounded-lg px-3 text-sm font-black text-slate-600"
        >
          <Home className="h-5 w-5" aria-hidden="true" />
          처음
        </button>
      ) : null}
    </nav>
  );
}
