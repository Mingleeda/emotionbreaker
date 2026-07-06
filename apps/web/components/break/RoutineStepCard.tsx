type RoutineStepCardProps = {
  step: string;
};

export function RoutineStepCard({ step }: RoutineStepCardProps) {
  return <div className="rounded-lg border border-slate-200 bg-white p-4">{step}</div>;
}
