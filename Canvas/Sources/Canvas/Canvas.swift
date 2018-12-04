import CoreGraphics
import CoreServices
import Foundation
import ImageIO

public class Canvas {
    
    let context: CGContext
    
    public init(width: Int, height: Int) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    }
    
    public func draw(_ drawFunction: (CGContext) -> ()) {
        drawFunction(context)
    }
    
    public func save(path: String) {
        let url = URL(fileURLWithPath: path)
        save(url: url)
    }
    
    public func save(url: URL) {
        let image = context.makeImage()!
        
        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}
