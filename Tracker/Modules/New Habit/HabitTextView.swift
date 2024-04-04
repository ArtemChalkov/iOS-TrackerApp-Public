//
//  HabitTextView.swift
//  Tracker
//

import UIKit

final class HabitTextView: UIView {
   
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите название трекера"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var nameTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.backgroundColor = Colors.lightGray
        textView.text = "Текст"
        textView.textColor = UIColor.black
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // Инициализация
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyles()
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.nameTextView.isScrollEnabled = false
        self.nameTextView.sizeToFit()
        self.nameTextView.isScrollEnabled = true
    }
    
    // Общая инициализация
    private func setupStyles() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .orange
    }
    
    func setupViews() {
        addSubview(nameTextView)
    }
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            nameTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            nameTextView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            nameTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            nameTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
}

extension HabitTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}


extension HabitTextView {
    func update(_ text: String) {
        self.nameTextView.text = text
    }
}
