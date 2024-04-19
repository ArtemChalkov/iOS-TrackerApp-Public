//
//  ViewController.swift
//  Tracker
//

import UIKit


final class TrackersViewController: UIViewController {
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    
    private var editingTracker: Tracker?
    private var currentDate: Date = Date()
    
    //MARK: Service
    //private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var emptyStateView = TrackersEmptyStateView()
    private let analyticsService = AnalyticsService()
    
    
    // MARK: - Lifecycle
    var trackerStore: TrackerStoreProtocol
    
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        label.text = "Trackers.title".localized
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.backgroundColor = .white
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Trackers.filters".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 16
        button.backgroundColor = .Blue
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.placeholder = "Trackers.search".localized
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
        
        fetchTrackers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
}

private extension TrackersViewController {
    
    func fetchTrackers() {
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        
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

extension TrackersViewController: TrackerFormViewControllerDelegate {
    func didAddTracker(category: TrackerCategory, trackerToAdd: Tracker) {
        dismiss(animated: true)
        try? trackerStore.addTracker(trackerToAdd, with: category)
    }
    
    func didUpdateTracker(with data: Tracker.Data) {
        guard let editingTracker else { return }
        dismiss(animated: true)
        try? trackerStore.updateTracker(editingTracker, with: data)
        self.editingTracker = nil
    }
    
    func didTapCancelButton() {
        collectionView.reloadData()
        editingTracker = nil
        dismiss(animated: true)
    }
}


private extension TrackersViewController {
    
    private func presentFormController(
        with data: Tracker.Data? = nil,
        of trackerType: TrackerType,
        setAction: TrackerFormViewController.ActionType
    ) {
        let trackerFormViewController = TrackerFormViewController(ActionType: setAction, trackerType: trackerType, data: data)
        trackerFormViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerFormViewController)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
    
    func navigateToCreateTaskScreen() {
        let createTaskVC = CreateTrackerViewController()
        let navVC = UINavigationController(rootViewController: createTaskVC)
        present(navVC, animated: true)
    }
}

//MARK: - Event Handler
private extension TrackersViewController {
    
    @objc private func filterButtonTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main","item": "filter"])
    }
    
    @objc private func addTrackerBarButtonTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
        
        searchBar.endEditing(true)
        navigateToCreateTaskScreen()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy" // Формат даты
        dateFormatter.locale = Locale.current
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
        
        //delegate
        cell.onTrackerStatusChanged = { tracker, cell in
            self.updateTrackerRecord(tracker: tracker, cell: cell)
        }

        let isCompleted = completedTrackers.contains { $0.date == currentDate && $0.trackerId == tracker.id }
        let interaction = UIContextMenuInteraction(delegate: self)
//        //trackerCell.configure(with: tracker, days: tracker.daysCount, isCompleted: isCompleted, interaction: interaction)
        cell.update(tracker, counter: tracker.daysCount, isComplete: isCompleted, calendarDate: currentDate, interaction: interaction)
        //cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as! TrackerHeader
            
            guard let categoryName =  trackerStore.headerLabelInSection(indexPath.section) else { return UICollectionReusableView() }
            header.update(categoryName)
            
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
        
        navigationItem.leftBarButtonItem?.tintColor = .blackDay
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(trackerLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        view.addSubview(filterButton)
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
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
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

////MARK: - Context Menu
extension TrackersViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let location = interaction.view?.convert(location, to: collectionView),
            let indexPath = collectionView.indexPathForItem(at: location),
            let tracker = trackerStore.tracker(at: indexPath)
        else { return nil }
        
        return UIContextMenuConfiguration(actionProvider:  { actions in
            UIMenu(children: [
                UIAction(title: tracker.isPinned ? "Trackers.unPin".localized : "Trackers.pin".localized) { [weak self] _ in
                    try? self?.trackerStore.togglePin(for: tracker)
                },
                UIAction(title: "SetCategories.edit".localized) { [weak self] _ in
                    let type: TrackerType = tracker.schedule != nil ? .habit : .unregularEvent
                    self?.editingTracker = tracker
                    self?.presentFormController(with: tracker.data, of: type, setAction: .edit)
                    self?.analyticsService.report(event: "click", params: ["screen": "Main","item": "filter"])
                },
                UIAction(title: "SetCategories.delete".localized, attributes: .destructive) { [weak self] _ in
                    let alert = UIAlertController(
                        title: nil,
                        message: "Trackers.deleteTracker".localized,
                        preferredStyle: .actionSheet
                    )
                    let cancelAction = UIAlertAction(title: "TrackerForm.cancel".localized, style: .cancel)
                    let deleteAction = UIAlertAction(title: "SetCategories.delete".localized, style: .destructive) { [weak self] _ in
                        guard let self else { return }
                        try? trackerStore.deleteTracker(tracker)
                        try? trackerStore.deleteTracker(tracker)
                        analyticsService.report(event: "click", params: ["screen": "Main","item": "filter"])
                    }
                    
                    alert.addAction(deleteAction)
                    alert.addAction(cancelAction)
                    
                    self?.present(alert, animated: true)
                }
            ])
        })
    }
}

