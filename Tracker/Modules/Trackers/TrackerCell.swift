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
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return view
    }()
    
    private var iconButton: UIButton = {
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
        return view
    }()
    
    private var dayLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
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
        button.tintColor = .white
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

        [containerView, iconButton, nameLabel, dayLabel, plusButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
    }
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            iconButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: 8),
            nameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16),
            dayLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
        ])
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            plusButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
        ])
    }
    
    func update(_ tracker: Tracker, counter: Int = 0, isComplete: Bool = false, calendarDate: Date) {
        
        self.tracker = tracker
        self.days = counter
        
        nameLabel.text = tracker.name
        iconButton.setTitle(tracker.emoji, for: .normal)
        plusButton.backgroundColor = tracker.color
        containerView.backgroundColor = tracker.color
        

        switchAddDayButton(to: isComplete)
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        
        if calendarDate > Date() {
            return
        }
//
//        guard let tracker = tracker else { return }
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected {
//            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
//            sender.layer.opacity = 0.3
//        } else {
//            sender.setImage(UIImage(systemName: "plus"), for: .normal)
//            sender.layer.opacity = 1
//        }
//        let trackerStatus = sender.isSelected
        
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
         if "1".contains("\(self % 10)")      { ending = "день" }
         if "234".contains("\(self % 10)")    { ending = "дня"  }
         if "567890".contains("\(self % 10)") { ending = "дней" }
         if 11...14 ~= self % 100             { ending = "дней" }
         return "\(self) " + ending
     }
 }
