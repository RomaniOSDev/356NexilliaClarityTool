import SwiftUI

struct SnapsView: View {
    @EnvironmentObject private var store: DataStore
    @State private var showCreate = false
    @State private var editing: LessonSnap?
    @State private var warmup: LessonSnap?
    @State private var query = ""
    @State private var subjectFilter: Subject?

    private var visibleSnaps: [LessonSnap] {
        store.snapsByEdit.filter { snap in
            if let subjectFilter, store.resolvedSubject(for: snap) != subjectFilter { return false }
            let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if needle.isEmpty { return true }
            return RosterFilter.matches(query, title: snap.title, tags: snap.tags)
                || snap.note.lowercased().contains(needle.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !store.activeSnaps.isEmpty {
                RosterSearchBar(query: $query, subject: $subjectFilter)
                Button {
                    warmup = store.randomSnap()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                        Text("Warm-up of the day")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color("AppPrimary"))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .disabled(store.activeSnaps.isEmpty)
            }

            if store.activeSnaps.isEmpty {
                Spacer(minLength: 20)
                EmptyPlaceholder(
                    title: "No lessons yet! Tap + to begin.",
                    symbol: "square.and.pencil",
                    hint: "Bridge a snap to a tagged lesson when the idea belongs on the roster."
                )
                Spacer()
            } else if visibleSnaps.isEmpty {
                Spacer(minLength: 20)
                EmptyPlaceholder(
                    title: "No matches",
                    symbol: "magnifyingglass",
                    hint: "Try another subject or clear the search."
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(visibleSnaps) { snap in
                            Button {
                                editing = snap
                            } label: {
                                snapRow(snap)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    editing = snap
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button {
                                    store.duplicateSnap(snap)
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                Button(role: .destructive) {
                                    store.archiveSnap(snap)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
        .addInkButton { showCreate = true }
        .sheet(isPresented: $showCreate) {
            SnapEditorView(snap: nil, onClose: { showCreate = false })
                .environmentObject(store)
        }
        .sheet(item: $editing) { snap in
            SnapEditorView(snap: snap, onClose: { editing = nil })
                .environmentObject(store)
        }
        .sheet(item: $warmup) { snap in
            warmupSheet(snap)
                .environmentObject(store)
        }
    }

    private func snapRow(_ snap: LessonSnap) -> some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(snap.title)
                            .roundedTitle(17, weight: .semibold)
                            .foregroundColor(Color("AppTextPrimary"))
                        if !snap.note.isEmpty {
                            Text(snap.note)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(Color("AppTextSecondary"))
                                .lineLimit(3)
                        }
                    }
                    Spacer(minLength: 0)
                }
                HStack(spacing: 8) {
                    SubjectChip(subject: store.resolvedSubject(for: snap))
                    if let linked = snap.linkedLessonId, let lesson = store.lesson(id: linked) {
                        TagChip(label: "→ \(lesson.title)")
                    }
                }
                Text("Inked \(DateDisplay.inked(snap.lastEdited))")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color("AppTextSecondary"))
                if !snap.tags.isEmpty {
                    FlowTags(tags: snap.tags)
                }
            }
        }
    }

    private func warmupSheet(_ snap: LessonSnap) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Warm-up of the day")
                    .roundedTitle(26)
                    .foregroundColor(Color("AppTextPrimary"))
                LayeredSurface {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(snap.title)
                            .roundedTitle(18, weight: .semibold)
                            .foregroundColor(Color("AppTextPrimary"))
                        if !snap.note.isEmpty {
                            Text(snap.note)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        SubjectChip(subject: store.resolvedSubject(for: snap))
                    }
                }
                GlowFillButton(title: "Draw another", symbol: "dice.fill") {
                    warmup = store.randomSnap()
                }
                Button("Open this snap") {
                    let chosen = snap
                    warmup = nil
                    editing = chosen
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Color("AppPrimary"))
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { warmup = nil }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .plannerScreenBackground()
            .background(RuledNotebookCanvas().allowsHitTesting(false))
        }
    }
}
