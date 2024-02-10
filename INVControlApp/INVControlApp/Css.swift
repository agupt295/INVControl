import SwiftUI

enum ButtonStyle {
    case normal
    case highlighted
    case disabled
    case warning
    
    var backgroundColor: Color {
        switch self {
        case .normal:
            return Color.blue
        case .highlighted:
            return Color.yellow
        case .disabled:
            return Color.gray
        case .warning:
            return Color.red
        }
    }
    
    var textColor: Color {
        switch self {
        case .normal, .disabled, .warning:
            return Color.white
        case .highlighted:
            return Color.red
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .normal, .highlighted, .disabled, .warning: return 5
        }
    }
}
