
import SwiftUI

struct PresetsView: View {

    private let presets = [
        ("iPad Mode", "iPad arayüzüyle ilgili desteklenen ayarlar.", "ipad"),
        ("Display", "Ekran yapılandırma bilgileri.", "display"),
        ("Device Info", "Cihaz özelliklerini incele.", "info.circle"),
        ("Wallpaper", "Duvar kâğıdı dosyalarını yönet.", "photo")
    ]

    var body: some View {
        NavigationStack {
            List {

                Section {
                    ForEach(presets, id: \.0) { preset in
                        HStack(spacing: 14) {

                            Image(systemName: preset.2)
                                .font(.title2)
                                .foregroundStyle(INJECTTheme.accent)
                                .frame(width: 42, height: 42)
                                .background(
                                    .regularMaterial,
                                    in: RoundedRectangle(cornerRadius: 12)
                                )

                            VStack(alignment: .leading, spacing: 5) {
                                Text(preset.0)
                                    .font(.headline)

                                Text(preset.1)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("Coming Soon")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                } header: {
                    Text("Available Presets")
                } footer: {
                    Text("Preset işlemleri henüz geliştirme aşamasında.")
                }
            }
            .navigationTitle("Presets")
        }
    }
}
