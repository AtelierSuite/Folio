import AppIntents
import CoreSpotlight
import UniformTypeIdentifiers

extension NoteEntity {
    public var attributeSet: CSSearchableItemAttributeSet {
        let attributes = defaultAttributeSet
        attributes.contentType = UTType.text.identifier
        attributes.title = title
        attributes.displayName = title
        attributes.contentDescription = excerpt
        attributes.textContent = plainText
        attributes.keywords = tags
        attributes.contentCreationDate = date
        attributes.contentModificationDate = modifiedDate
        return attributes
    }
}
