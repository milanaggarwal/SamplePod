import AVFoundation

public extension CVPixelBuffer {
    
    /// Create an identically-sized pixel buffer.
    func emptyClone() -> CVPixelBuffer? {
        var newBuffer: CVPixelBuffer?
        _ = CVPixelBufferCreate(kCFAllocatorDefault,
                                CVPixelBufferGetWidth(self),
                                CVPixelBufferGetHeight(self),
                                CVPixelBufferGetPixelFormatType(self),
                                nil,
                                &newBuffer)
        return newBuffer
    }
}
