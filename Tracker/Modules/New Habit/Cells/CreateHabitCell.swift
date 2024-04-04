//
//  CreateHabitCell.swift
//  textfield-in-tableview
//

import UIKit

final class CreateHabitCell: UITableViewCell {
    
    static let reuseId = "CreateHabitCell"
    
    var onCancelButtonTapped: (()->Void)?
    var onCreateButtonTapped: (()->Void)?
    
    private var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.gray
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Создать", for: .normal)
        //button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(nil, action: #selector(createButtonTapped), for: .touchUpInside)

        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(nil, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}

//MARK - Public
extension CreateHabitCell {
    
    func update(_ isConfirmButtonEnabled: Bool) {
        
        if isConfirmButtonEnabled {
            confirmButton.backgroundColor = Colors.black
            confirmButton.isEnabled = true
        } else {
            confirmButton.backgroundColor = Colors.gray
            confirmButton.isEnabled = false
        }
    }
    
}

//MARK: - Event Handler
extension CreateHabitCell {
    
    @objc func cancelButtonTapped() {
        onCancelButtonTapped?()
    }
    
    @objc func createButtonTapped() {
        print("->")
        onCreateButtonTapped?()
    }
    
}

//MARK: - Layout
extension CreateHabitCell {
    
    func setupViews() {
        //selectionStyle = .none
        
        contentView.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(confirmButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            buttonsStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            buttonsStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
