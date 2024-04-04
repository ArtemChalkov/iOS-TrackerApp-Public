//
//  CreateTrackerViewController.swift
//  Tracker
//


import UIKit

final class CreateTrackerViewController: UIViewController {

    private var habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(nil, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var nonRegularButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(nil, action: #selector(nonRegularButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupNavigationItems()
    }
}

private extension CreateTrackerViewController {
    
    @objc func habitButtonTapped() {
        
        let newHabitVC = NewHabitViewController.init(trackType: .regular)
        navigationController?.pushViewController(newHabitVC, animated: true)
    }
    
    @objc func nonRegularButtonTapped() {
        let newHabitVC = NewHabitViewController.init(trackType: .unregularTask)
        
        navigationController?.pushViewController(newHabitVC, animated: true)
    }
}

private extension CreateTrackerViewController {
    
    func setupNavigationItems() {
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
    }
    
    func setupViews() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(habitButton)
        verticalStackView.addArrangedSubview(nonRegularButton)
    }
    
    func setupConstraints() {
        
        verticalStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
