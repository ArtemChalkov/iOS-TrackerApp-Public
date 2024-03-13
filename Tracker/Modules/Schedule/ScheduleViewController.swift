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
}

final class ScheduleViewController: UIViewController {

    lazy var days: [String] = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    var trackerService = TrackerService.shared
    
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

private extension ScheduleViewController {
    
    @objc func doneButtonTapped() {
        
        if let tracker = trackerService.currentTracker {
            trackerService.append(tracker)
            print("->", trackerService.categories)
        }
        NotificationCenter.default.post(name: Notification.Name("UpdateTrackersScreen"), object: nil, userInfo: nil)
        dismiss(animated: true)
    }
}

private extension ScheduleViewController {
    
    func setupNavigationItems() {
        navigationItem.title = "Расписание"
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
        cell.update(day)
        
        cell.onDaySwitchChanged = { [weak self] (day, dayIsChoosen) in
            
            guard let self else { return }
            
            guard let weekday = Weekday(rawValue: day) else { return }
            
            var tracker = self.trackerService.currentTracker
            
            if dayIsChoosen {
                tracker?.schedule.append(weekday)
            } else {
                tracker?.schedule.removeAll(where: { $0 == weekday })
            }
            
            self.trackerService.currentTracker = tracker
            
            print("->", tracker?.schedule)
            
        }
        
        return cell
    }
    
}

extension ScheduleViewController: UITableViewDelegate {
    
}
