//
//  FiltersViewController.swift
//  Tracker
//

import UIKit

struct Filter {
    var isSelected: Bool
    let filterType: FilterType
}

enum FilterType: String, CaseIterable {
    case allTrackers
    case todayTrackers
    case completedTrackers
    case noCompletedTrackrs
    
    func getName() -> String {
        switch self {
        case .allTrackers:
            return "Filters.AllTrackers".localized
        case .todayTrackers:
            return "Filters.TrackersForToday".localized
        case .completedTrackers:
            return "Filters.Completed".localized
        case .noCompletedTrackrs:
            return "Filters.NotCompleted".localized
        }
    }
}

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: Filter)
    func didDeselectFilter()
}

// MARK: - FiltersViewController

final class FiltersViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: FiltersViewControllerDelegate?

    var currentFilterType: FilterType = .allTrackers {
        didSet {
            for index in 0..<filters.count {
                
                let item = filters[index]
                
                if item.filterType == currentFilterType {
                    filters[index].isSelected = true
                }
            }
        }
    }
    
    private var filters = [
        Filter(isSelected: false, filterType: .allTrackers),
        Filter(isSelected: false, filterType: .todayTrackers),
        Filter(isSelected: false, filterType: .completedTrackers),
        Filter(isSelected: false, filterType: .noCompletedTrackrs),
    ]
    
    private let viewTitle: UILabel = {
        let label = UILabel()
        label.textColor = .BlackDay 
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "Trackers.filters".localized
        return label
    }()
    
    private let filtersTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .WhiteDay
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = .Gray
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersTable.dataSource = self
        filtersTable.delegate = self
        
        setupUI()
    }
    

}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = Colors.lightGray
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let filter = filters[indexPath.row]
        
        cell.update(filter)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Отключаем все фильтры
        for index in 0..<filters.count {
            filters[index].isSelected = false
        }
        
        //Включаем правильный фильтр
        filters[indexPath.row].isSelected = true
        
        tableView.reloadData()
        
        let selectedFilter = filters[indexPath.row]
        
        delegate?.didSelectFilter(selectedFilter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        
        self.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

extension FiltersViewController {
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        view.backgroundColor = .WhiteDay
        view.addSubview(viewTitle)
        view.addSubview(filtersTable)
        
        viewTitle.translatesAutoresizingMaskIntoConstraints = false
        filtersTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            viewTitle.heightAnchor.constraint(equalToConstant: 22),
            
            filtersTable.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 24),
            filtersTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTable.heightAnchor.constraint(equalToConstant: 300),
            
        ])
    }
}
