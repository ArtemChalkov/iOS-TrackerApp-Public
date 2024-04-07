//
//  HabitNameCell.swift
//  textfield-in-tableview
//

import UIKit

final class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 0,
        left: 16,
        bottom: 0,
        right: 16
    )

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

class HabitNameCell: UITableViewCell {
    
    static let reuseId = "HabitNameCell"
    
    var onNameHabitFieldChanged: ((String)->Void)?
    
    private lazy var habitTextField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название трекера"
        textField.addTarget(self, action: #selector(habitTextFieldChanged(_:)), for: .editingChanged)
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.backgroundColor = Colors.lightGray
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    func update(_ nameText: String) {
        habitTextField.text = nameText
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(habitTextField)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            habitTextField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
            habitTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            habitTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            habitTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
    
}

extension HabitNameCell {
    @objc func habitTextFieldChanged(_ textField: UITextField) {
        
        guard let nameText = textField.text else { return }
        onNameHabitFieldChanged?(nameText)
    }
}

//MARK: - UITextFieldDelegate
extension HabitNameCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}
