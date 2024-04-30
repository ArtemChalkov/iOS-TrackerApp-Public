//
//  ColorsCell.swift
//  textfield-in-tableview
//

import UIKit

class ColorContainerCell: UITableViewCell {
    
    static let reuseId = "ColorContainerCell"
    
    var onColorCellSelected: ((Color)->Void)?
    
    var colorSelected: UIColor = UIColor() {
        didSet {
            
            if let index = colors.firstIndex(where: { item in
                
                print(item.color.rgb(), colorSelected.rgb())
                
                let itemRGB = item.color.rgb()!
                let selectedRGB = self.colorSelected.rgb()!
                    
                if itemRGB == selectedRGB {
                    return true
                } else {
                    return false
                }
                //}
                
//                if item.color.equals(colorSelected) {
//                    return true
//                } else {
//                    return false
//                }
                
                
            }) {
                print("->", colors[index].id)
                colors[index].isSelected = true
            }
        }
    }
    
    func update(_ color: UIColor) {
        self.colorSelected = color
    }
    
    lazy var colors = Colors().items {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        //layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50) // Размер заголовка секции
        
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - (2 * 16) - (5 * 16))
        print(itemWidth / 5)
        layout.itemSize = CGSize(width: itemWidth / 5, height: itemWidth / 5)
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       // collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: 204).isActive = true
        collectionView.keyboardDismissMode = .onDrag
        //collectionView.separatorStyle = .none
        
        collectionView.register(ColorsCollectionCell.self, forCellWithReuseIdentifier: ColorsCollectionCell.reuseId)
        
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.selectionStyle = .none
        self.clipsToBounds = true
        contentView.addSubview(nameLabel)
        contentView.addSubview(collectionView)
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 24)
        ])
    }
    
}

extension ColorContainerCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionCell.reuseId, for: indexPath) as? ColorsCollectionCell else { return UICollectionViewCell() }
        
        let color = colors[indexPath.item]
        
        cell.update(color)
        
        return cell
    }
    
    
}

extension ColorContainerCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        for index in 0..<colors.count {
            colors[index].isSelected = false
        }
        
        colors[indexPath.item].isSelected = !colors[indexPath.item].isSelected
        
        let color = colors[indexPath.item]
        
        onColorCellSelected?(color)
        
    }
    
}


class ColorsCollectionCell: UICollectionViewCell {
    
    static let reuseId = "ColorsCollectionCell"
        
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .WhiteDay
        //view.layer.cornerRadius =
        //view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var colorsView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ color: Color) {
        colorsView.backgroundColor = color.color
        
        if color.isSelected {
            containerView.layer.borderWidth = 3
            containerView.layer.cornerRadius = 8
            containerView.layer.borderColor = color.color.withAlphaComponent(0.3).cgColor
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.cornerRadius = 8
            containerView.layer.borderColor = UIColor.clear.cgColor
        }
        
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(colorsView)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 3),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -3),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3)
        ])

        NSLayoutConstraint.activate([
            colorsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorsView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
