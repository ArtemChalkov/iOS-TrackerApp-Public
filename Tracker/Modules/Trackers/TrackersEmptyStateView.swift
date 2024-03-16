//
//  EmptyTrackerStateView.swift
//  Tracker
//

import UIKit

enum EmptyType {
    case empty //Вообще нет трекеров
    case error //Трекеры есть но по дате/поиску их нет
}

final class TrackersEmptyStateView: UIView {
    
    private var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty")
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(emptyStateImageView)
        self.addSubview(emptyStateLabel)
    }
    
    func setupConstraints() {
        emptyStateImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 220).isActive = true
        emptyStateImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8).isActive = true
        emptyStateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    func update(_ type: EmptyType) {
        
        switch type {
        case .empty:
            emptyStateLabel.text = "Что будем отслеживать?"
            emptyStateImageView.image = UIImage(named: "empty")
        case .error:
            emptyStateLabel.text = "Ничего не найдено"
            emptyStateImageView.image = UIImage(named: "error")
        }
    }
}
