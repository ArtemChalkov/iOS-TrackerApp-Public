//
//  CustomCell.swift
//  Tracker
//

import UIKit

class TrackerCell: UICollectionViewCell {
        
    static let identifier = "TrackerCell"
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return view
    }()
    
    private var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon-1")
        view.heightAnchor.constraint(equalToConstant: 24).isActive = true
        view.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return view
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
        let view = UIButton()
        view.setImage(UIImage(named: "plus-button"), for: .normal)
        view.setImage(UIImage(named: "done-button"), for: .selected)
        view.addTarget(nil, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
        return view
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

        [containerView, iconImageView, nameLabel, dayLabel, plusButton].forEach { view in
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
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
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
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
    }
}
