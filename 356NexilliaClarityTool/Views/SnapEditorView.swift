import SwiftUI
import UIKit

struct SnapEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: SnapEditorViewModel
    private let snap: LessonSnap?
    private let onClose: () -> Void

    init(snap: LessonSnap?, onClose: @escaping () -> Void = {}) {
        self.snap = snap
        self.onClose = onClose
        _model = StateObject(wrappedValue: SnapEditorViewModel(snap: snap))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(model.isEditing ? "Edit Idea" : "Scratch an Idea")
                        .roundedTitle(26)
                        .foregroundColor(Color("AppTextPrimary"))

                    WorksheetField(label: "Title", text: $model.title, prompt: "Warm-up spark")
                    WorksheetEditor(label: "Note", text: $model.note, prompt: "Jot the thought while it is hot")
                    WorksheetField(label: "Tags", text: $model.tagsText, prompt: "exit ticket, pair share")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("SUBJECT")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                            .foregroundColor(Color("AppTextSecondary"))
                        Picker("Subject", selection: $model.subject) {
                            ForEach(Subject.allCases) { item in
                                Text(item.rawValue).tag(item)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color("AppPrimary"))
                        .disabled(model.linkedLessonId != nil)
                        SubjectChip(subject: model.subject)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("LINK TO ROSTER")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                            .foregroundColor(Color("AppTextSecondary"))
                        Picker("Linked lesson", selection: $model.linkedLessonId) {
                            Text("Standalone idea").tag(nil as UUID?)
                            ForEach(store.lessonsByDate) { lesson in
                                Text(lesson.title).tag(lesson.id as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color("AppPrimary"))
                        .onChange(of: model.linkedLessonId) { newValue in
                            if let newValue, let lesson = store.lesson(id: newValue) {
                                model.applyLinkedLesson(lesson)
                            } else {
                                model.applyLinkedLesson(nil)
                            }
                        }
                        if let linked = model.linkedLessonId, let lesson = store.lesson(id: linked) {
                            Text("Bridged to “\(lesson.title)”")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                    }

                    GlowFillButton(
                        title: model.isEditing ? "Save Idea" : "Keep Idea",
                        symbol: "square.and.pencil",
                        enabled: !model.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        saveAndClose()
                    }

                    if model.isEditing, let snap {
                        Button("Archive idea") {
                            store.archiveSnap(snap)
                            closeEditor()
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AppPrimary"))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.immediately)
            .editorKeyboardDone()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { closeEditor() }
                        .foregroundColor(Color("AppPrimary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndClose() }
                        .foregroundColor(Color("AppPrimary"))
                        .disabled(model.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .plannerScreenBackground()
            .background(RuledNotebookCanvas().allowsHitTesting(false))
        }
    }

    private func saveAndClose() {
        guard model.canSave else { return }
        model.commit(to: store)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        closeEditor()
    }

    private func closeEditor() {
        onClose()
        dismiss()
    }
}
