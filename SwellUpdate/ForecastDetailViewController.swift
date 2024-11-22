//
//  ForecastDetailViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/24/24.
//

import Foundation
import UIKit

class ForecastDetailViewController: UIViewController {
    
    @IBOutlet weak var beachNameLabel: UILabel!
    @IBOutlet weak var waveHeightLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    var selectedForecast: SurfForecast?
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Populate the labels with data
            if let forecast = selectedForecast {
                beachNameLabel.text = forecast.spotName
                waveHeightLabel.text = "Wave Height: \(forecast.waveHeight) ft"
                windSpeedLabel.text = "Wind Speed: \(forecast.windSpeed) mph"
            }
        }
}

