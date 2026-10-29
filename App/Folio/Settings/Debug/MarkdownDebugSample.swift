#if DEBUG
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

enum MarkdownDebugSample {
    static let contents = """
    ---
    event: 5A1B2C3D-0000-4000-8000-000000000001
    date: 2026-10-29
    tags: [trip, packing]
    mood: excited # unknown keys are preserved
    ---
    # Weekend Trip

    A sample note with **bold**, _italic_, ~~strikethrough~~, `inline code` and a [link](https://www.apple.com).
    Soft breaks join lines,\\
    and a backslash forces a line break.

    ## Checklist

    - [ ] Book the train
    - [x] Reserve the hotel
    - [ ] Pack
      - [ ] Charger
      - [x] Passport

    ## Itinerary

    1. Arrive on Friday
    2. Museum on Saturday
       - Buy tickets online
    3. Home on Sunday

    ### Budget

    | Item | Nights | Cost |
    |:-----|:------:|-----:|
    | Hotel | 2 | ¥24,000 |
    | Train | – | ¥8,400 |
    | **Total** | | **¥32,400** |

    #### Code

    ```swift
    let greeting = "Hello, Folio"
    print(greeting)
    ```

    > Travel is the only thing you buy that makes you richer.
    >
    > - [ ] Quoted task

    ---

    ![Folio sample image](assets/sample.png "A relative asset")

    ![Remote image](https://www.apple.com/favicon.ico)

    ##### Small heading
    ###### Smallest heading
    """

    @MainActor
    static func prepareBaseURL() -> URL? {
        let baseURL = URL.temporaryDirectory.appending(path: "MarkdownDebug", directoryHint: .isDirectory)
        let assetsURL = baseURL.appending(path: "assets", directoryHint: .isDirectory)
        let imageURL = assetsURL.appending(path: "sample.png")
        let renderer = ImageRenderer(content: MarkdownDebugSampleImage())
        renderer.scale = 2
        guard (try? FileManager.default.createDirectory(at: assetsURL, withIntermediateDirectories: true)) != nil,
              let cgImage = renderer.cgImage,
              let destination = CGImageDestinationCreateWithURL(
                imageURL as CFURL, UTType.png.identifier as CFString, 1, nil
              ) else { return nil }
        CGImageDestinationAddImage(destination, cgImage, nil)
        return CGImageDestinationFinalize(destination) ? baseURL : nil
    }
}

private struct MarkdownDebugSampleImage: View {
    var body: some View {
        Image(systemName: "book.pages")
            .font(.system(size: 64))
            .foregroundStyle(.white)
            .frame(width: 320, height: 160)
            .background(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
#endif
