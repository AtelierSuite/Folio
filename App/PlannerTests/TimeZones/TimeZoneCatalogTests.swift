import Foundation
import Testing
@testable import Planner

struct TimeZoneCatalogTests {
    private let english = Locale(identifier: "en_US")
    private let winter = Date(timeIntervalSince1970: 1_767_225_600)

    @Test func cityZonesUseTheLocalizedCityName() throws {
        let tokyo = try #require(TimeZoneOption(identifier: "Asia/Tokyo", locale: english, date: winter))
        #expect(tokyo.cityName == "Tokyo")
        #expect(tokyo.shortLabel == "Tokyo")
        #expect(tokyo.offset == "GMT+9")
        let japanese = try #require(TimeZoneOption(identifier: "Asia/Tokyo", locale: Locale(identifier: "ja_JP")))
        #expect(japanese.cityName == "東京")
    }

    @Test func columnLabelIsTheISORegionCode() throws {
        let singapore = try #require(TimeZoneOption(identifier: "Asia/Singapore", locale: english, date: winter))
        #expect(singapore.columnLabel == "SG")
        let kolkata = try #require(TimeZoneOption(identifier: "Asia/Calcutta", locale: english, date: winter))
        #expect(kolkata.columnLabel == "IN")
    }

    @Test func knownZonesHaveARegionCode() {
        let missing = TimeZone.knownTimeZoneIdentifiers.filter {
            $0.contains("/") && TimeZoneRegions.regionCode(for: $0) == nil
        }
        #expect(missing.isEmpty)
    }

    @Test func zonesWithoutACityFallBackToTheAbbreviation() throws {
        let gmt = try #require(TimeZoneOption(identifier: "GMT", locale: english, date: winter))
        #expect(gmt.cityName == nil)
        #expect(gmt.shortLabel == "GMT")
        #expect(gmt.columnLabel == "GMT")
        #expect(gmt.displayName == gmt.regionName)
    }

    @Test func unknownIdentifierHasNoOption() {
        #expect(TimeZoneOption(identifier: "Mars/Olympus_Mons") == nil)
    }

    @Test func searchMatchesCityRegionAndIdentifier() throws {
        let losAngeles = try #require(TimeZoneOption(identifier: "America/Los_Angeles", locale: english, date: winter))
        #expect(losAngeles.matches("los ang"))
        #expect(losAngeles.matches("Pacific"))
        #expect(losAngeles.matches("america/los"))
        #expect(losAngeles.matches("  "))
        #expect(!losAngeles.matches("Tokyo"))
    }

    @Test func catalogIsSortedAndSkipsEtcZones() {
        let options = TimeZoneCatalog.options(locale: english, date: winter)
        #expect(options.count > 300)
        #expect(!options.contains { $0.identifier.hasPrefix("Etc/") })
        #expect(options.contains { $0.identifier == "Asia/Tokyo" })
        let names = options.map(\.displayName)
        #expect(names == names.sorted { $0.localizedStandardCompare($1) == .orderedAscending })
    }

    @Test func filterNarrowsTheCatalog() {
        let options = TimeZoneCatalog.options(locale: english, date: winter)
        let matches = TimeZoneCatalog.filter(options, by: "Tokyo")
        #expect(matches.map(\.identifier) == ["Asia/Tokyo"])
        #expect(TimeZoneCatalog.filter(options, by: "").count == options.count)
    }
}
