import Foundation
import UIKit
import PinLayout

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addSubviews()
        
        view.backgroundColor = Colors.mainBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addConstraints()
    }
}

@objc extension BaseViewController {
    func setupUI() {
        
    }
    func addSubviews() {}
    func addConstraints() {}
}
