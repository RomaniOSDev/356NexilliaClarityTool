import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var model = StatsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if !model.hasData {
                    EmptyPlaceholder(
                        title: "No ink to chart yet",
                        symbol: "chart.bar",
                        hint: "Tag lessons, keep snaps, and file plans — the graphs fill in as the roster grows."
                    )
                } else {
                    summaryRow
                    subjectChart
                    activityChart
                    mixChart
                    if !model.upcoming.isEmpty {
                        upcomingCard
                    }
                    if !model.topTags.isEmpty {
                        tagsCard
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
        .onAppear { model.rebuild(from: store) }
        .onChange(of: store.lessons) { _ in model.rebuild(from: store) }
        .onChange(of: store.snaps) { _ in model.rebuild(from: store) }
        .onChange(of: store.plans) { _ in model.rebuild(from: store) }
        .onReceive(NotificationCenter.default.publisher(for: AppNotifications.dataDidReset)) { _ in
            model.rebuild(from: store)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("How the roster is moving")
                .roundedTitle(20)
                .foregroundColor(Color("AppTextPrimary"))
            Text(model.hasData ? "\(model.grandTotal) pieces · \(model.revisionCount) marked to revise" : "Charts stay quiet until the first tag.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color("AppTextSecondary"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppSurface").opacity(0.92))
        .overlay(
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(height: 2),
            alignment: .bottom
        )
        .pinkGlow()
    }

    private var summaryRow: some View {
        HStack(spacing: 8) {
            summaryStamp("Lessons", model.lessonCount)
            summaryStamp("Snaps", model.snapCount)
            summaryStamp("Plans", model.planCount)
        }
    }

    private func summaryStamp(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .roundedTitle(22)
                .foregroundColor(Color("AppPrimary"))
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color("AppTextSecondary"))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppSurface").opacity(0.92))
        .overlay(
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(width: 3),
            alignment: .leading
        )
    }

    private var subjectChart: some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 12) {
                Text("By subject")
                    .roundedTitle(17, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                Chart(model.subjectMix) { row in
                    BarMark(
                        x: .value("Subject", row.subject.rawValue),
                        y: .value("Count", row.count)
                    )
                    .foregroundStyle(by: .value("Kind", row.kind))
                }
                .chartForegroundStyleScale([
                    "Lessons": Color("AppPrimary"),
                    "Snaps": Color("AppAccent"),
                    "Plans": Color("AppTextSecondary")
                ])
                .chartLegend(position: .bottom, spacing: 8)
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color("AppTextPrimary").opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
    }

    private var activityChart: some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ink over 14 days")
                    .roundedTitle(17, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                Chart(model.activity) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Count", point.count)
                    )
                    .foregroundStyle(by: .value("Kind", point.kind))
                    .interpolationMethod(.catmullRom)
                }
                .chartForegroundStyleScale([
                    "Lessons": Color("AppPrimary"),
                    "Snaps": Color("AppAccent")
                ])
                .chartLegend(position: .bottom, spacing: 8)
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(DateDisplay.shortDay(date))
                            }
                        }
                        .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color("AppTextPrimary").opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
    }

    private var mixChart: some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 12) {
                Text("Roster mix")
                    .roundedTitle(17, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                Chart(model.kindShare) { slice in
                    BarMark(
                        x: .value("Count", slice.count),
                        y: .value("Kind", slice.kind)
                    )
                    .foregroundStyle(by: .value("Kind", slice.kind))
                }
                .chartForegroundStyleScale([
                    "Lessons": Color("AppPrimary"),
                    "Snaps": Color("AppAccent"),
                    "Plans": Color("AppTextSecondary")
                ])
                .chartLegend(.hidden)
                .frame(height: 140)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color("AppTextPrimary").opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
                if model.linkedSnapCount > 0 {
                    Text("\(model.linkedSnapCount) snap\(model.linkedSnapCount == 1 ? "" : "s") bridged to the roster")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color("AppTextSecondary"))
                }
            }
        }
    }

    private var upcomingCard: some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 10) {
                Text("Upcoming reminders")
                    .roundedTitle(17, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                ForEach(model.upcoming) { plan in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("AppTextPrimary"))
                                .lineLimit(1)
                            Text(DateDisplay.inked(plan.reminderDate))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
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
                }
            }
        }
    }

    private var tagsCard: some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 10) {
                Text("Hottest tags")
                    .roundedTitle(17, weight: .semibold)
                    .foregroundColor(Color("AppTextPrimary"))
                Chart(model.topTags) { item in
                    BarMark(
                        x: .value("Uses", item.count),
                        y: .value("Tag", item.tag)
                    )
                    .foregroundStyle(Color("AppPrimary"))
                }
                .frame(height: CGFloat(max(120, model.topTags.count * 28)))
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color("AppTextPrimary").opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
            }
        }
    }
}
