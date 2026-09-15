import SwiftUI
import Combine
import UIKit

enum LessonTimerPreset: String, CaseIterable, Identifiable {
    case doNow = "Do Now"
    case ten = "10 min"
    case five = "5 min"

    var id: String { rawValue }

    var seconds: Int {
        switch self {
        case .doNow: return 8 * 60
        case .ten: return 10 * 60
        case .five: return 5 * 60
        }
    }
}

final class LessonTimerController: ObservableObject {
    @Published private(set) var remaining: Int = 0
    @Published private(set) var isRunning = false
    @Published private(set) var label = ""
    @Published private(set) var lessonTitle = ""

    private var ticker: AnyCancellable?

    var isActive: Bool { !label.isEmpty }

    var clock: String {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func start(preset: LessonTimerPreset, lessonTitle: String) {
        ticker?.cancel()
        remaining = preset.seconds
        label = preset.rawValue
        self.lessonTitle = lessonTitle
        isRunning = true
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func togglePause() {
        guard remaining > 0 else { return }
        if isRunning {
            isRunning = false
            ticker?.cancel()
        } else {
            isRunning = true
            ticker = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.tick()
                }
        }
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        remaining = 0
        isRunning = false
        label = ""
        lessonTitle = ""
    }

    private func tick() {
        if remaining <= 1 {
            remaining = 0
            isRunning = false
            ticker?.cancel()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            remaining -= 1
        }
    }
}

struct LessonTimerOverlay: View {
    @ObservedObject var timer: LessonTimerController

    var body: some View {
        if timer.isActive {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timer.label.isEmpty ? "Timer" : timer.label)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AppTextSecondary"))
                    Text(timer.clock)
                        .roundedTitle(22)
                        .foregroundColor(Color("AppTextPrimary"))
                        .monospacedDigit()
                    if !timer.lessonTitle.isEmpty {
                        Text(timer.lessonTitle)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("AppTextSecondary"))
                            .lineLimit(1)
                    }
                }
                Spacer()
                Button(timer.isRunning ? "Pause" : "Resume") {
                    timer.togglePause()
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color("AppTextPrimary"))
                Button("Stop") {
                    timer.stop()
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color("AppPrimary"))
            }
            .padding(14)
            .background(Color("AppSurface"))
            .overlay(
                Rectangle()
                    .fill(Color("AppPrimary"))
                    .frame(height: 2),
                alignment: .top
            )
            .pinkGlow()
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
