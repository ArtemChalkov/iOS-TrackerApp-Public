//
//  ScheduleViewController.swift
//  Tracker
//


import UIKit

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    func shortDay() -> String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    func index() -> Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
}

final class ScheduleViewController: UIViewController {

    
    //var array: [Weekday] = [.sunday, .monday].sorted { $0.index() < $1.index() }
    
    lazy var days: [String] = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    private var trackerService = TrackerService.shared
    
    private var schedule: [Weekday] = []
    
    var onTrackerChanged: ((Tracker)->())?
    
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
        
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseId)
        
        return tableView
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(nil, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigationItems()
    }
}

extension ScheduleViewController {
    
    func update(_ schedule: [Weekday]) {
        self.schedule = schedule
        tableView.reloadData()
    }
}

private extension ScheduleViewController {
    
    @objc func doneButtonTapped() {
        
        if let tracker = trackerService.currentTracker {
            
            //if trackerService.categories.
            
            trackerService.append(tracker)
            print("->", trackerService.categories)
            NotificationCenter.default.post(name: Notification.Name("UpdateTrackersScreen"), object: nil, userInfo: nil)
            //dismiss(animated: true)
            onTrackerChanged?(tracker)
        }
       
        
        navigationController?.popViewController(animated: true)
    }
}

private extension ScheduleViewController {
    
    func setupNavigationItems() {
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    func setupConstraints() {
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(days.count) * ScheduleCell.height).isActive = true
        
        doneButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseId, for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        
        let day = days[indexPath.row]
        
        cell.update(day, schedule)
        
        cell.onDaySwitchChanged = { [weak self] (day, dayIsChoosen) in
            
            guard let self else { return }
            
            guard let weekday = Weekday(rawValue: day) else { return }
            
            var tracker = self.trackerService.currentTracker
            
            if dayIsChoosen {
                tracker?.schedule.append(weekday)
            } else {
                tracker?.schedule.removeAll(where: { $0 == weekday })
            }
            
            
            tracker?.schedule.sort(by: { $0.index() < $1.index() })
            
            self.trackerService.currentTracker = tracker
            
            print("->", tracker?.schedule)
            
        }
        
        return cell
    }
    
}

extension ScheduleViewController: UITableViewDelegate {
    
}
