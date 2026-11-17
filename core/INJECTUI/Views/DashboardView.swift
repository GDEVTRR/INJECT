
import SwiftUI

struct DashboardView: View {

    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("INJECT")
                            .font(.largeTitle.bold())

                        Text("Your device. Your control.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Device Overview", systemImage: "iphone")

                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Device")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text("iPhone")
                                        .font(.headline)
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tools")
                            .font(.title2.bold())

                        toolRow(
                            title: "Field Editor",
                            subtitle: "Explore supported property list fields",
                            icon: "slider.horizontal.3",
                            tab: 1
                        )

                        toolRow(
                            title: "Presets",
                            subtitle: "Manage ready-made configurations",
                            icon: "square.grid.2x2",
                            tab: 3
                        )

                        toolRow(
                            title: "File Manager",
                            subtitle: "Open and inspect plist files",
                            icon: "folder",
                            tab: 4
                        )
                    }
                }
                .padding()
            }
            .background(INJECTTheme.background)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func toolRow(
        title: String,
        subtitle: String,
        icon: String,
        tab: Int
    ) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(INJECTTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 14)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 20)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
