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
    
    var onTrackerStatusChanged: ((Tracker, Bool)->Void)?
    
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
        self.isComplete = isComplete
        self.calendarDate = calendarDate
        
        plusButton.isSelected = isComplete
        
        if plusButton.isSelected {
            
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.layer.opacity = 0.3
            
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.layer.opacity = 1
        }
        
        self.tracker = tracker
        nameLabel.text = tracker.name
        containerView.backgroundColor = tracker.color
        
        dayLabel.text = "\(counter) дня"
        iconButton.setTitle(tracker.emoji, for: .normal)
        
        //plusButton.tintColor = tracker.color
        plusButton.backgroundColor = tracker.color
        
        
        
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        
        if calendarDate > Date() {
            return
        }
        
        
        guard let tracker = tracker else { return }
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
            sender.layer.opacity = 0.3
            
        } else {
            sender.setImage(UIImage(systemName: "plus"), for: .normal)
            sender.layer.opacity = 1
        }
        
        let trackerStatus = sender.isSelected
        
        onTrackerStatusChanged?(tracker, trackerStatus)
    }
}
