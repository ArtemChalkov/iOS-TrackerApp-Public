//
//  ScheduleCell.swift
//  Tracker
//

import UIKit

final class ScheduleCell: UITableViewCell {
    
    static let reuseId = "ScheduleCell"
    
    static let height: CGFloat = 75
    
    private var day: String?
    
    var onDaySwitchChanged: ((String, Bool)->())?
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Понедельник"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    private let daySwitch: UISwitch = {
        let control = UISwitch()
        control.isOn = false
        control.translatesAutoresizingMaskIntoConstraints = false
        //control.tintColor = Colors.blue
        //control.backgroundColor = Colors.blue
        
        control.onTintColor = Colors.blue
        
        control.addTarget(nil, action: #selector(daySwitchChanged(_:)), for: .valueChanged)
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

//MARK: - Event Handler

extension ScheduleCell {
    
    @objc func daySwitchChanged(_ sender: UISwitch) {
        
        guard let day = self.day else { return }
        
        let dayIsChoosen = sender.isOn
        
        onDaySwitchChanged?(day, dayIsChoosen)
    }
}

//MARK: - Public
extension ScheduleCell {
    func update(_ day: String) {
        self.day = day
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

