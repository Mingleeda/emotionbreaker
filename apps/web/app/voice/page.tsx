"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, Loader2, Mic, RotateCcw, Square } from "lucide-react";
import { StepNav } from "@/components/layout/StepNav";
import { updateFlowState } from "@/lib/session/flow-store";

export default function VoicePage() {
  const router = useRouter();
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const mediaStreamRef = useRef<MediaStream | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<number | null>(null);
  const [recording, setRecording] = useState(false);
  const [transcribing, setTranscribing] = useState(false);
  const [recordedBlob, setRecordedBlob] = useState<Blob | null>(null);
  const [elapsedSeconds, setElapsedSeconds] = useState(0);
  const [text, setText] = useState("");
  const [error, setError] = useState("");

  const hasTranscript = Boolean(text.trim());

  useEffect(() => {
    return () => {
      stopTimer();
      stopStream();
    };
  }, []);

  function formatTime(seconds: number) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${String(minutes).padStart(2, "0")}:${String(remainingSeconds).padStart(2, "0")}`;
  }

  function stopTimer() {
    if (timerRef.current) {
      window.clearInterval(timerRef.current);
      timerRef.current = null;
    }
  }

  function stopStream() {
    mediaStreamRef.current?.getTracks().forEach((track) => track.stop());
    mediaStreamRef.current = null;
  }

  async function handleStartRecording() {
    setError("");
    setText("");
    setRecordedBlob(null);

    if (!navigator.mediaDevices?.getUserMedia) {
      setError("이 브라우저에서는 음성 녹음을 사용할 수 없어요.");
      return;
    }

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mimeType = MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
        ? "audio/webm;codecs=opus"
        : "audio/webm";
      const recorder = new MediaRecorder(stream, { mimeType });

      chunksRef.current = [];
      mediaStreamRef.current = stream;
      mediaRecorderRef.current = recorder;

      recorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          chunksRef.current.push(event.data);
        }
      };

      recorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: recorder.mimeType || "audio/webm" });
        setRecordedBlob(blob);
        setRecording(false);
        stopTimer();
        stopStream();
      };

      recorder.start();
      setElapsedSeconds(0);
      setRecording(true);
      timerRef.current = window.setInterval(() => {
        setElapsedSeconds((seconds) => {
          const nextSeconds = seconds + 1;

          if (nextSeconds >= 180) {
            mediaRecorderRef.current?.stop();
          }

          return nextSeconds;
        });
      }, 1000);
    } catch {
      setError("마이크 권한을 허용해야 녹음할 수 있어요.");
      stopStream();
      stopTimer();
      setRecording(false);
    }
  }

  async function handleStopRecording() {
    if (mediaRecorderRef.current?.state === "recording") {
      mediaRecorderRef.current.stop();
    }
  }

  async function handleTranscribe() {
    if (!recordedBlob) {
      return;
    }

    setError("");
    setTranscribing(true);

    const formData = new FormData();
    formData.append("file", recordedBlob, "emotionbreaker-recording.webm");

    try {
      const response = await fetch("/api/transcribe", {
        method: "POST",
        body: formData,
      });
      const result = (await response.json()) as { text?: string; error?: string };

      if (!response.ok || !result.text) {
        if (result.error === "OPENAI_API_KEY is not configured.") {
          throw new Error("OpenAI API 키가 아직 설정되지 않았어요. .env.local에 OPENAI_API_KEY를 넣고 서버를 다시 시작해주세요.");
        }

        if (result.error === "Audio file is required.") {
          throw new Error("녹음 파일이 비어 있어요. 다시 녹음해 주세요.");
        }

        if (result.error === "Audio file is too large.") {
          throw new Error("녹음 파일이 너무 커요. 3분 이내로 다시 녹음해 주세요.");
        }

        throw new Error(result.error ?? "음성을 텍스트로 바꾸지 못했어요.");
      }

      setText(result.text);
    } catch (transcribeError) {
      const message = transcribeError instanceof Error ? transcribeError.message : "음성을 텍스트로 바꾸지 못했어요.";
      setError(message);
    } finally {
      setTranscribing(false);
    }
  }

  function handleResetRecording() {
    stopTimer();
    stopStream();
    setRecording(false);
    setRecordedBlob(null);
    setText("");
    setElapsedSeconds(0);
    setError("");
  }

  function handleNext() {
    if (!text.trim()) {
      return;
    }

    updateFlowState({
      inputType: "voice",
      originalText: text.trim(),
      sttText: text.trim(),
    });
    router.push("/intensity");
  }

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-2xl flex-col gap-6 px-5 py-6">
      <StepNav backHref="/start" />
      <header className="space-y-3">
        <div className="flex items-center gap-2 text-sm font-bold text-[#C56F5C]">
          <Mic className="h-5 w-5" aria-hidden="true" />
          1단계 · 말로 털어놓기
        </div>
        <h1 className="text-3xl font-black leading-tight">정리 안 해도 괜찮아요.</h1>
        <p className="text-lg font-medium leading-7 text-[#46564E]">일단 말하면, 텍스트로 바꾼 뒤 다시 확인하게 해드릴게요.</p>
      </header>
      <section className="rounded-lg border-2 border-slate-200 bg-white p-6 shadow-sm">
        <p className="text-center text-6xl font-black">{formatTime(elapsedSeconds)}</p>
        <p className="mt-2 text-center text-sm font-semibold text-slate-600">최대 3분</p>
        <div className="mt-6 grid gap-3 sm:grid-cols-2">
          <button
            type="button"
            onClick={handleStartRecording}
            disabled={recording || transcribing}
            className="flex min-h-16 items-center justify-center gap-2 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white disabled:cursor-not-allowed disabled:bg-slate-300"
          >
            <Mic className="h-6 w-6" aria-hidden="true" />
            녹음 시작
          </button>
          <button
            type="button"
            onClick={handleStopRecording}
            disabled={!recording}
            className="flex min-h-16 items-center justify-center gap-2 rounded-lg border-2 border-slate-300 bg-white px-5 text-xl font-bold disabled:cursor-not-allowed disabled:text-slate-300"
          >
            <Square className="h-5 w-5" aria-hidden="true" />
            녹음 종료
          </button>
        </div>
        {recording ? <p className="mt-4 text-center text-sm font-bold text-[#C56F5C]">녹음 중이에요. 다 말했으면 종료를 눌러주세요.</p> : null}
      </section>
      {recordedBlob && !text.trim() ? (
        <section className="space-y-3 rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <h2 className="text-xl font-black">녹음이 끝났어요.</h2>
          <p className="text-base font-medium text-[#46564E]">이제 텍스트로 바꿔서 확인할게요.</p>
          <div className="grid gap-3 sm:grid-cols-2">
            <button
              type="button"
              onClick={handleTranscribe}
              disabled={transcribing}
              className="flex min-h-14 items-center justify-center gap-2 rounded-lg bg-[#25342D] px-5 text-lg font-bold text-white disabled:cursor-wait disabled:bg-slate-400"
            >
              {transcribing ? <Loader2 className="h-5 w-5 animate-spin" aria-hidden="true" /> : <ArrowRight className="h-5 w-5" aria-hidden="true" />}
              텍스트로 바꾸기
            </button>
            <button
              type="button"
              onClick={handleResetRecording}
              disabled={transcribing}
              className="flex min-h-14 items-center justify-center gap-2 rounded-lg border-2 border-slate-300 px-5 text-lg font-bold"
            >
              <RotateCcw className="h-5 w-5" aria-hidden="true" />
              다시 녹음
            </button>
          </div>
        </section>
      ) : null}
      {error ? (
        <p className="rounded-lg border border-red-200 bg-[#FFF1EA] p-4 text-base font-bold text-[#994838]">{error}</p>
      ) : null}
      {hasTranscript ? (
        <section className="space-y-3">
          <h2 className="text-xl font-black">이렇게 들었어요.</h2>
          <textarea
            value={text}
            onChange={(event) => setText(event.target.value)}
            className="min-h-44 w-full rounded-lg border-2 border-slate-300 bg-white p-4 text-lg font-medium leading-8 shadow-sm outline-none focus:border-slate-400"
          />
          <button
            type="button"
            onClick={handleNext}
            disabled={!text.trim()}
            className="flex min-h-16 w-full items-center justify-center gap-2 rounded-lg bg-[#25342D] px-5 text-xl font-bold text-white"
          >
            이대로 분석하기
            <ArrowRight className="h-6 w-6" aria-hidden="true" />
          </button>
        </section>
      ) : null}
    </main>
  );
}
