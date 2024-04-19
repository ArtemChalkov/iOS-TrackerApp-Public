//
//  ScheduleViewController.swift
//  Tracker
//


import UIKit

final class ScheduleViewController: UIViewController {
    
    //var array: [DayOfWeek] = [.sunday, .monday].sorted { $0.index() < $1.index() }
    
    private var selectedWeekdays: Set<DayOfWeek> = [] {
        didSet {
            tableView.reloadData()
        }
    }
    lazy var days: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var onScheduleChanged: (([DayOfWeek])->())?
    
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
        tableView.separatorColor = .gray
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseId)
        return tableView
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = .BlackDay
        button.setTitleColor(.BlackNight, for: .normal)
        
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
    
    func update(_ schedule: [DayOfWeek]) {
        self.selectedWeekdays = Set(schedule)
    }
}

private extension ScheduleViewController {
    
    @objc func doneButtonTapped() {
        let sortedDays: [DayOfWeek] = Array(selectedWeekdays).sorted { $0.index() < $1.index() }
        onScheduleChanged?(sortedDays)
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
        cell.update(day, selectedWeekdays)
        
        cell.onDaySwitchChanged = { [weak self] (day, isSelected) in
            
            if isSelected {
                self?.selectedWeekdays.insert(day)
            } else {
                self?.selectedWeekdays.remove(day)
            }
        }
        return cell
    }
    
}

extension ScheduleViewController: UITableViewDelegate {
    
}
