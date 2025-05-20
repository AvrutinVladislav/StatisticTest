import UIKit

final class VisitorsGraphView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("===== Error init VisitorsGraphView")
    }
}

extension VisitorsGraphView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        
    }
}
