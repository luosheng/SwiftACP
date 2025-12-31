// MARK: - Content Types

import Foundation

// MARK: - Content Block

/// A block of content that can appear in messages or tool calls.
///
/// Content blocks are used in user prompts sent via `session/prompt`
/// and in language model output streamed through `session/update` notifications.
public enum ContentBlock: Codable, Sendable {
  case text(TextContent)
  case image(ImageContent)
  case audio(AudioContent)
  case resourceLink(ResourceLink)
  case resource(EmbeddedResource)

  private enum CodingKeys: String, CodingKey {
    case type
  }

  private enum ContentType: String, Codable {
    case text
    case image
    case audio
    case resourceLink = "resource_link"
    case resource
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ContentType.self, forKey: .type)

    switch type {
    case .text:
      self = .text(try TextContent(from: decoder))
    case .image:
      self = .image(try ImageContent(from: decoder))
    case .audio:
      self = .audio(try AudioContent(from: decoder))
    case .resourceLink:
      self = .resourceLink(try ResourceLink(from: decoder))
    case .resource:
      self = .resource(try EmbeddedResource(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .text(let content):
      try content.encode(to: encoder)
    case .image(let content):
      try content.encode(to: encoder)
    case .audio(let content):
      try content.encode(to: encoder)
    case .resourceLink(let content):
      try content.encode(to: encoder)
    case .resource(let content):
      try content.encode(to: encoder)
    }
  }
}

// MARK: - Text Content

/// Text content block.
public struct TextContent: Codable, Sendable {
  private let type: String = "text"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional annotations for the content.
  public var annotations: Annotations?

  /// The text content.
  public var text: String

  public init(
    _meta: Meta = nil,
    annotations: Annotations? = nil,
    text: String
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.text = text
  }
}

// MARK: - Image Content

/// Image content block.
public struct ImageContent: Codable, Sendable {
  private let type: String = "image"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional annotations for the content.
  public var annotations: Annotations?

  /// Base64-encoded image data.
  public var data: String?

  /// The MIME type of the image.
  public var mimeType: String

  /// URI reference to the image.
  public var uri: String?

  public init(
    _meta: Meta = nil,
    annotations: Annotations? = nil,
    data: String? = nil,
    mimeType: String,
    uri: String? = nil
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.data = data
    self.mimeType = mimeType
    self.uri = uri
  }
}

// MARK: - Audio Content

/// Audio content block.
public struct AudioContent: Codable, Sendable {
  private let type: String = "audio"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional annotations for the content.
  public var annotations: Annotations?

  /// Base64-encoded audio data.
  public var data: String

  /// The MIME type of the audio.
  public var mimeType: String

  public init(
    _meta: Meta = nil,
    annotations: Annotations? = nil,
    data: String,
    mimeType: String
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.data = data
    self.mimeType = mimeType
  }
}

// MARK: - Resource Link

/// A link to a resource.
public struct ResourceLink: Codable, Sendable {
  private let type: String = "resource_link"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional annotations for the content.
  public var annotations: Annotations?

  /// Optional description of the resource.
  public var description: String?

  /// The MIME type of the resource.
  public var mimeType: String?

  /// The name of the resource.
  public var name: String?

  /// The size of the resource in bytes.
  public var size: Int?

  /// The title of the resource.
  public var title: String?

  /// The URI of the resource.
  public var uri: String

  public init(
    _meta: Meta = nil,
    annotations: Annotations? = nil,
    description: String? = nil,
    mimeType: String? = nil,
    name: String? = nil,
    size: Int? = nil,
    title: String? = nil,
    uri: String
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.description = description
    self.mimeType = mimeType
    self.name = name
    self.size = size
    self.title = title
    self.uri = uri
  }
}

// MARK: - Embedded Resource

/// An embedded resource with its contents.
public struct EmbeddedResource: Codable, Sendable {
  private let type: String = "resource"

  /// Extensible metadata field.
  public var _meta: Meta

  /// Optional annotations for the content.
  public var annotations: Annotations?

  /// The resource contents.
  public var resource: EmbeddedResourceResource

  public init(
    _meta: Meta = nil,
    annotations: Annotations? = nil,
    resource: EmbeddedResourceResource
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.resource = resource
  }
}

// MARK: - Embedded Resource Resource

/// The contents of an embedded resource, either text or binary.
public enum EmbeddedResourceResource: Codable, Sendable {
  case text(TextResourceContents)
  case blob(BlobResourceContents)

  public init(from decoder: Decoder) throws {
    // Try to decode as text first (has 'text' field)
    if let text = try? TextResourceContents(from: decoder) {
      self = .text(text)
    } else {
      self = .blob(try BlobResourceContents(from: decoder))
    }
  }

  public func encode(to encoder: Encoder) throws {
    switch self {
    case .text(let contents):
      try contents.encode(to: encoder)
    case .blob(let contents):
      try contents.encode(to: encoder)
    }
  }
}

// MARK: - Text Resource Contents

/// Text-based resource contents.
public struct TextResourceContents: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The MIME type of the text content.
  public var mimeType: String?

  /// The text content.
  public var text: String

  /// The URI of the resource.
  public var uri: String

  public init(
    _meta: Meta = nil,
    mimeType: String? = nil,
    text: String,
    uri: String
  ) {
    self._meta = _meta
    self.mimeType = mimeType
    self.text = text
    self.uri = uri
  }
}

// MARK: - Blob Resource Contents

/// Binary resource contents.
public struct BlobResourceContents: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Base64-encoded binary data.
  public var blob: String

  /// The MIME type of the blob content.
  public var mimeType: String?

  /// The URI of the resource.
  public var uri: String

  public init(
    _meta: Meta = nil,
    blob: String,
    mimeType: String? = nil,
    uri: String
  ) {
    self._meta = _meta
    self.blob = blob
    self.mimeType = mimeType
    self.uri = uri
  }
}

// MARK: - Annotations

/// Optional annotations for the client.
///
/// The client can use annotations to inform how objects are used or displayed.
public struct Annotations: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// Describes who the intended audience is for the content.
  public var audience: [Role]?

  /// ISO 8601 timestamp of when the content was last modified.
  public var lastModified: String?

  /// Priority hint for display ordering.
  public var priority: Double?

  public init(
    _meta: Meta = nil,
    audience: [Role]? = nil,
    lastModified: String? = nil,
    priority: Double? = nil
  ) {
    self._meta = _meta
    self.audience = audience
    self.lastModified = lastModified
    self.priority = priority
  }
}

// MARK: - Role

/// The role of a participant in the conversation.
public enum Role: String, Codable, Sendable {
  case user
  case assistant
}

// MARK: - Content

/// A wrapper for an array of content blocks.
public struct Content: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The content blocks.
  public var content: [ContentBlock]

  public init(_meta: Meta = nil, content: [ContentBlock]) {
    self._meta = _meta
    self.content = content
  }
}

// MARK: - Content Chunk

/// A chunk of content for streaming updates.
public struct ContentChunk: Codable, Sendable {
  /// Extensible metadata field.
  public var _meta: Meta

  /// The content blocks in this chunk.
  public var content: [ContentBlock]

  public init(_meta: Meta = nil, content: [ContentBlock]) {
    self._meta = _meta
    self.content = content
  }
}
