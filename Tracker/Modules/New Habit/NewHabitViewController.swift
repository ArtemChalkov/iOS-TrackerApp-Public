//
//  NewHabitViewController.swift
//  Tracker
//

import UIKit

class TextFieldWithPadding: UITextField {
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

final class NewHabitViewController: UIViewController {
    
    var habitTypes: [String] = ["Категория", "Расписание"]
    
    //private var habitTextView = HabitTextView()
    
    
    private var createButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        
        button.setTitle("Создать", for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        //button.addTarget(nil, action: #selector(createButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Отменить", for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        //button.addTarget(nil, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
   
    
    
    private var habitTextField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название трекера"
        textField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.backgroundColor = Colors.lightGray
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0) //фикс верхнего сепаратора
        tableView.backgroundColor = Colors.lightGray
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.register(HabitTypeCell.self, forCellReuseIdentifier: HabitTypeCell.reuseId)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupNavigationItems()
    }
}

//MARK: - Navigation
private extension NewHabitViewController {
    
}

private extension NewHabitViewController {
    
    func setupNavigationItems() {
        navigationItem.title = "Новая привычка"
    }
    
    func setupViews() {
        navigationItem.setHidesBackButton(true, animated: true)
        view.backgroundColor = .systemBackground
        view.addSubview(habitTextField)
        view.addSubview(tableView)
        view.addSubview(buttonsStackView)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            habitTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            habitTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            habitTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            //habitTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: habitTextField.bottomAnchor, constant: 24),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 148)
        ])
        
        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            buttonsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitTypeCell.reuseId, for: indexPath) as? HabitTypeCell else { return UITableViewCell() }
        
        let type = habitTypes[indexPath.row]
        cell.update(type)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HabitTypeCell.height
    }
    
}

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
            
        case 1:
            
            let scheduleVC = ScheduleViewController()
            
            self.navigationController?.pushViewController(scheduleVC, animated: true)
            
        default: break
        }
    }
}
