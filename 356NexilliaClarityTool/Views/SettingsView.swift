import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var showArchive = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Workspace")
                        .roundedTitle(26)
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(.bottom, 6)

                    settingsRow(title: store.archivedCount == 0 ? "Archive" : "Archive (\(store.archivedCount))", symbol: "archivebox.fill") {
                        showArchive = true
                    }
                    settingsRow(title: "Reminders", symbol: "bell.fill") {
                        ReminderScheduler.prepare()
                    }
                    settingsRow(title: "Rate Us", symbol: "star.fill") {
                        AppLinks.requestReview()
                    }
                    settingsRow(title: "Privacy", symbol: "hand.raised.fill") {
                        AppLinks.open(AppLinks.privacy)
                    }
                    settingsRow(title: "Terms", symbol: "doc.plaintext") {
                        AppLinks.open(AppLinks.terms)
                    }
                    settingsRow(title: "Reset All Data", symbol: "trash.fill", destructive: true) {
                        confirmReset = true
                    }
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showArchive) {
                ArchiveView()
                    .environmentObject(store)
            }
            .alert("Erase the roster?", isPresented: $confirmReset) {
                Button("Reset All Data", role: .destructive) {
                    store.resetAll()
                    dismiss()
                }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("Lessons, snaps, and plans will be cleared from this device.")
            }
            .plannerScreenBackground()
            .background(RuledNotebookCanvas())
        }
    }

    private func settingsRow(title: String, symbol: String, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("AppTextPrimary"))
                    .frame(width: 34, height: 34)
                    .background(destructive ? Color("AppPrimary") : Color("AppSurface"))
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .tracking(-0.35)
                    .foregroundColor(Color("AppTextPrimary"))
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("AppTextSecondary"))
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color("AppBackground").opacity(0.4), Color("AppSurface")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                Rectangle()
                    .fill(Color("AppPrimary"))
                    .frame(height: 1.5),
                alignment: .bottom
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
