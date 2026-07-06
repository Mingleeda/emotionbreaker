import SwiftUI
import Speech
import AVFoundation

@MainActor
final class VoiceRecorderModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case recording
        case finished
    }

    @Published var phase: Phase = .idle
    @Published var transcript: String = ""
    @Published var elapsedSeconds: Int = 0
    @Published var errorMessage: String?

    private let audioEngine = AVAudioEngine()
    private var recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var timer: Timer?

    var formattedTime: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    func startRecording() {
        errorMessage = nil
        transcript = ""
        elapsedSeconds = 0

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                guard status == .authorized else {
                    self.errorMessage = "음성 인식 권한이 없어요. 설정에서 허용하거나, 글로 적기로 계속할 수 있어요."
                    return
                }
                AVAudioApplication.requestRecordPermission { granted in
                    Task { @MainActor in
                        guard granted else {
                            self.errorMessage = "마이크 권한이 없어요. 설정에서 허용하거나, 글로 적기로 계속할 수 있어요."
                            return
                        }
                        self.beginSession()
                    }
                }
            }
        }
    }

    private func beginSession() {
        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "지금은 음성 인식을 사용할 수 없어요. 글로 적기로 계속해 주세요."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            self.request = request

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                    }
                    if error != nil, self.phase == .recording {
                        self.stopRecording()
                    }
                }
            }

            phase = .recording
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    self.elapsedSeconds += 1
                    if self.elapsedSeconds >= 180 {
                        self.stopRecording()
                    }
                }
            }
        } catch {
            errorMessage = "녹음을 시작하지 못했어요. 글로 적기로 계속해 주세요."
            cleanup()
        }
    }

    func stopRecording() {
        guard phase == .recording else { return }
        cleanup()
        phase = .finished
    }

    func reset() {
        cleanup()
        phase = .idle
        transcript = ""
        elapsedSeconds = 0
        errorMessage = nil
    }

    private func cleanup() {
        timer?.invalidate()
        timer = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        request = nil
        task?.cancel()
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

struct VoiceView: View {
    @EnvironmentObject private var flow: FlowStore
    @StateObject private var recorder = VoiceRecorderModel()
    @ScaledMetric(relativeTo: .largeTitle) private var timerFontSize = 56

    private var trimmedTranscript: String {
        recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    StepBadge(symbol: "mic", text: "1단계 · 말로 털어놓기")
                    Text("정리 안 해도 괜찮아요.")
                        .font(.title.weight(.black))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("일단 말하면, 텍스트로 바꾼 뒤 다시 확인하게 해드릴게요.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                recordingCard

                if let error = recorder.errorMessage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(error)
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color.appWarnText)
                        Button {
                            flow.path.removeLast()
                            flow.path.append(.input)
                        } label: {
                            Label("글로 적기로 계속하기", systemImage: "keyboard")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appWarnBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if recorder.phase == .finished {
                    transcriptSection
                }
            }
            .padding(20)
        }
        .background(Color.appBackground)
        .navigationTitle("말로 털어놓기")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if recorder.phase == .recording {
                recorder.stopRecording()
            }
        }
    }

    private var recordingCard: some View {
        VStack(spacing: 14) {
            Text(recorder.formattedTime)
                .font(.system(size: timerFontSize, weight: .black))
                .monospacedDigit()
                .foregroundStyle(Color.appTextPrimary)
            Text("최대 3분")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)

            if recorder.phase == .recording {
                Button {
                    recorder.stopRecording()
                } label: {
                    Label("녹음 종료", systemImage: "stop.fill")
                }
                .buttonStyle(SecondaryButtonStyle())

                Text("녹음 중이에요. 다 말했으면 종료를 눌러주세요.")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Color.appAccent)
            } else {
                Button {
                    recorder.startRecording()
                } label: {
                    Label(recorder.phase == .finished ? "다시 녹음" : "녹음 시작", systemImage: "mic.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.appCard)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.appBorder, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이렇게 들었어요.")
                .font(.title3.weight(.black))
                .foregroundStyle(Color.appTextPrimary)

            if trimmedTranscript.isEmpty {
                Text("들린 내용이 없어요. 다시 녹음하거나, 글로 적기로 계속할 수 있어요.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .card()
                Button {
                    flow.path.removeLast()
                    flow.path.append(.input)
                } label: {
                    Label("글로 적기로 계속하기", systemImage: "keyboard")
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                TextEditor(text: $recorder.transcript)
                    .font(.title3.weight(.medium))
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .frame(minHeight: 150)
                    .background(Color.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.appBorder, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .accessibilityLabel("음성으로 받아 적은 내용, 수정 가능")

                Button {
                    flow.inputType = .voice
                    flow.originalText = trimmedTranscript
                    flow.invalidateResults()
                    flow.path.append(.intensity)
                } label: {
                    Label("감정 점수 고르기", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}
