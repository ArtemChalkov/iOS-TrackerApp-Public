//
//  EmojisCell.swift
//  textfield-in-tableview
//

import UIKit

class EmojiContainerCell: UITableViewCell {
    
    static let reuseId = "EmojiContainerCell"
    
    var onEmojiCellSelected: ((Emoji)->Void)?
    
    var emojiSelected: String = "" {
        didSet {
            
            if let index = emojis.firstIndex(where: { $0.symbol == emojiSelected }) {
                emojis[index].isSelected = true
            }
            
            collectionView.reloadData()
        }
    }
    
    func update(_ emoji: String) {
        self.emojiSelected = emoji
    }
    
    lazy var emojis = Emojis().items {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        //layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50) // Размер заголовка секции
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - (2 * 19) - (5 * 16))
        print(itemWidth / 5)
        layout.itemSize = CGSize(width: itemWidth / 5 - 1, height: 52)
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       // collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: 204).isActive = true
        collectionView.keyboardDismissMode = .onDrag
        //collectionView.separatorStyle = .none
        
        collectionView.register(EmojisCollectionCell.self, forCellWithReuseIdentifier: EmojisCollectionCell.reuseId)
        
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
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
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

extension EmojiContainerCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisCollectionCell.reuseId, for: indexPath) as? EmojisCollectionCell else { return UICollectionViewCell() }
        
        var emoji = emojis[indexPath.item]
        
        cell.update(emoji)
        
        return cell
    }
}

extension EmojiContainerCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        for index in 0..<emojis.count {
            emojis[index].isSelected = false
        }
        
        emojis[indexPath.item].isSelected = !emojis[indexPath.item].isSelected
        
        let emoji = emojis[indexPath.item]
        
        onEmojiCellSelected?(emoji)
        
        //print("->", emoji)
    }
}

class EmojisCollectionCell: UICollectionViewCell {
    
    static let reuseId = "EmojisCollectionCell"
    
    private var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "🙂"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ emoji: Emoji) {
        emojiLabel.text = emoji.symbol
        
        if emoji.isSelected {
            containerView.backgroundColor = .LightGray //Colors.lightGray1
        } else {
            containerView.backgroundColor = .clear
        }
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(emojiLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            emojiLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            emojiLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
}
