import Foundation

import UIKit

enum ObserversDescription: String, CaseIterable {
    case newObservers = "Новые наблюдатели в этом месяце"
    case lostObservers = "Пользователей перестали за Вами наблюдать"
    case riseVisitors = "Количество посетителей в этом месяце выросло"
    case lowVisitors = "Количество посетителей в этом месяце уменьшилось"
}

enum Colors {
    static let mainBackground = Colors.color(light: .init(hex: .mainBackground), dark: .init(hex: .mainBackground))
    static let tabbarBorder = Colors.color(light: .init(hex: .tabbarBorder), dark: .init(hex: .tabbarBorder))
    static let selectedPeriodeButton = Colors.color(light: .init(hex: .selectedPeriodeButton), dark: .init(hex: .selectedPeriodeButton))
    
    static func color(light: UIColor, dark: UIColor) -> UIColor {
        
        return .init { traitCollection in
            
            return traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}

extension UIColor {
    
    enum Hex: String {
        case mainBackground = "F6F6F6"
        case tabbarBorder = "E9E9EA"
        case selectedPeriodeButton = "FF2E00"
    }
    
    convenience init(hex: Hex) {
        
        var hexString: String = hex.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.remove(at: hexString.startIndex) }
        
        var rgbValue:UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

