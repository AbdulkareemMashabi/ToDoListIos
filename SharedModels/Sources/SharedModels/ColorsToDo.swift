import Foundation

public enum ColorsToDo: String, Hashable, CaseIterable {
    case red
    case blue
    case orange
    case green

    public var assetName: String { rawValue }

    public var hex: String {
        switch self {
        case .red:    return "#FF3B30"
        case .blue:   return "#32ADE6"
        case .orange: return "#FF9500"
        case .green:  return "#34C759"
        }
    }
}
