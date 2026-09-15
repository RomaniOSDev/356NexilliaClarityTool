import SwiftUI
import UIKit

struct PlanEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: PlanEditorViewModel
    private let plan: LessonPlan?
    private let onClose: () -> Void

    init(plan: LessonPlan?, onClose: @escaping () -> Void = {}) {
        self.plan = plan
        self.onClose = onClose
        _model = StateObject(wrappedValue: PlanEditorViewModel(plan: plan))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 12) {
                        Text(model.isEditing ? "Refine Plan" : "Compose Plan")
                            .roundedTitle(26)
                            .foregroundColor(Color("AppTextPrimary"))
                        Spacer()
                        Image("tile_chalkboard")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                            .clipShape(ParallelogramChip())
                            .overlay(
                                ParallelogramChip()
                                    .stroke(Color("AppPrimary"), lineWidth: 1.2)
                            )
                            .allowsHitTesting(false)
                    }

                    Text("Standards motif — keep the sequence tight.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color("AppTextSecondary"))

                    WorksheetField(label: "Title", text: $model.title, prompt: "Full period sequence")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("TEMPLATES")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                            .foregroundColor(Color("AppTextSecondary"))
                        HStack(spacing: 8) {
                            ForEach(PlanTemplate.allCases) { template in
                                Button {
                                    model.applyTemplate(template)
                                } label: {
                                    Text(template.chipTitle)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color("AppTextPrimary"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background(Color("AppSurface"))
                                        .overlay(Rectangle().stroke(Color("AppPrimary"), lineWidth: 1))
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    WorksheetEditor(
                        label: "Description",
                        text: $model.descriptionText,
                        prompt: "Objectives, flow, checks for understanding"
                    )
                    WorksheetField(label: "Tags", text: $model.tagsText, prompt: "standards, station, debate")

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
                            Text("Standalone plan").tag(nil as UUID?)
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("LOCAL REMINDER")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.6)
                            .foregroundColor(Color("AppTextSecondary"))
                        DatePicker(
                            "Reminder",
                            selection: $model.reminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(Color("AppPrimary"))
                        .colorScheme(.dark)
                    }

                    Toggle(isOn: $model.needsRevision) {
                        Text("Needs revision")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("AppTextPrimary"))
                    }
                    .tint(Color("AppPrimary"))

                    GlowFillButton(
                        title: model.isEditing ? "Update Plan" : "File Plan",
                        symbol: "doc.text.fill",
                        enabled: !model.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        saveAndClose()
                    }

                    if model.isEditing, let plan {
                        Button("Archive plan") {
                            store.archivePlan(plan)
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
