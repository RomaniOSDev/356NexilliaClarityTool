import SwiftUI
import UIKit

struct LessonEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: LessonEditorViewModel
    private let lesson: TaggedLesson?
    private let onClose: () -> Void

    init(lesson: TaggedLesson?, onClose: @escaping () -> Void = {}) {
        self.lesson = lesson
        self.onClose = onClose
        _model = StateObject(wrappedValue: LessonEditorViewModel(lesson: lesson))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(model.isEditing ? "Revise Lesson" : "Tag a Lesson")
                        .roundedTitle(26)
                        .foregroundColor(Color("AppTextPrimary"))

                    WorksheetField(label: "Title", text: $model.title, prompt: "Period topic")

                    WorksheetField(label: "Period", text: $model.periodLabel, prompt: "P1")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("DURATION")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                            .foregroundColor(Color("AppTextSecondary"))
                        Stepper(value: $model.durationMinutes, in: 5...120, step: 5) {
                            Text("\(model.durationMinutes) min")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(Color("AppTextPrimary"))
                        }
                        .tint(Color("AppPrimary"))
                    }

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
                        SubjectChip(subject: model.subject)
                    }

                    WorksheetField(label: "Tags", text: $model.tagsText, prompt: "inquiry, lab, review")

                    GlowFillButton(
                        title: model.isEditing ? "Update Roster" : "Pin to Roster",
                        symbol: "arrow.up.doc.fill",
                        enabled: !model.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        saveAndClose()
                    }

                    if model.isEditing, let lesson {
                        Button("Archive from roster") {
                            store.archiveLesson(lesson)
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
                    Button(model.isEditing ? "Save" : "Pin") { saveAndClose() }
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
