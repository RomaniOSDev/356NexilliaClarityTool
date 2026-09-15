import SwiftUI

struct ContentView: View {
    @StateObject private var store = DataStore()
    @StateObject private var timer = LessonTimerController()
    @State private var selectedTab: PlannerTab = .syllabus
    @State private var showSettings = false
    @State private var undoHideTask: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 0) {
            header
                .zIndex(5)
            UnderlineTabStrip(selection: $selectedTab, revisionCount: store.revisionCount)
                .zIndex(5)
            Rectangle()
                .fill(Color("AppPrimary").opacity(0.35))
                .frame(height: 1)
                .zIndex(5)
            tabBody
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(0)
            if store.undoPayload != nil {
                UndoBanner(message: store.undoMessage, onUndo: {
                    undoHideTask?.cancel()
                    store.undoLast()
                })
                .padding(.bottom, timer.isActive ? 0 : 8)
            }
            LessonTimerOverlay(timer: timer)
        }
        .animation(.easeOut(duration: 0.2), value: store.undoToken)
        .animation(.easeOut(duration: 0.2), value: timer.isActive)
        .environmentObject(store)
        .environmentObject(timer)
        .background(RuledNotebookCanvas().allowsHitTesting(false))
        .plannerScreenBackground()
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .onChange(of: store.undoToken) { _ in
            scheduleUndoHide()
        }
        .onReceive(NotificationCenter.default.publisher(for: AppNotifications.dataDidReset)) { _ in
            selectedTab = .syllabus
            timer.stop()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTab.heading)
                    .roundedTitle(24)
                    .foregroundColor(Color("AppTextPrimary"))
                Text("Underline the period. Keep the ink honest.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("AppTextSecondary"))
            }
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("AppTextPrimary"))
                    .frame(width: 44, height: 44)
                    .background(Color("AppPrimary"))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .pinkGlow()
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .contentShape(Rectangle())
        .background(Color("AppBackground").opacity(0.001))
    }

    @ViewBuilder
    private var tabBody: some View {
        switch selectedTab {
        case .syllabus:
            SyllabusView()
        case .snaps:
            SnapsView()
        case .plans:
            PlansView()
        case .board:
            BoardView()
        case .stats:
            StatsView()
        }
    }

    private func scheduleUndoHide() {
        undoHideTask?.cancel()
        guard store.undoPayload != nil else { return }
        let work = DispatchWorkItem {
            store.clearUndo()
        }
        undoHideTask = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: work)
    }
}
