import Planner
import SwiftUI

struct MarkdownImageView: View {
    let image: MarkdownImage
    @Environment(\.markdownBaseURL) private var baseURL
    @State private var loadedImage: MarkdownLoadedImage?
    @State private var hasFailed = false

    var body: some View {
        let url = MarkdownURLResolver.url(for: image.source, relativeTo: baseURL)
        Group {
            if let loadedImage {
                loadedImage.image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: loadedImage.size.width)
                    .clipShape(.rect(cornerRadius: 10))
            } else if hasFailed || url == nil {
                MarkdownImagePlaceholder(altText: image.altText)
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(image.altText)
        .help(image.title ?? image.altText)
        .task(id: url) {
            guard let url else { return }
            loadedImage = await MarkdownLoadedImage.load(from: url)
            hasFailed = loadedImage == nil
        }
    }
}
