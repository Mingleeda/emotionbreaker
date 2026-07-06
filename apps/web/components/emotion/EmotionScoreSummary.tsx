type EmotionScoreSummaryProps = {
  before?: number;
  after?: number;
};

export function EmotionScoreSummary({ before, after }: EmotionScoreSummaryProps) {
  return (
    <p className="text-[#46564E]">
      처음 점수 {before ?? "-"}점, 현재 점수 {after ?? "-"}점
    </p>
  );
}
