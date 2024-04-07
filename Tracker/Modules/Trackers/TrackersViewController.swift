//
//  ViewController.swift
//  Tracker
//

import UIKit


final class TrackersViewController: UIViewController {
    
    //private var searchText: String = ""
    private var categories: [TrackerCategory] = []
    
    private var visibleCategories: [TrackerCategory] {
        return []
    }

    //private var completedTrackers: [TrackerRecord] = []
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    
    private var currentDate: Date = Date()
    //private var currentDate = Date.from(date: Date())!
    
    //MARK: Service
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
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
        //let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        

        datePicker.minimumDate = minDate
        datePicker.maximumDate = Date()
    
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
        //NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("UpdateTrackersScreen"), object: nil)
        
        fetchTrackers()
    }
}


//private extension TrackersViewController {
//
//    @objc func update() {
//        fetchTrackers()
//        collectionView.reloadData()
//    }
//}

private extension TrackersViewController {
    
    func fetchTrackers() {
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        
        try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        try? trackerRecordStore.loadCompletedTrackers(by: currentDate)
        
        checkNumberOfTrackers()
        collectionView.reloadData()
    }
    
    private func checkNumberOfTrackers() {
        
        emptyStateView.update(.empty)
        emptyStateView.isHidden = trackerStore.numberOfTrackers != 0
        print(trackerStore.numberOfTrackers)
    }
    
    func updateTrackerRecord(tracker: Tracker, cell: TrackerCell) {
        
        if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate && $0.trackerId == tracker.id }) {
                     
            try? trackerRecordStore.remove(recordToRemove)
            
            cell.switchAddDayButton(to: false)
            cell.decreaseCount()
        } else {
            let trackerRecord = TrackerRecord(trackerId: tracker.id, date: currentDate)
                         
            try? trackerRecordStore.add(trackerRecord)
            
            cell.switchAddDayButton(to: true)
            cell.increaseCount()
        }
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
    
    @objc func addTrackerBarButtonTapped() {
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
        
        currentDate = Date.from(date: sender.date)!
        print(currentDate)
        
        //Если меняется currentDate делаем новый запрос в БД
        do {
            try trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
            try trackerRecordStore.loadCompletedTrackers(by: currentDate)
        } catch {}
        
        collectionView.reloadData()
    }
}

extension TrackersViewController:  UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if trackerStore.numberOfTrackers == 0 {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: self.view.frame.width, height: 50)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell,
              let tracker = trackerStore.tracker(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.onTrackerStatusChanged = { tracker, cell in
            
            self.updateTrackerRecord(tracker: tracker, cell: cell)
            
        }

        let isCompleted = completedTrackers.contains { $0.date == currentDate && $0.trackerId == tracker.id }
        
        cell.update(tracker, counter: tracker.daysCount, isComplete: isCompleted, calendarDate: currentDate)

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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("end searching --> Close Keyboard")
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText //Запускается запрос на поиск в БД
        collectionView.reloadData()
    }
}


//MARK: - Layout
extension TrackersViewController {
    
    func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem =
        UIBarButtonItem(image: UIImage(named: "plus"),
                        style: .plain,
                        target: self,
                        action: #selector(addTrackerBarButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
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


// MARK: - TrackerStoreDelegate
 extension TrackersViewController: TrackerStoreDelegate {
     func didUpdate() {
         
         checkNumberOfTrackers()
         collectionView.reloadData()
     }
 }

 // MARK: - TrackerRecordStoreDelegate
 extension TrackersViewController: TrackerRecordStoreDelegate {
     func didUpdateRecords(_ records: Set<TrackerRecord>) {
         
         completedTrackers = records
     }
 }

