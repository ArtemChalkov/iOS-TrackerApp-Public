//
//  HabitTypeContainerCell.swift
//  textfield-in-tableview
//

import UIKit

final class HabitTypeContainerCell: UITableViewCell {
    
    static let reuseId = "HabitTypeContainerCell"
    
    var onCategoryCellSelected: (()->Void)?
    var onScheduleCellSelected: (()->Void)?
    
    //MARK: Data Models
    private var habitTypes: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0) //фикс верхнего сепаратора
        tableView.backgroundColor = Colors.lightGray
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.register(HabitTypeCell.self, forCellReuseIdentifier: HabitTypeCell.reuseId)
        
        return tableView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//MARK: - Public
extension HabitTypeContainerCell {
    
    func update(_ habitTypes: [String]) {
        self.habitTypes = habitTypes
        
        let height = CGFloat(habitTypes.count) * HabitTypeCell.height
        tableView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
}

extension HabitTypeContainerCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("->", habitTypes.count)
        return habitTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitTypeCell.reuseId, for: indexPath) as? HabitTypeCell else { return UITableViewCell() }
        
        let type = habitTypes[indexPath.row] // -> "Категория" или "Расписание"
        let schedule: [DayOfWeek] = [] //= regularTracker?.schedule ?? [] // -> [DayOfWeek]
        cell.update(type, schedule)
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HabitTypeCell.height
    }
    
}

extension HabitTypeContainerCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            print("index row = 0")
            
            onCategoryCellSelected?()
            
        case 1:
            print("index row = 1")
            
            onScheduleCellSelected?()
            
        default: break
        }
    }
}

extension HabitTypeContainerCell {
    
}


//MARK: - Layout
extension HabitTypeContainerCell {
    func setupViews() {
        selectionStyle = .none
        clipsToBounds = true
        contentView.addSubview(tableView)
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            tableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
}
