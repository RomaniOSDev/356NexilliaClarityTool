import SwiftUI

struct SyllabusView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var timer: LessonTimerController
    @State private var showCreate = false
    @State private var editing: TaggedLesson?
    @State private var query = ""
    @State private var subjectFilter: Subject?

    private var visibleLessons: [TaggedLesson] {
        store.lessonsByDate.filter { lesson in
            if let subjectFilter, lesson.subject != subjectFilter { return false }
            return RosterFilter.matches(query, title: lesson.title, tags: lesson.tags)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            TornPaperBanner(caption: store.activeLessons.isEmpty
                ? "A blank roster waits for the first tag."
                : "Roster inked · \(store.activeLessons.count) tagged")
                .padding(.top, 6)

            if !store.activeLessons.isEmpty {
                RosterSearchBar(query: $query, subject: $subjectFilter)
            }

            if store.activeLessons.isEmpty {
                Spacer(minLength: 12)
                EmptyPlaceholder(
                    title: "No Lessons Yet",
                    symbol: "arrow.up.doc",
                    hint: "Title and subject lock a lesson onto the roster."
                )
                Spacer()
            } else if visibleLessons.isEmpty {
                Spacer(minLength: 12)
                EmptyPlaceholder(
                    title: "No matches",
                    symbol: "magnifyingglass",
                    hint: "Try another subject or clear the search."
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(visibleLessons) { lesson in
                            Button {
                                editing = lesson
                            } label: {
                                lessonRow(lesson)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    editing = lesson
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                ForEach(LessonTimerPreset.allCases) { preset in
                                    Button {
                                        timer.start(preset: preset, lessonTitle: lesson.title)
                                    } label: {
                                        Label(preset.rawValue, systemImage: "timer")
                                    }
                                }
                                Button {
                                    store.duplicateLesson(lesson)
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                Button(role: .destructive) {
                                    store.archiveLesson(lesson)
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
            LessonEditorView(lesson: nil, onClose: { showCreate = false })
                .environmentObject(store)
        }
        .sheet(item: $editing) { lesson in
            LessonEditorView(lesson: lesson, onClose: { editing = nil })
                .environmentObject(store)
        }
    }

    private func lessonRow(_ lesson: TaggedLesson) -> some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(lesson.title)
                        .roundedTitle(18, weight: .semibold)
                        .foregroundColor(Color("AppTextPrimary"))
                    Spacer()
                    Text(DateDisplay.roster(lesson.revisedDate))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color("AppTextSecondary"))
                }
                HStack(spacing: 8) {
                    SubjectChip(subject: lesson.subject)
                    TagChip(label: lesson.periodStamp)
                }
                if !lesson.tags.isEmpty {
                    FlowTags(tags: lesson.tags)
                }
            }
        }
    }
}

struct FlowTags: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(tags.prefix(4).enumerated()), id: \.offset) { _, tag in
                TagChip(label: tag)
            }
        }
    }
}
