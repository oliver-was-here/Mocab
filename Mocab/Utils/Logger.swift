import Foundation

enum Status: String {
    case error
}

func log(
    _ status: Status,
    _ message: String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    print("\(status.rawValue.uppercased())-\(file)-\(function)-\(line): \(message)")
}
