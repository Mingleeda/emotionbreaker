import type { EmotionFlowState } from "@/types/session";
import type { EmotionAnalysisResult } from "@/types/emotion";
import type { ResourceRecommendation, ResourceType } from "@/types/resource";

export const initialFlowState: EmotionFlowState = {
  originalText: "",
};

export const flowStorageKey = "emotionbreaker.flow";

export function loadFlowState(): EmotionFlowState {
  if (typeof window === "undefined") {
    return initialFlowState;
  }

  const rawState = window.localStorage.getItem(flowStorageKey);

  if (!rawState) {
    return initialFlowState;
  }

  try {
    return { ...initialFlowState, ...JSON.parse(rawState) };
  } catch {
    return initialFlowState;
  }
}

export function saveFlowState(nextState: EmotionFlowState) {
  window.localStorage.setItem(flowStorageKey, JSON.stringify(nextState));
}

export function updateFlowState(patch: Partial<EmotionFlowState>) {
  const nextState = { ...loadFlowState(), ...patch };
  saveFlowState(nextState);
  return nextState;
}

export function resetFlowState() {
  window.localStorage.removeItem(flowStorageKey);
}

export function getNextRouteByEmotionScore(score: number) {
  if (score >= 4) {
    return "/break";
  }

  return "/analysis";
}

export function createMockAnalysis(state: EmotionFlowState): EmotionAnalysisResult {
  const selectedEmotion = state.selectedEmotion ?? "anger";

  const emotionLabelByValue = {
    anger: "화남",
    anxiety: "불안",
    hurt: "서운함",
    injustice: "억울함",
    pause: "정리하고 싶은 마음",
  };

  return {
    riskLevel: "normal",
    primaryEmotion: emotionLabelByValue[selectedEmotion],
    secondaryEmotions: ["긴장", "답답함"],
    fact: getMessageSituation({ ...state, analysis: undefined }),
    interpretation: "상대가 내 마음이나 입장을 충분히 알아주지 않는다고 느낀 것 같아요.",
    desire: "내 말을 끝까지 듣고, 내 입장을 존중해주길 바라는 마음이 있어 보여요.",
    notRecommendedAction: "감정이 가장 높은 상태에서 바로 따지듯 메시지를 보내기.",
    recommendedAction: "한 문장으로 내 감정과 요청을 분리해서 전달하기.",
    situationSummary: "감정이 올라온 상황에서 바로 반응하기 전 잠시 멈추고 정리하려는 상태.",
  };
}

function normalizeContextText(text: string) {
  return text.replace(/\s+/g, " ").trim();
}

function inferRelationship(text: string) {
  if (/(상사|파트장|팀장|부장|회사|회의|업무|직장|동료|고객|클라이언트|출장|출근)/.test(text)) {
    return "work";
  }

  if (/(엄마|아빠|부모|가족|형|누나|언니|오빠|동생)/.test(text)) {
    return "family";
  }

  if (/(남자친구|여자친구|연인|애인|남친|여친|배우자|남편|아내)/.test(text)) {
    return "partner";
  }

  if (/(친구|지인|선배|후배)/.test(text)) {
    return "friend";
  }

  return "default";
}

function makeSituationPhrase(state: EmotionFlowState) {
  const sourceText = normalizeContextText(state.originalText || state.sttText || "");
  const fact = normalizeContextText(state.analysis?.fact ?? "");
  const situation = cleanSituationPhrase(fact || sourceText);

  if (!situation) {
    return "방금 있었던 일";
  }

  return situation.length > 70 ? `${situation.slice(0, 70)}...` : situation;
}

export function getMessageSituation(state: EmotionFlowState) {
  return makeSituationPhrase(state);
}

function cleanSituationPhrase(text: string) {
  const normalized = normalizeContextText(text);

  if (!normalized) {
    return "";
  }

  if (/(하\s*고\s*싶지\s*않은\s*일|하고싶지\s*않은\s*일|원치\s*않는\s*(일|업무|일정)|원하지\s*않는\s*(일|업무|일정)|하기\s*싫은\s*(일|업무|일정))/.test(normalized)) {
    if (/(팀장|상사|파트장|부장|회사|업무|직장|동료)/.test(normalized) && /(통보|요구|지시|받았)/.test(normalized)) {
      return "원치 않는 업무를 충분한 논의 없이 통보받은 일";
    }

    return "원치 않는 일을 맡게 된 상황";
  }

  if (/(말을|말|의견).{0,12}(끊|자르)/.test(normalized)) {
    return normalized.includes("회의") ? "회의 중 제 말을 끝까지 듣지 않은 일" : "제 말을 끝까지 듣지 않은 일";
  }

  if (/(출장|출근|셔틀|이천)/.test(normalized)) {
    const placeMatch = normalized.match(/([가-힣A-Za-z0-9]+)\s*출장/);
    const place = placeMatch?.[1] ? `${placeMatch[1]} 출장` : "출장";

    if (/(갑자기|갑작|갑작스러운|통보|요구)/.test(normalized) && /(아침|오전|새벽|6시|7시|8시|셔틀|출근)/.test(normalized)) {
      return `갑작스러운 ${place}과 이른 출근 일정 통보`;
    }

    if (/(갑자기|갑작|갑작스러운|통보|요구)/.test(normalized)) {
      return `갑작스러운 ${place} 요청`;
    }

    return `${place} 일정`;
  }

  if (/(무시|존중)/.test(normalized)) {
    return "제가 존중받지 못한다고 느낀 일";
  }

  if (/(팀장|상사|파트장|부장|회사|업무|직장|동료)/.test(normalized) && /(통보|요구|지시)/.test(normalized)) {
    return "업무 내용을 충분한 논의 없이 통보받은 일";
  }

  if (/(약속|늦|기다)/.test(normalized)) {
    return "약속이나 기다림과 관련해 마음이 상한 일";
  }

  const firstSentence = normalized.split(/[.!?。！？]/)[0] ?? normalized;

  return firstSentence
    .replace(/너무\s*(화가|짜증이|속상|서운).*/, "")
    .replace(/바로\s*(따지고|말하고|보내고).*/, "")
    .replace(/(화가 나|짜증나|빡쳐|열받아|억울해|서운해).*/, "")
    .replace(/\s*(때문에|라서|해서|어서|니까)\s*$/, "")
    .trim();
}

function makeDesirePhrase(state: EmotionFlowState) {
  const desire = normalizeContextText(state.analysis?.desire ?? "");

  if (desire) {
    return desire.replace(/ 있어 보여요\.?$/, "").replace(/ 마음이$/, "");
  }

  return "제 입장도 차분히 들어주셨으면 하는 마음";
}

function withTopicParticle(text: string) {
  const lastChar = text.at(-1);

  if (!lastChar) {
    return text;
  }

  const code = lastChar.charCodeAt(0);

  if (code < 0xac00 || code > 0xd7a3) {
    return `${text}는`;
  }

  const hasBatchim = (code - 0xac00) % 28 !== 0;
  return `${text}${hasBatchim ? "은" : "는"}`;
}

function makeWorkOpening(situation: string) {
  if (situation.includes("원치 않는 업무")) {
    return "말씀하신 업무가 제 상황에서는 바로 받아들이기 어려워";
  }

  if (situation.includes("충분한 논의 없이 통보")) {
    return "업무 내용을 충분히 논의하지 못한 채 전달받아";
  }

  if (situation.endsWith("통보")) {
    return `${situation}를 받고`;
  }

  if (situation.endsWith("요청")) {
    return `${situation}을 받고`;
  }

  if (situation.endsWith("일정")) {
    return `${situation}을 듣고`;
  }

  return `${situation} 때문에`;
}

function makeWorkMessages(situation: string) {
  if (situation.includes("원치 않는 업무")) {
    return {
      soft: "말씀하신 업무가 제 상황에서는 바로 받아들이기 어려워 당황했습니다. 맡아야 하는 범위와 조정 가능한 부분을 함께 다시 확인하고 싶습니다.",
      firm: "그 업무는 현재 제 상황에서 부담이 큽니다. 바로 진행하기보다 필요성, 범위, 일정 조정 가능 여부를 먼저 논의하고 싶습니다.",
      short: "그 업무는 지금 바로 맡기 어렵습니다. 범위와 일정 조정을 먼저 논의하고 싶습니다.",
    };
  }

  if (situation.includes("충분한 논의 없이 통보")) {
    return {
      soft: "업무 내용이 충분한 논의 없이 전달되어 많이 당황했습니다. 제 상황도 함께 고려해서 조정할 수 있을지 이야기 나누고 싶습니다.",
      firm: "이번 건은 제게 부담이 큰 결정입니다. 일방적으로 진행하기보다 범위와 조정 방법을 다시 논의하고 싶습니다.",
      short: "이번 건은 제 상황도 함께 봐야 할 것 같습니다. 조정 가능 여부를 논의하고 싶습니다.",
    };
  }

  return null;
}

export function createMockSuggestedMessages(state: EmotionFlowState = initialFlowState) {
  const sourceText = normalizeContextText(state.originalText || state.sttText || "");
  const relationship = inferRelationship(sourceText);
  const situation = makeSituationPhrase(state);
  const situationTopic = withTopicParticle(situation);
  const workOpening = makeWorkOpening(situation);
  const desire = makeDesirePhrase(state);

  if (relationship === "work") {
    return makeWorkMessages(situation) ?? {
      soft: `${workOpening} 많이 당황했습니다. 일정 조율이 필요한 부분이라 제 상황도 함께 봐주시면 좋겠습니다.`,
      firm: `${situationTopic} 제게 부담이 큰 일정입니다. 가능한 범위와 조정 방법을 다시 논의하고 싶습니다.`,
      short: `${situation} 관련해서 제 상황도 함께 말씀드리고 싶습니다.`,
    };
  }

  if (relationship === "family") {
    return {
      soft: `${situation} 때문에 마음이 많이 상했어요. 싸우고 싶다기보다, ${desire}이 있다는 걸 알아줬으면 해요.`,
      firm: `${situationTopic} 저에게 가볍게 느껴지지 않았어요. 같은 일이 반복되지 않도록 제 이야기도 끝까지 들어주세요.`,
      short: `${situation} 때문에 마음이 상했어요. 제 이야기도 들어줬으면 해요.`,
    };
  }

  if (relationship === "partner") {
    return {
      soft: `${situation} 때문에 서운하고 속상했어요. 비난하려는 건 아니고, ${desire}이 있다는 걸 말하고 싶어요.`,
      firm: `${situationTopic} 저에게 중요한 문제예요. 감정적으로 싸우기보다 서로 어떻게 느꼈는지 차분히 이야기하고 싶어요.`,
      short: `${situation} 때문에 서운했어요. 차분히 이야기하고 싶어요.`,
    };
  }

  if (relationship === "friend") {
    return {
      soft: `${situation} 때문에 마음이 좀 불편했어. 따지려는 건 아니고, 내 입장도 한 번 말하고 싶어.`,
      firm: `${situationTopic} 나한테 그냥 넘기기 어려웠어. 다음에는 내 이야기도 조금 더 들어줬으면 해.`,
      short: `${situation} 때문에 불편했어. 내 입장도 말하고 싶어.`,
    };
  }

  return {
    soft: `${situation} 때문에 감정이 많이 올라왔어요. 바로 따지기보다, ${desire}이 있다는 걸 차분히 전하고 싶습니다.`,
    firm: `${situationTopic} 제게 중요한 부분입니다. 감정적으로 반응하기보다 제 입장을 분명히 설명하고 싶습니다.`,
    short: `${situation} 때문에 마음이 불편했습니다. 제 입장도 말하고 싶습니다.`,
  };
}

export function getMockResources(type: ResourceType): ResourceRecommendation[] {
  const resourcesByType: Record<ResourceType, ResourceRecommendation[]> = {
    video: [
      {
        id: "mock-video-1",
        title: "화가 올라올 때 멈추는 3분 호흡",
        type: "video",
        durationMinutes: 3,
        description: "감정 강도가 높을 때 몸의 긴장을 먼저 낮추는 짧은 영상입니다.",
        reason: "지금은 긴 설명보다 짧게 따라 할 수 있는 자료가 좋아요.",
      },
    ],
    meditation: [
      {
        id: "mock-meditation-1",
        title: "4초 들숨, 6초 날숨 루틴",
        type: "meditation",
        durationMinutes: 5,
        description: "호흡을 천천히 맞추며 즉각적인 반응을 늦추는 연습입니다.",
        reason: "감정이 빠르게 올라올 때 호흡 속도를 낮추는 데 도움이 됩니다.",
      },
    ],
    book: [
      {
        id: "mock-book-1",
        title: "비폭력 대화 연습",
        type: "book",
        description: "사실, 감정, 욕구, 부탁을 분리해 말하는 연습에 도움이 되는 책입니다.",
        reason: "상대에게 보낼 말을 차분한 요청으로 바꾸는 데 맞는 자료입니다.",
      },
    ],
    article: [
      {
        id: "mock-article-1",
        title: "감정과 해석을 분리하는 짧은 글",
        type: "article",
        durationMinutes: 4,
        description: "상황을 다시 볼 때 fact와 interpretation을 나누는 방법입니다.",
      },
    ],
    exercise: [
      {
        id: "mock-exercise-1",
        title: "보내기 전 3문장 체크",
        type: "exercise",
        durationMinutes: 2,
        description: "지금 보내려는 말을 감정, 사실, 요청으로 다시 쓰는 짧은 실천 과제입니다.",
      },
    ],
  };

  return resourcesByType[type];
}
