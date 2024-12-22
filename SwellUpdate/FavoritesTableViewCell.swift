//
//  FavoritesTableViewCell.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 12/15/24.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    //CELL STYLING

    private let gradientLayer = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        // Gradient background setup
        gradientLayer.colors = [UIColor.systemTeal.cgColor, UIColor.systemBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 10
        layer.insertSublayer(gradientLayer, at: 0)

        // Rounded corners
        layer.cornerRadius = 10
        layer.masksToBounds = true

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds.insetBy(dx: 10, dy: 5) // Add padding
    }
}

