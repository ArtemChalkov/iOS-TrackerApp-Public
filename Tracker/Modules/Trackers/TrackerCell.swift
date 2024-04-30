//
//  CustomCell.swift
//  Tracker
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    
    private var tracker: Tracker?
    private var isComplete = false
    
    private var calendarDate = Date()
    
    private var days = 0 {
        willSet {
            dayLabel.text = "\(newValue.days())"
        }
    }
    
    var onTrackerStatusChanged: ((Tracker, TrackerCell)->Void)?
    
    
    private var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return view
    }()
    
    private var emojiButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.backgroundColor = .white.withAlphaComponent(0.3)
        return button
    }()
    
    private var nameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .systemBackground
        view.text = "Поливать растения"
        view.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return view
    }()
    
    private var dayLabel: UILabel = {
        let view = UILabel()
        view.textColor = .BlackDay
        view.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        view.text = "1 день"
        return view
    }()
    
    private var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 34).isActive = true
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.layer.cornerRadius = 17
        button.addTarget(nil, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .WhiteDay
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {

        [containerView, dayLabel, plusButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        [emojiButton, nameLabel, pinImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
    }
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            emojiButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: emojiButton.bottomAnchor, constant: 8),
            nameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            pinImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            pinImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
        ])
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            dayLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
        ])
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12),
            plusButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -4),
        ])
    }
    
    func update(_ tracker: Tracker, counter: Int = 0, isComplete: Bool = false, calendarDate: Date, interaction: UIInteraction) {
        
        pinImageView.isHidden = !tracker.isPinned
        
        self.tracker = tracker
        self.days = counter
        
        nameLabel.text = tracker.name
        emojiButton.setTitle(tracker.emoji, for: .normal)
        plusButton.backgroundColor = tracker.color
        containerView.backgroundColor = tracker.color
        
        containerView.addInteraction(interaction)
        
        switchAddDayButton(to: isComplete)
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        
        guard let tracker else { return }
        onTrackerStatusChanged?(tracker, self)
    }
    
    func switchAddDayButton(to isCompleted: Bool) {
        
        if isCompleted {
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.layer.opacity = 0.3
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.layer.opacity = 1
        }
    }
    
    func increaseCount() {
        days += 1
    }
    
    func decreaseCount() {
        days -= 1
    }
}

extension Int {
     func days() -> String {
         var ending: String!
         if "1".contains("\(self % 10)")      { ending = "день".localized }
         if "234".contains("\(self % 10)")    { ending = "дня".localized  }
         if "567890".contains("\(self % 10)") { ending = "дней".localized }
         if 11...14 ~= self % 100             { ending = "дней".localized }
         return "\(self) " + ending
     }
 }
