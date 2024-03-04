//
//  ViewController.swift
//  Tracker
//

import UIKit

final class TrackersViewController: UIViewController {
    
    var categories: [TrackerCategory] = []
    
    var completedTrackers: [TrackerRecord] = []
    
    var emptyStateView = TrackersEmptyStateView()
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50) // Размер заголовка секции
        layout.itemSize = CGSize(width: 167, height: 148)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        //datePicker.datePickerMode = .date
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
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
    
    private var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.isTranslucent = true
        
        searchBar.backgroundImage = UIImage() //фиксит полоски на UISearchBar
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
        setupViews()
        setupConstraints()
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

//MARK: - Event Handler
private extension TrackersViewController {
    
    @objc func addTapped() {
        print("addTapped")
        
        let createTaskVC = CreateTrackerViewController()
        let navVC = UINavigationController(rootViewController: createTaskVC)
        
        present(navVC, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
}

extension TrackersViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let itemCount = 2
        emptyStateView.isHidden = itemCount != 0
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default: return 0
        }
        //return 1 // Одна ячейка
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as! TrackerCell
        // Настройте cell
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
