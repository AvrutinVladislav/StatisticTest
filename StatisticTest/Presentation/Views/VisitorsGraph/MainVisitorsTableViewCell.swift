import UIKit
import PinLayout

final class MainVisitorsTableViewCell: UITableViewCell {
    
    static let identifier = "MainVisitorsTableViewCell"
    
    private let avatarImageView = UIImageView()
    private let visitorNameLabel = UILabel()
    private let rightArrowButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(model: MainVisitor) {
        if let url = model.avatarImg {
            getAvatarFromURL(urlString: url) { [weak self] image in
                guard let image else {
                    print("Error to load avatar")
                    return
                }
                self?.avatarImageView.image = image
            }
        } else {
            print("==== Error to load avatar url string ====")
        }
        visitorNameLabel.text = "\(model.name), \(model.visitsCount)"
        rightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    }
}

extension MainVisitorsTableViewCell {
    
    private func setupUI() {
        let separator = UIView()
        separator.backgroundColor = Colors.tabbarBorder
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20
        
        rightArrowButton.tintColor = .systemGray
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(visitorNameLabel)
        contentView.addSubview(rightArrowButton)
        
        contentView.pin.height(62)
        
        avatarImageView.pin
            .vertically(12)
            .start(16)
            .height(38)
            .width(38)
        
        visitorNameLabel.pin
            .after(of: avatarImageView)
            .marginLeft(8)
            .vCenter()
            .height(20)
            .width(contentView.frame.width - avatarImageView.frame.width - rightArrowButton.frame.width - 24)
        
        rightArrowButton.pin
            .start(to: visitorNameLabel.edge.end)
            .vCenter()
            .end()
            .height(16)
            .width(10)
    }
    
    func getAvatarFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
               completion(nil)
               return
           }
           URLSession.shared.dataTask(with: url) { data, response, error in
               guard let data, error == nil else {
                   completion(nil)
                   return
               }
               let image = UIImage(data: data)
               DispatchQueue.main.async {
                   completion(image)
               }
           }.resume()
    }
}
