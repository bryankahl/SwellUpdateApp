//
//  ForecastTableViewCell.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 12/14/24.
//

import UIKit

// Custom table view cell for displaying surf forecast data.
class ForecastTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var beachNameLabel: UILabel! // Label to display the name of the surf spot.
    @IBOutlet weak var ratingLabel: UILabel!    // Label to display the surf rating (e.g., "Good", "Poor").

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the cell's appearance when it's first loaded.
        contentView.layer.cornerRadius = 10 // Round the corners of the cell content.
        contentView.layer.masksToBounds = true // Ensure content respects the rounded corners.

        // Add a subtle shadow effect to the cell.
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false // Ensure the shadow extends beyond the cell's bounds.
        
        backgroundColor = .clear // Set the background color to transparent.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // This method is triggered when the cell is selected.
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Remove any existing gradient layers to avoid stacking them on reloads.
        contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Create and apply a gradient background for the cell.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds // Cover the entire cell.
        gradientLayer.colors = [UIColor.systemTeal.cgColor, UIColor.systemBlue.cgColor] // Gradient colors.
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // Start the gradient at the top-left corner.
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)   // End the gradient at the bottom-right corner.
        gradientLayer.cornerRadius = 10 // Match the corner radius of the content view.

        contentView.layer.insertSublayer(gradientLayer, at: 0) // Add the gradient as the first layer.

        // Ensure the content respects the rounded corners and gradient bounds.
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
}
