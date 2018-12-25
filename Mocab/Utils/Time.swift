import Foundation

struct Time {
    let seconds: Double
    
    init(
        days: Double = 0,
        hours: Double = 0,
        minutes: Double = 0,
        seconds: Double = 0
    ) {
        self.seconds = (((((days * 24) + hours) * 60) + minutes) * 60) + seconds
    }
    
    func toSeconds() -> Double { return seconds }
}
