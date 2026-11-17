import SwiftUI

struct INJECTRootView: View {

    @AppStorage("injectAppearance")
    private var appearance = "dark"

    @State private var selectedTab = 0
    @StateObject private var engine = INJECTEngine()

    var body: some View {
        TabView(selection: $selectedTab) {

            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "square.grid.2x2")
                }
                .tag(0)

            FieldEditorView(engine: engine)
                .tabItem {
                    Label("Fields", systemImage: "slider.horizontal.3")
                }
                .tag(1)

            ChangesView(engine: engine)
                .tabItem {
                    Label("Changes", systemImage: "arrow.left.arrow.right")
                }
                .tag(2)

            PresetsView()
                .tabItem {
                    Label("Presets", systemImage: "square.stack.3d.up")
                }
                .tag(3)

            FileManagerView(engine: engine)
                .tabItem {
                    Label("Files", systemImage: "folder")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(5)
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}