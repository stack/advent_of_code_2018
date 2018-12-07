import Canvas
import Foundation

public class Animator {
    
    var name: String
    var width: Int
    var height: Int
    var rate: String
    
    var canvas: Canvas
    var directory: URL
    var frame: Int
    
    public init(name: String, width: Int, height: Int, rate: String) {
        self.name = name
        self.width = width
        self.height = height
        self.rate = rate
        
        canvas = Canvas(width: width, height: height)
        directory = URL(fileURLWithPath: "./\(name).temp")
        frame = 0
        
        let manager = FileManager.default
        try? manager.removeItem(at: directory)
        try! manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func cleanup() {
        try? FileManager.default.removeItem(at: directory)
    }
    
    public func draw(_ drawFunction: (CGContext, Canvas) -> ()) {
        canvas.draw(drawFunction)
    }
    
    public func finalize() {
        let input = directory.appendingPathComponent("%08d.png").path
        
        let process = Process()
        process.launchPath = "/usr/local/bin/ffmpeg"
        process.arguments = [
            "-r",
            rate,
            "-y",
            "-i",
            input,
            "-c:v",
            "libx264",
            "-vf",
            "fps=30",
            "-pix_fmt",
            "yuv420p",
            "\(name).mp4"
        ]
        
        process.launch()
        process.waitUntilExit()
    }
    
    public func snap() {
        let url = directory.appendingPathComponent(String(format: "%08i.png", frame))
        frame += 1
        
        canvas.save(url: url)
    }
}
