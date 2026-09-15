import SwiftUI

enum RosterFilter {
    static func matches(_ query: String, title: String, tags: [String]) -> Bool {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return true }
        if title.lowercased().contains(needle) { return true }
        return tags.contains { $0.lowercased().contains(needle) }
    }
}

struct RosterSearchBar: View {
    @Binding var query: String
    @Binding var subject: Subject?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("AppTextSecondary"))
                ZStack(alignment: .leading) {
                    if query.isEmpty {
                        Text("Search titles & tags")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color("AppTextPrimary").opacity(0.55))
                            .allowsHitTesting(false)
                    }
                    TextField("", text: $query)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))
                        .submitLabel(.search)
                        .onSubmit { Keyboard.dismiss() }
                }
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color("AppSurface").opacity(0.9))
            .overlay(
                Rectangle()
                    .fill(Color("AppPrimary"))
                    .frame(height: 1.4),
                alignment: .bottom
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    subjectChip(title: "All", selected: subject == nil) {
                        subject = nil
                    }
                    ForEach(Subject.allCases) { item in
                        subjectChip(title: item.rawValue, selected: subject == item) {
                            subject = item
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func subjectChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color("AppTextPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(selected ? Color("AppPrimary") : Color("AppSurface"))
                .overlay(
                    Rectangle()
                        .stroke(Color("AppPrimary"), lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
