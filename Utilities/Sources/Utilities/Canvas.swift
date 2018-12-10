import CoreGraphics
import CoreServices
import Foundation
import ImageIO

public class Canvas {
    
    let context: CGContext
    let width: Int
    let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    }
    
    public func draw(_ drawFunction: (CGContext, Canvas) -> ()) {
        context.saveGState()
        drawFunction(context, self)
        context.restoreGState()
    }
    
    public func invert() {
        context.translateBy(x: 0.0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
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
