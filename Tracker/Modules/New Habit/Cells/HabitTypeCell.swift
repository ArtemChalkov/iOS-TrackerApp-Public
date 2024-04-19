//
//  HabitTypeCell.swift
//  Tracker
//

import UIKit

final class HabitTypeCell: UITableViewCell {
    
    static let reuseId = "HabitTypeCell"
    static let height: CGFloat = 75
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let scheduleLabel: UILabel = {
        let label = UILabel()
        //label.text = ""
        label.textColor = Colors.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        //stackView.spacing = 2
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
extension HabitTypeCell {
    func update(_ type: String, _ weekday: [DayOfWeek], _ categoryName: String) {
        typeLabel.text = type
        
        
        if type == "Категория" {
            scheduleLabel.text = categoryName
        }
        
        if type == "Расписание" {
            var values: [String] = []
            for day in weekday {
                let value = day.shortDay()
                values.append(value)
            }
            scheduleLabel.text = values.joined(separator: ", ")
        }
    }
}

//MARK: - Layout
extension HabitTypeCell {
    
    func setupStyles() {
        selectionStyle = .none
        layer.backgroundColor = UIColor.clear.cgColor
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setupViews() {
        contentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(typeLabel)
        verticalStackView.addArrangedSubview(scheduleLabel)
    }
    
    func setupConstraints() {
        verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        //typeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        //contentView.heightAnchor.constraint(equalToConstant: HabitTypeCell.height).isActive = true
    }
}


