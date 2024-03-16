//
//  NewHabitViewController.swift
//  Tracker
//

import UIKit

enum TrackType: Int, CaseIterable {
    case regular //habit
    case unregularTask //unregular
}

final class NewHabitViewController: UIViewController {
    
    var trackerService = TrackerService.shared
    var habitTypes: [String] = []
    var trackType: TrackType
    
    var regularTracker: Tracker?

    init(trackType: TrackType) {
        self.trackType = trackType
        
        super.init(nibName: nil, bundle: nil)
        
        switch trackType {
        case .regular:
            habitTypes = ["Категория", "Расписание"]
        case .unregularTask:
            habitTypes = ["Категория"]
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var createButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = Colors.gray
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Создать", for: .normal)
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(nil, action: #selector(createButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var cancelButton: UIButton = {
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
    
    private var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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

//MARK: - Event Handler
private extension NewHabitViewController {
    
    @objc func habitTextFieldChanged(_ textField: UITextField) {
        
        switch trackType {
        case .regular:
            if let textCount =  textField.text?.count, let schedule = regularTracker?.schedule {
                if textCount > 0, schedule.count > 0 {
                    createButton.isUserInteractionEnabled = true
                    createButton.backgroundColor = Colors.black
                } else {
                    createButton.isUserInteractionEnabled = false
                    createButton.backgroundColor = Colors.gray
                }
            }
            
        case .unregularTask:
            if let textCount =  textField.text?.count {
                if textCount > 0 {
                    createButton.isUserInteractionEnabled = true
                    createButton.backgroundColor = Colors.black
                } else {
                    createButton.isUserInteractionEnabled = false
                    createButton.backgroundColor = Colors.gray
                }
            }
        }
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func createButtonTapped() {
        createHabit()
    }
    
    func createHabit() {
        let trackerName = habitTextField.text ?? ""
        let randomUUID = UUID()
        let randomColor = Colors.randomColor()
        let randomEmoji = Emojis.randomEmoji()
        let tracker = Tracker(id: randomUUID, name: trackerName, color: randomColor, emoji: randomEmoji, schedule: [])
        print("->", tracker)
        trackerService.currentTracker = tracker
        
        if trackType == .unregularTask {
            if let tracker = trackerService.currentTracker {
                trackerService.append(tracker)
                print("->", trackerService.categories)
                NotificationCenter.default.post(name: Notification.Name("UpdateTrackersScreen"), object: nil, userInfo: nil)
                dismiss(animated: true)
            }
        }
        
        if trackType == .regular {
            if let tracker = regularTracker {
                //trackerService.append(tracker)
                print("->", trackerService.categories)
                NotificationCenter.default.post(name: Notification.Name("UpdateTrackersScreen"), object: nil, userInfo: nil)
                dismiss(animated: true)
            }
            
        }
    }
}

extension NewHabitViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("->", habitTypes.count)
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
            print("index row = 0")
            
        case 1:
            createHabit()
            let scheduleVC = ScheduleViewController()
            
            scheduleVC.onTrackerChanged = { [weak self] tracker in
                guard let self else { return }
                
                self.regularTracker = tracker
                
                if let textCount =  self.habitTextField.text?.count, let schedule = self.regularTracker?.schedule {
                    if textCount > 0, schedule.count > 0 {
                        self.createButton.isUserInteractionEnabled = true
                        self.createButton.backgroundColor = Colors.black
                    } else {
                        self.createButton.isUserInteractionEnabled = false
                        self.createButton.backgroundColor = Colors.gray
                    }
                }
                
            }
            
            
            self.navigationController?.pushViewController(scheduleVC, animated: true)
            
        default: break
        }
    }
}

//MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

private extension NewHabitViewController {
    
    func setupNavigationItems() {
        
        switch trackType {
        case .regular:
            navigationItem.title = "Новая привычка"
        case .unregularTask:
            navigationItem.title = "Новое нерегулярное событие"
        }
        
       
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
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
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: habitTextField.bottomAnchor, constant: 24),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
        
        switch trackType {
        case .regular:
            tableView.heightAnchor.constraint(equalToConstant: 148).isActive = true
        case .unregularTask:
            tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
            tableView.separatorStyle = .none
        }
        
        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            buttonsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

