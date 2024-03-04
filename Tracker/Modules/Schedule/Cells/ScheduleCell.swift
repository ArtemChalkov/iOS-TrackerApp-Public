//
//  ScheduleCell.swift
//  Tracker
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    static let reuseId = "ScheduleCell"
    
    static let height: CGFloat = 75
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Понедельник"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    private let daySwitch: UISwitch = {
        let control = UISwitch()
        control.isOn = false
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyles()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Public
extension ScheduleCell {
    func update(_ day: String) {
        dayLabel.text = day
    }
}

//MARK: - Layout
extension ScheduleCell {
    
    func setupStyles() {
        selectionStyle = .none
        layer.backgroundColor = UIColor.clear.cgColor
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setupViews() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
    }
    
    func setupConstraints() {
        
        dayLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        
        contentView.heightAnchor.constraint(equalToConstant: ScheduleCell.height).isActive = true
        
        daySwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16).isActive = true
        daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        
        daySwitch.widthAnchor.constraint(equalToConstant:51).isActive = true
    }
}

