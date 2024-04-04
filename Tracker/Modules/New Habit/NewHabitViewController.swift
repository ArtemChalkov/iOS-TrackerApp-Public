//
//  ViewController.swift
//  textfield-in-tableview
//


import UIKit

enum TrackType: Int, CaseIterable {
    case regular //habit
    case unregular //unregular
}

enum NewHabitSection: Int, CaseIterable {
    case name = 0
    case habitType = 1
    case emojis = 2
    case colors = 3
    case buttons = 4
}

final class NewHabitViewController: UIViewController {
    
    //MARK: Data Models
    private var habitTypes: [String] = [] //["Категория", "Расписание"]
    private var trackType: TrackType
    
    //Трекер собираем c пустой модели
    private var data: Tracker.Data = Tracker.Data() {
        didSet {
            checkFormValidation()
        }
    }
    
    //Кнопка создания трекера включена или выключена
    private var isConfirmButtonEnabled: Bool = false {
        didSet {
            updateConfirmButtonInTableView()
        }
    }
     
    //Рандомная категория
    private lazy var category: TrackerCategory? = trackerCategoryStore.categories.randomElement() {
        didSet {
            checkFormValidation()
        }
    }
    
    //MARK: Services
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    
    
    init(trackType: TrackType) {
        self.trackType = trackType
        
        super.init(nibName: nil, bundle: nil)
        
        switch trackType {
        case .regular:
            habitTypes = ["Категория", "Расписание"]
        case .unregular:
            habitTypes = ["Категория"]
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0) //фикс верхнего сепаратора
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(HabitNameCell.self, forCellReuseIdentifier: HabitNameCell.reuseId)
        tableView.register(EmojisCell.self, forCellReuseIdentifier: EmojisCell.reuseId)
        tableView.register(ColorsCell.self, forCellReuseIdentifier: ColorsCell.reuseId)
        tableView.register(CreateHabitCell.self, forCellReuseIdentifier: CreateHabitCell.reuseId)
        tableView.register(HabitTypeContainerCell.self, forCellReuseIdentifier: HabitTypeContainerCell.reuseId)
    
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupNavigationItems()
        
        //addTapGestureToHideKeyboard()
    }
}

//MARK: - Business Logic
extension NewHabitViewController {
    
    private func checkFormValidation() {
        if data.name.count == 0 {
            isConfirmButtonEnabled = false
            return
        }
//        if isValidationMessageVisible {
//            isConfirmButtonEnabled = false
//            return
//        }
        if category == nil || data.emoji == nil || data.color == nil {
            isConfirmButtonEnabled = false
            return
        }
        
        print(data.schedule)
        
        if trackType == .regular {
            let schedule = data.schedule ?? []
            if schedule.isEmpty {
                isConfirmButtonEnabled = false
                return
            }
        }
        
        isConfirmButtonEnabled = true
        
        print("-> Validation", isConfirmButtonEnabled)
    }
    
    func updateConfirmButtonInTableView() {
        
        let sectionIndex = NewHabitSection.buttons.rawValue
        let indexPath = IndexPath(row: 0, section: sectionIndex)
        
        self.tableView.reloadRows(at: [indexPath],
                                  with: .fade)
    }
    
    
}

//MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewHabitSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let sectionType = NewHabitSection(rawValue: indexPath.section) {
            
            switch sectionType {
                
            case .name:
                let cell = HabitNameCell.init(style: .default, reuseIdentifier: HabitNameCell.reuseId)
                
                cell.onNameHabitFieldChanged = { [weak self] nameText in
                    
                    self?.data.name = nameText
                    print("->", self?.data)
                }
                
                return cell
                
            case .habitType:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitTypeContainerCell.reuseId, for: indexPath) as? HabitTypeContainerCell else { return UITableViewCell() }
                
                cell.onCategoryCellSelected = {
                    print("->", "Category")
                }
                
                cell.onScheduleCellSelected = { [weak self] in
                    print("->", "Schedule")
                    
                    self?.scheduleButtonTapped()
                }
                
                cell.update(habitTypes)
                
                return cell
                
  
            case .emojis:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: EmojisCell.reuseId, for: indexPath) as? EmojisCell else { return UITableViewCell() }
                
                cell.onEmojiCellSelected = { [weak self] emoji in
                
                    self?.data.emoji = emoji.symbol
                    print("->", self?.data)
                }
                
                return cell
                
            case .colors:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorsCell.reuseId, for: indexPath) as? ColorsCell else { return UITableViewCell() }
                
                cell.onColorCellSelected = { [weak self] color in
                    
                    self?.data.color = color.color
                    print("->", self?.data)
                }
                
                return cell
                
            case .buttons:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateHabitCell.reuseId, for: indexPath) as? CreateHabitCell else { return UITableViewCell() }
                
                cell.update(isConfirmButtonEnabled)
                
                cell.onCancelButtonTapped = {
                    print("->", "Cancel")
                }
                
                cell.onCreateButtonTapped = { [weak self] in
                    
                    guard let self else { return }
                    print("->", "Create")
                    self.createButtonTapped()
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}
//MARK: - Event Handler
extension NewHabitViewController {
    
    func scheduleButtonTapped() {
        view.endEditing(true)
        
        let schedule = self.data.schedule ?? []
        let scheduleVC = ScheduleViewController()
        scheduleVC.onScheduleChanged = { [weak self] schedule in
            self?.data.schedule = schedule
            print(self?.data)
        }
        self.navigationController?.pushViewController(scheduleVC, animated: true)
        
        scheduleVC.update(schedule)
    }
    
    func createButtonTapped() {
        
        print("->", "Create")
        
        guard let category, let emoji = data.emoji, let color = data.color else { return }
        
        let newTracker = Tracker(
            name: data.name,
            emoji: emoji,
            color: color,
            daysCount: 0,
            schedule: data.schedule
        )
        
        try? trackerStore.addTracker(newTracker, with: category) //Будет добавлен в трекер если модели не пустые
        
        dismiss(animated: true)
    }
}

extension NewHabitViewController: UITableViewDelegate {
    
   
}

//MARK: - Layout
extension NewHabitViewController {
    
    func setupNavigationItems() {
        
        switch trackType {
        case .regular:
            navigationItem.title = "Новая привычка"
        case .unregular:
            navigationItem.title = "Новое нерегулярное событие"
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
    }
    
    func setupViews() {
        navigationItem.setHidesBackButton(true, animated: true)
        view.backgroundColor = .systemBackground
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}
