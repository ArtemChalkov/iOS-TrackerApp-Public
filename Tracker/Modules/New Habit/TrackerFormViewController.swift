//
//  ViewController.swift
//  textfield-in-tableview
//

import UIKit

protocol TrackerFormViewControllerDelegate: AnyObject {
    func didTapCancelButton()
    func didAddTracker(category: TrackerCategory, trackerToAdd: Tracker)
    func didUpdateTracker(with data: Tracker.Data)
}

enum TrackerType: Int, CaseIterable {
    case habit //habit
    case unregularEvent //unregular
}

enum NewHabitSection: Int, CaseIterable {
    case name = 0
    case habitType = 1
    case emojis = 2
    case colors = 3
    case buttons = 4
}

extension TrackerFormViewController {
    enum ActionType {
        case add, edit
    }
}

final class TrackerFormViewController: UIViewController {
    
    //MARK: Data Models
    private var habitTypes: [String] = [] //["Категория", "Расписание"]
   
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
     
//    //Рандомная категория
//    private lazy var category: TrackerCategory? = trackerCategoryStore.categories.randomElement() {
//        didSet {
//            checkFormValidation()
//        }
//    }
    
    //MARK: Services
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    
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
        tableView.register(EmojiContainerCell.self, forCellReuseIdentifier: EmojiContainerCell.reuseId)
        tableView.register(ColorContainerCell.self, forCellReuseIdentifier: ColorContainerCell.reuseId)
        tableView.register(CreateHabitCell.self, forCellReuseIdentifier: CreateHabitCell.reuseId)
        tableView.register(HabitTypeContainerCell.self, forCellReuseIdentifier: HabitTypeContainerCell.reuseId)
        return tableView
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupNavigationItems()
        
    }
    
    private let setAction: ActionType
    private let trackerType: TrackerType
    weak var delegate: TrackerFormViewControllerDelegate?
    
    // MARK: - Lifecycle
    init(ActionType: TrackerFormViewController.ActionType, trackerType: TrackerType, data: Tracker.Data?) {
        self.setAction = ActionType
        self.trackerType = trackerType
        self.data = data ?? Tracker.Data()
        
        switch trackerType {
        case .habit:
            habitTypes = ["Категория", "Расписание"]
        case .unregularEvent:
            habitTypes = ["Категория"]
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.checkFormValidation()
    }
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        self.setAction = .add
        
        super.init(nibName: nil, bundle: nil)
        
        switch trackerType {
        case .habit:
            habitTypes = ["Категория", "Расписание"]
        case .unregularEvent:
            habitTypes = ["Категория"]
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Business Logic
extension TrackerFormViewController {
    
    private func checkFormValidation() {
        if data.name.count == 0 {
            isConfirmButtonEnabled = false
            return
        }
//        if isValidationMessageVisible {
//            isConfirmButtonEnabled = false
//            return
//        }
        if data.category == nil || data.emoji == nil || data.color == nil {
            isConfirmButtonEnabled = false
            return
        }
        
        print(data.schedule)
        
        if trackerType == .habit {
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
extension TrackerFormViewController: UITableViewDataSource {
    
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
                
                cell.update(data.name)
                
                return cell
                
            case .habitType:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitTypeContainerCell.reuseId, for: indexPath) as? HabitTypeContainerCell else { return UITableViewCell() }
                
                cell.onCategoryCellSelected = {
                    print("->", "Category")
                    self.categoryCellSelected()
                }
                
                cell.onScheduleCellSelected = { [weak self] in
                    print("->", "Schedule")
                    
                    self?.scheduleButtonTapped()
                }
                
                let schedule = data.schedule ?? []
                let categoryName = data.category?.name ?? ""
                
                cell.update(habitTypes, schedule, categoryName)
                
                return cell
                
  
            case .emojis:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: EmojiContainerCell.reuseId, for: indexPath) as? EmojiContainerCell else { return UITableViewCell() }
                
                cell.onEmojiCellSelected = { [weak self] emoji in
                
                    self?.data.emoji = emoji.symbol
                    print("->", self?.data)
                }
                
                if let emoji = data.emoji {
                    cell.update(emoji)
                }
                
                return cell
                
            case .colors:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ColorContainerCell.reuseId, for: indexPath) as? ColorContainerCell else { return UITableViewCell() }
                
                if let color = self.data.color {
                    print(color.rgb())
                    cell.update(color)
                }
                
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
                    self.dismiss(animated: true)
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
extension TrackerFormViewController {
    
    func categoryCellSelected() {
        
        let category = data.category
        print(category)
        let setCategoriesViewController = SetCategoriesViewController(selectedCategory: category)
        setCategoriesViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: setCategoriesViewController)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
    
    func scheduleButtonTapped() {
        view.endEditing(true)
        
        let schedule = self.data.schedule ?? []
        let scheduleVC = ScheduleViewController()
        scheduleVC.onScheduleChanged = { [weak self] schedule in
            
            self?.data.schedule = schedule
            print(self?.data)
            self?.tableView.reloadData()
        }
        self.navigationController?.pushViewController(scheduleVC, animated: true)
        
        scheduleVC.update(schedule)
    }
    
    func createButtonTapped() {
        
        switch setAction {
        case .add: addTracker()
        case .edit: editTracker()
        }
    }
    
    func addTracker() {
        print("->", "Create")
        
        guard let category = data.category, let emoji = data.emoji, let color = data.color else { return }

        let newTracker = Tracker(
            name: data.name,
            emoji: emoji,
            color: color,
            category: category,
            isPinned: false,
            daysCount: 0,
            schedule: data.schedule
        )
        
        try? trackerStore.addTracker(newTracker, with: category) //Будет добавлен в трекер если модели не пустые
        
        dismiss(animated: true)
        
        delegate?.didAddTracker(category: category, trackerToAdd: newTracker)
    }
}

extension TrackerFormViewController: UITableViewDelegate {
    
    private func editTracker() {
        delegate?.didUpdateTracker(with: data)
    }
   
}

//MARK: - Layout
extension TrackerFormViewController {
    
    func setupNavigationItems() {
        
        switch trackerType {
        case .habit:
            navigationItem.title = "Новая привычка"
        case .unregularEvent:
            navigationItem.title = "Новое нерегулярное событие"
        }
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
    }
    
    func setupViews() {
        navigationItem.setHidesBackButton(true, animated: true)
        view.backgroundColor = .systemBackground
        view.backgroundColor = .WhiteDay
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

// MARK: - SetCategoriesViewControllerDelegate
 extension TrackerFormViewController: SetCategoriesViewControllerDelegate {
     
     func didConfirm(_ category: TrackerCategory) {
         self.data.category = category
         tableView.reloadData()
         dismiss(animated: true)
     }
 }

extension UIColor {

    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
