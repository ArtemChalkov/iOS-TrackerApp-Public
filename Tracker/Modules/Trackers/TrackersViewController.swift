//
//  ViewController.swift
//  Tracker
//

import UIKit


final class TrackerService {
    
    var currentTracker: Tracker?
    
    static let shared = TrackerService()
    
    private init() {}
    
    var categories: [TrackerCategory] = [
        TrackerCategory(name: "Домашний уют!", array: [])
    ]
    
    var completedTrackers: [TrackerRecord] = []
    
    func append(_ tracker: Tracker) {
        categories[0].array.append(tracker)
    }
    
    func remove(_ tracker: Tracker) {
        categories[0].array.removeAll { $0.id == tracker.id }
    }
}

final class TrackersViewController: UIViewController {
    
    private var searchText: String = ""
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] {
        
        //Пон - 2 Втр - 3 Ср - 4 Чтв - 5 Птн - 6 Сбт - 7 Вск - 1
        // [0, 1, 2, 3, 4, 5, 6]
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        print("weekday ->", weekday)
        var result = [TrackerCategory]()
        
        
        for category in categories {
            
            //Фильтруем те у которых есть расписание
            let trackersByDay = category.array.filter { tracker in
                let schedule = tracker.schedule
                return schedule.contains(Weekday.allCases[weekday > 1 ? weekday - 2 : weekday + 5])
            }
            //Фильтруем тех у которых нет расписание
            let trackersNoSchedule = category.array.filter { tracker in
                
                let isScheduleEmpty = tracker.schedule.isEmpty
                let isNotComplete = completedTrackers.filter { $0.id == tracker.id }.count == 0
                
                return isScheduleEmpty && isNotComplete
            }
            result.append(TrackerCategory(name: category.name, array: trackersByDay + trackersNoSchedule))
            print("->", trackersByDay)
            
            //ПОИСК
            
            if !searchText.isEmpty {
                result = []
                
                let filteredTrackersByDay = trackersByDay.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                let filteredTrackersNoSchedule = trackersNoSchedule.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                
                let filteredTrackers = filteredTrackersByDay + filteredTrackersNoSchedule
                
                if !filteredTrackers.isEmpty {
                    result.append(TrackerCategory(name: category.name, array: filteredTrackers))
                }
            }
        }
    
        return result
    }
    
    private var completedTrackers: [TrackerRecord] = []
    
    var currentDate: Date = Date()
    
    
    private var trackerService = TrackerService.shared
    private var emptyStateView = TrackersEmptyStateView()
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50) // Размер заголовка секции
        
        let screenWidth = UIScreen.main.bounds.width
        var itemWidth = (screenWidth - 16 - 16 - 9) / 2
        layout.itemSize = CGSize(width: itemWidth - 1, height: 148)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.keyboardDismissMode = .onDrag
        
        return collectionView
    }()
    
    var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
    
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.isTranslucent = true
        searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage() //фиксит полоски на UISearchBar
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureToHideKeyboard()
        
        setupNavigationBarItems()
        setupViews()
        setupConstraints()
        
        //addTapGestureToHideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("UpdateTrackersScreen"), object: nil)
        
        fetchTrackers()
    }
}

private extension TrackersViewController {
    
    @objc func update() {
        fetchTrackers()
        collectionView.reloadData()
    }
}

private extension TrackersViewController {
    
    func fetchTrackers() {
        categories = trackerService.categories
        completedTrackers = trackerService.completedTrackers
        
        collectionView.reloadData()
    }
}

//MARK: - Navigation

private extension TrackersViewController {
    
    func navigateToCreateTaskScreen() {
        let createTaskVC = CreateTrackerViewController()
        let navVC = UINavigationController(rootViewController: createTaskVC)
        present(navVC, animated: true)
    }
}

//MARK: - Event Handler
private extension TrackersViewController {
    
    @objc func addTapped() {
        searchBar.endEditing(true)
        navigateToCreateTaskScreen()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        
        currentDate = sender.date
        print(currentDate)
        
        collectionView.reloadData()
        
        //visibleCategories
    }
    
}

extension TrackersViewController:  UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var count = 0
//        for category in categories {
        for category in visibleCategories {
            count += category.array.count
        }
        
        if count == 0 {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: self.view.frame.width, height: 50)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
   
        //Common Count
        let trackersCount = categories.count
        var count = 0
        
        for category in categories {
            count += category.array.count
        }
        
        //Visible Count
        let itemCount = visibleCategories.count
        var visibleCount = 0
        //for category in categories {
        for category in visibleCategories {
            visibleCount += category.array.count
        }
        
        
        emptyStateView.isHidden = visibleCount != 0

        //Resolve
        if count == 0 {
            emptyStateView.update(.empty)
            return trackersCount
        }
        
        if visibleCount == 0 {
            emptyStateView.update(.error)
        }
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //let trackerCategory = categories[section]
        let trackerCategory = visibleCategories[section]
        return trackerCategory.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as! TrackerCell
        
        //let trackerCategory = categories[indexPath.section]
        
        cell.onTrackerStatusChanged = { [weak self] tracker, completeStatus in
            guard let self else { return }
            
            if completeStatus == true {
                let trackerRecord = TrackerRecord(id: tracker.id, date: self.currentDate)
                self.completedTrackers.append(trackerRecord)
                print("add ->", self.completedTrackers)
            } else {
                self.completedTrackers.removeAll { $0.id == tracker.id && $0.date == self.currentDate }
                print("remove ->", self.completedTrackers)
            }
            
            collectionView.reloadData()
            
        }
        
        
        let trackerCategory = visibleCategories[indexPath.section]
        
        let tracker = trackerCategory.array[indexPath.row]
        
        let counter = completedTrackers.filter { $0.id == tracker.id }.count
        
        let isComplete = completedTrackers.filter { $0.id == tracker.id && $0.date == currentDate }.count > 0
        
        cell.update(tracker, counter: counter, isComplete: isComplete, calendarDate: currentDate)
        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as! TrackerHeader
            // Настройте header
            return header
        }
        fatalError("Unexpected kind")
    }
}

//MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate  {
    // When button "Search" pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print("end searching --> Close Keyboard")
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()
    }
}


//MARK: - Layout
private extension TrackersViewController {
    
    func setupNavigationBarItems() {
        
        navigationItem.leftBarButtonItem =
        UIBarButtonItem(image: UIImage(named: "plus"),
                        style: .plain,
                        target: self,
                        action: #selector(addTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem =
        UIBarButtonItem(customView: datePicker)
    }
    
    func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(trackerLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
    }
    
    func setupConstraints() {
        
        trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        trackerLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 16).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        emptyStateView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16).isActive = true
        emptyStateView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        emptyStateView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

