import SwiftUI

struct BoardView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var model = BoardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if model.grandTotal == 0 {
                    EmptyPlaceholder(
                        title: "The board is still blank",
                        symbol: "square.grid.2x2",
                        hint: "Tag a lesson, ink a snap, or file a plan — counts stay honest."
                    )
                }
                ForEach(model.clusters) { cluster in
                    clusterCard(cluster)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
            Text("Insights by subject")
                .roundedTitle(20)
                .foregroundColor(Color("AppTextPrimary"))
            Text("\(model.grandTotal) pieces across the roster")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color("AppTextSecondary"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 132, alignment: .bottomLeading)
        .background {
            Color("AppSurface")
                .overlay {
                    Image("tile_textbooks")
                        .resizable()
                        .scaledToFill()
                        .allowsHitTesting(false)
                }
                .overlay {
                    LinearGradient(
                        colors: [
                            Color("AppBackground").opacity(0.1),
                            Color("AppBackground").opacity(0.82)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipped()
        }
        .clipShape(ParallelogramChip())
        .overlay(ParallelogramChip().stroke(Color("AppPrimary"), lineWidth: 1.3))
        .pinkGlow()
    }

    private func clusterCard(_ cluster: BoardViewModel.Cluster) -> some View {
        LayeredSurface {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    SubjectChip(subject: cluster.subject)
                    Spacer()
                    Text("\(cluster.total)")
                        .roundedTitle(22)
                        .foregroundColor(Color("AppPrimary"))
                }
                HStack(spacing: 10) {
                    countStamp("Lessons", cluster.lessonCount)
                    countStamp("Snaps", cluster.snapCount)
                    countStamp("Plans", cluster.planCount)
                }
                if cluster.revisionCount > 0 {
                    Text("\(cluster.revisionCount) plan\(cluster.revisionCount == 1 ? "" : "s") marked for revision")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AppPrimary"))
                }
                if !cluster.titles.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(cluster.titles.enumerated()), id: \.offset) { _, title in
                            Text("· \(title)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color("AppTextPrimary"))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private func countStamp(_ label: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .roundedTitle(16)
                .foregroundColor(Color("AppTextPrimary"))
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
