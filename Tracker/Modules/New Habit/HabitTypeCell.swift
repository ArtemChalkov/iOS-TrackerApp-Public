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
    func update(_ type: String) {
        typeLabel.text = type
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
        contentView.addSubview(typeLabel)
    }
    
    func setupConstraints() {
        typeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        typeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: HabitTypeCell.height).isActive = true
    }
}


