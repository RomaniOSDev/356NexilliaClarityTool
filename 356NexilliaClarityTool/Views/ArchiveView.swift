import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Archive")
                        .roundedTitle(26)
                        .foregroundColor(Color("AppTextPrimary"))
                    Text("Restore to put ink back on the roster, or delete forever.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color("AppTextSecondary"))

                    if store.archivedCount == 0 {
                        EmptyPlaceholder(
                            title: "Archive is empty",
                            symbol: "archivebox",
                            hint: "Removing a lesson, snap, or plan files it here first."
                        )
                    }

                    if !store.archivedLessons.isEmpty {
                        sectionTitle("Lessons")
                        ForEach(store.archivedLessons) { lesson in
                            archiveCard(
                                title: lesson.title,
                                detail: lesson.subject.rawValue,
                                restore: { store.restoreLesson(lesson) },
                                delete: { store.deleteLesson(lesson) }
                            )
                        }
                    }

                    if !store.archivedSnaps.isEmpty {
                        sectionTitle("Snaps")
                        ForEach(store.archivedSnaps) { snap in
                            archiveCard(
                                title: snap.title,
                                detail: store.resolvedSubject(for: snap).rawValue,
                                restore: { store.restoreSnap(snap) },
                                delete: { store.deleteSnap(snap) }
                            )
                        }
                    }

                    if !store.archivedPlans.isEmpty {
                        sectionTitle("Plans")
                        ForEach(store.archivedPlans) { plan in
                            archiveCard(
                                title: plan.title,
                                detail: store.resolvedSubject(for: plan).rawValue,
                                restore: { store.restorePlan(plan) },
                                delete: { store.deletePlan(plan) }
                            )
                        }
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
            .plannerScreenBackground()
            .background(RuledNotebookCanvas().allowsHitTesting(false))
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .roundedTitle(16, weight: .semibold)
            .foregroundColor(Color("AppTextPrimary"))
            .padding(.top, 6)
    }

    private func archiveCard(title: String, detail: String, restore: @escaping () -> Void, delete: @escaping () -> Void) -> some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .roundedTitle(16, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                Text(detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("AppTextSecondary"))
                HStack(spacing: 12) {
                    Button("Restore", action: restore)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AppTextPrimary"))
                    Button("Delete forever", action: delete)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AppPrimary"))
                }
            }
        }
    }
}
