import SwiftUI

struct GlassCard<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: INJECTTheme.cornerRadius)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: INJECTTheme.cornerRadius)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    }
            }
    }
}