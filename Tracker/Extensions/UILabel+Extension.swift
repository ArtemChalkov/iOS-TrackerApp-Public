//
//  UILabel+Extension.swift
//  Tracker
//

import UIKit

extension UILabel {
    func configureLabel(text: String, addToView: UIView, ofSize: CGFloat, weight: UIFont.Weight) {
        self.translatesAutoresizingMaskIntoConstraints = false
        addToView.addSubview(self)
        self.text = text
        self.font = UIFont.systemFont(ofSize: ofSize, weight: weight)
        self.textAlignment = .center
        self.textColor = .BlackDay
    }
}

extension UIStackView {
    
    func configurePlaceholderStack(imageName: String, text: String) {
        self.contentMode = .scaleAspectFit
        self.layer.masksToBounds = true
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.layer.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 80))
        let label = UILabel()
        label.textColor = .BlackDay
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = text
        label.textAlignment = .center
        self.addArrangedSubview(imageView)
        self.addArrangedSubview(label)
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 8
    }
}

// MARK: - For StatisticViewController - Gradient
extension UIView {
     private static let kLayerNameGradientBorder = "GradientBorderLayer"

     func gradientBorder(
         width: CGFloat,
         colors: [UIColor],
         startPoint: CGPoint = .init(x: 0.5, y: 0),
         endPoint: CGPoint = .init(x: 0.5, y: 1),
         andRoundCornersWithRadius cornerRadius: CGFloat = 0
     ) {
         let existingBorder = gradientBorderLayer()
         let border = existingBorder ?? .init()
         border.frame = CGRect(
             x: bounds.origin.x,
             y: bounds.origin.y,
             width: bounds.size.width + width,
             height: bounds.size.height + width
         )
         border.colors = colors.map { $0.cgColor }
         border.startPoint = startPoint
         border.endPoint = endPoint

         let mask = CAShapeLayer()
         let maskRect = CGRect(
             x: bounds.origin.x + width/2,
             y: bounds.origin.y + width/2,
             width: bounds.size.width - width,
             height: bounds.size.height - width
         )
         mask.path = UIBezierPath(
             roundedRect: maskRect,
             cornerRadius: cornerRadius
         ).cgPath
         mask.fillColor = UIColor.clear.cgColor
         mask.strokeColor = UIColor.white.cgColor
         mask.lineWidth = width

         border.mask = mask

         let isAlreadyAdded = (existingBorder != nil)
         if !isAlreadyAdded {
             layer.addSublayer(border)
         }
     }

     private func gradientBorderLayer() -> CAGradientLayer? {
         let borderLayers = layer.sublayers?.filter {
             $0.name == UIView.kLayerNameGradientBorder
         }
         if borderLayers?.count ?? 0 > 1 {
             fatalError()
         }
         return borderLayers?.first as? CAGradientLayer
     }
 }

extension CGPoint {

     enum CoordinateSide {
         case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left
     }

     static func unitCoordinate(_ side: CoordinateSide) -> CGPoint {
         let x: CGFloat
         let y: CGFloat

         switch side {
         case .topLeft:      x = 0.0; y = 0.0
         case .top:          x = 0.5; y = 0.0
         case .topRight:     x = 1.0; y = 0.0
         case .right:        x = 0.0; y = 0.5
         case .bottomRight:  x = 1.0; y = 1.0
         case .bottom:       x = 0.5; y = 1.0
         case .bottomLeft:   x = 0.0; y = 1.0
         case .left:         x = 1.0; y = 0.5
         }
         return .init(x: x, y: y)
     }
 }


