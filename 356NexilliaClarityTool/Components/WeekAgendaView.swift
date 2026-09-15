import SwiftUI

struct WeekAgendaView: View {
    let plans: [LessonPlan]
    var onSelect: (LessonPlan) -> Void

    private var days: [Date] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This week")
                .roundedTitle(17, weight: .semibold)
                .foregroundColor(Color("AppTextPrimary"))
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        dayColumn(day)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 10)
    }

    private func plans(on day: Date) -> [LessonPlan] {
        let calendar = Calendar.current
        return plans
            .filter { calendar.isDate($0.reminderDate, inSameDayAs: day) }
            .sorted { $0.reminderDate < $1.reminderDate }
    }

    private func dayColumn(_ day: Date) -> some View {
        let hits = plans(on: day)
        let isToday = Calendar.current.isDateInToday(day)
        return VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 2) {
                Text(DateDisplay.weekday(day))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(isToday ? Color("AppPrimary") : Color("AppTextSecondary"))
                Text(DateDisplay.monthDay(day))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("AppTextPrimary"))
            }
            .frame(maxWidth: .infinity)

            if hits.isEmpty {
                Text("—")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                ForEach(hits) { plan in
                    Button {
                        onSelect(plan)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(plan.title)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("AppTextPrimary"))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            UrgencyStamp(urgency: plan.urgency)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("AppBackground").opacity(0.55))
                        .overlay(
                            Rectangle()
                                .fill(UrgencyStamp.color(plan.urgency))
                                .frame(width: 3),
                            alignment: .leading
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(8)
        .frame(width: 132, alignment: .top)
        .background(Color("AppSurface").opacity(0.92))
        .overlay(
            Rectangle()
                .stroke(isToday ? Color("AppPrimary") : Color("AppPrimary").opacity(0.25), lineWidth: isToday ? 1.6 : 1)
        )
    }
}

struct UrgencyStamp: View {
    let urgency: ReminderUrgency

    var body: some View {
        Text(urgency.label)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(Color("AppTextPrimary"))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Self.color(urgency))
    }

    static func color(_ urgency: ReminderUrgency) -> Color {
        switch urgency {
        case .overdue: return Color("AppPrimary")
        case .today: return Color("AppAccent")
        case .tomorrow: return Color("AppPrimary").opacity(0.55)
        case .later: return Color("AppTextSecondary").opacity(0.55)
        }
    }
}
