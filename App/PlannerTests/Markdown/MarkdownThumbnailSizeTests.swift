import CoreGraphics
import Testing
@testable import Planner

struct MarkdownThumbnailSizeTests {
    private let landscape = MarkdownThumbnailSize(imageWidth: 4032, imageHeight: 3024, isRotated: false)

    @Test func roundsPixelWidthUpInSteps() {
        #expect(MarkdownThumbnailSize.pixelWidth(forPointWidth: 370, scale: 3) == 1280)
        #expect(MarkdownThumbnailSize.pixelWidth(forPointWidth: 640, scale: 2) == 1280)
        #expect(MarkdownThumbnailSize.pixelWidth(forPointWidth: 0, scale: 3) == 0)
    }

    @Test func fitsLandscapeImageToWidth() {
        #expect(landscape.maxPixelSize(fittingWidth: 1280) == 1280)
        #expect(!landscape.isFullSize(fittingWidth: 3500))
    }

    @Test func fitsPortraitImageByItsHeight() {
        let portrait = MarkdownThumbnailSize(imageWidth: 3024, imageHeight: 4032, isRotated: false)
        #expect(portrait.maxPixelSize(fittingWidth: 1260) == 1680)
    }

    @Test func swapsSidesForRotatedImages() {
        let rotated = MarkdownThumbnailSize(imageWidth: 4032, imageHeight: 3024, isRotated: true)
        #expect(rotated.maxPixelSize(fittingWidth: 1260) == 1680)
        #expect(rotated.isFullSize(fittingWidth: 3500))
    }

    @Test func neverUpscalesSmallImages() {
        let small = MarkdownThumbnailSize(imageWidth: 600, imageHeight: 400, isRotated: false)
        #expect(small.maxPixelSize(fittingWidth: 1280) == 600)
        #expect(small.isFullSize(fittingWidth: 1280))
    }
}
