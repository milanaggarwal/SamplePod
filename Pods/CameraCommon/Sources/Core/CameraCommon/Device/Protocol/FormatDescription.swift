import AVFoundation

/// Abstract the `CMFormatDescription` type.
///
public protocol FormatDescription {
    
    var mediaType: FourCharCode { get }
    
    var mediaSubType: FourCharCode { get }
    
    var cmDescription: CMFormatDescription? { get }
}

extension CMFormatDescription: FormatDescription {
    
    public var mediaType: FourCharCode {
        return CMFormatDescriptionGetMediaType(self)
    }
    
    public var mediaSubType: FourCharCode {
        return CMFormatDescriptionGetMediaSubType(self)
    }
    
    public var cmDescription: CMFormatDescription? { self }
}
