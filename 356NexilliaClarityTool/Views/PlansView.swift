import SwiftUI

struct PlansView: View {
    @EnvironmentObject private var store: DataStore
    @State private var showCreate = false
    @State private var editing: LessonPlan?
    @State private var query = ""
    @State private var subjectFilter: Subject?
    @State private var revisionOnly = false

    private var visiblePlans: [LessonPlan] {
        store.plansByReminder.filter { plan in
            if revisionOnly, !plan.needsRevision { return false }
            if let subjectFilter, store.resolvedSubject(for: plan) != subjectFilter { return false }
            let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if needle.isEmpty { return true }
            return RosterFilter.matches(query, title: plan.title, tags: plan.tags)
                || plan.description.lowercased().contains(needle.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !store.activePlans.isEmpty {
                WeekAgendaView(plans: store.activePlans) { plan in
                    editing = plan
                }
                RosterSearchBar(query: $query, subject: $subjectFilter)
                Button {
                    revisionOnly.toggle()
                } label: {
                    Text(revisionOnly ? "Showing revision only" : "Needs revision")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(revisionOnly ? Color("AppPrimary") : Color("AppSurface"))
                        .overlay(Rectangle().stroke(Color("AppPrimary"), lineWidth: 1))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            if store.activePlans.isEmpty {
                Spacer(minLength: 20)
                EmptyPlaceholder(
                    title: "Start creating your first lesson plan today!",
                    symbol: "doc.text",
                    hint: "A full plan keeps the reminder on this device only."
                )
                Spacer()
            } else if visiblePlans.isEmpty {
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
                        ForEach(visiblePlans) { plan in
                            Button {
                                editing = plan
                            } label: {
                                planRow(plan)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    editing = plan
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button {
                                    store.duplicatePlan(plan)
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                Button(role: .destructive) {
                                    store.archivePlan(plan)
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
            PlanEditorView(plan: nil, onClose: { showCreate = false })
                .environmentObject(store)
        }
        .sheet(item: $editing) { plan in
            PlanEditorView(plan: plan, onClose: { editing = nil })
                .environmentObject(store)
        }
    }

    private func planRow(_ plan: LessonPlan) -> some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(plan.title)
                        .roundedTitle(17, weight: .semibold)
                        .foregroundColor(Color("AppTextPrimary"))
                    Spacer()
                    HStack(spacing: 6) {
                        UrgencyStamp(urgency: plan.urgency)
                        if plan.needsRevision {
                            Text("Revise")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color("AppTextPrimary"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color("AppPrimary"))
                        }
                    }
                }
                if !plan.description.isEmpty {
                    Text(plan.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color("AppTextSecondary"))
                        .lineLimit(3)
                }
                HStack(spacing: 8) {
                    SubjectChip(subject: store.resolvedSubject(for: plan))
                    if let linked = plan.linkedLessonId, let lesson = store.lesson(id: linked) {
                        TagChip(label: "→ \(lesson.title)")
                    }
                }
                Text("Local mark · \(DateDisplay.inked(plan.reminderDate))")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color("AppTextSecondary"))
                if !plan.tags.isEmpty {
                    FlowTags(tags: plan.tags)
                }
            }
        }
        .overlay(
            Rectangle()
                .fill(UrgencyStamp.color(plan.urgency))
                .frame(width: 4),
            alignment: .leading
        )
    }
}
