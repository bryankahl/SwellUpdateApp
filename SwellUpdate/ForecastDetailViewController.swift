//
//  ForecastDetailViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/24/24.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import AVFoundation
import AVKit

class ForecastDetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var beachNameLabel: UILabel!
    @IBOutlet weak var waveHeightLabel: UILabel!
    @IBOutlet weak var waveDirectionLabel: UILabel!
    @IBOutlet weak var wavePeriodLabel: UILabel!
    @IBOutlet weak var spotRatingLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    var selectedForecast: SurfForecast?
    var storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    var mediaItems: [MediaItem] = []
    var selectedSpot: SurfSpotLocation?
    // Properties to store the fetched forecast data
    var waveHeight: Double = 0.0
    var waveDirection: Double = 0.0
    var wavePeriod: Double = 0.0


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure UI
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let spacing: CGFloat = 1 // Spacing between cells
                let itemsPerRow: CGFloat = 3
                
                // Calculate item width dynamically based on collection view width
                let totalSpacing = (itemsPerRow - 1) * spacing + layout.sectionInset.left + layout.sectionInset.right
                let itemWidth = (collectionView.bounds.width - totalSpacing) / itemsPerRow
                
                layout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Square cells
                layout.minimumLineSpacing = spacing
                layout.minimumInteritemSpacing = spacing
                layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
            }
        updateUI()
        updateFavoriteButton()
        // Fetch media
        fetchMediaMetadata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let spot = selectedSpot else { return }
        
        // Fetch and display updated forecast
        fetchForecastData(for: spot)
        updateFavoriteButton()
        fetchMediaMetadata()
        updateUI()
    }

    
    // MARK: - Fetch Forecast Data
    func fetchForecastData(for spot: SurfSpotLocation) {
        SurfSpotService.shared.fetchForecast(for: spot) { [weak self] forecast in
            guard let self = self else { return }
            guard let forecast = forecast else {
                print("No forecast data available for \(spot.name)")
                DispatchQueue.main.async {
                    self.beachNameLabel.text = spot.name
                    self.waveHeightLabel.text = "Wave Height: N/A"
                    self.waveDirectionLabel.text = "Wave Direction: N/A"
                    self.wavePeriodLabel.text = "Wave Period: N/A"
                    self.spotRatingLabel.text = "Rating: N/A"
                }
                return
            }

            // Update the UI with the fetched forecast
            DispatchQueue.main.async {
                self.selectedForecast = forecast
                print("Updating UI with Forecast: \(forecast)")
                self.updateUI()
            }
        }
    }


    func updateUI() {
        guard let forecast = selectedForecast else {
            beachNameLabel.text = "No Data Available"
            waveHeightLabel.text = "Wave Height: N/A"
            waveDirectionLabel.text = "Wave Direction: N/A"
            wavePeriodLabel.text = "Wave Period: N/A"
            spotRatingLabel.text = "Rating: N/A"
            return
        }

        beachNameLabel.text = forecast.spotName
        waveHeightLabel.text = "Wave Height: \(String(format: "%.2f", forecast.waveHeight)) m"
        waveDirectionLabel.text = "Wave Direction: \(directionFromDegrees(forecast.waveDirection))"
        wavePeriodLabel.text = "Wave Period: \(String(format: "%.2f", forecast.wavePeriod)) s"
        spotRatingLabel.text = forecast.surfRating
    }




    func directionFromDegrees(_ degrees: Double) -> String {
        switch degrees {
        case 0..<22.5, 337.5..<360:
            return "N"
        case 22.5..<67.5:
            return "NE"
        case 67.5..<112.5:
            return "E"
        case 112.5..<157.5:
            return "SE"
        case 157.5..<202.5:
            return "S"
        case 202.5..<247.5:
            return "SW"
        case 247.5..<292.5:
            return "W"
        case 292.5..<337.5:
            return "NW"
        default:
            return "Unknown"
        }
    }


    // MARK: - Favorite Handling
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let forecast = selectedForecast else { return }
        
        if FavoritesManager.shared.isFavorite(spotName: forecast.spotName) {
            FavoritesManager.shared.removeFavorite(spotName: forecast.spotName)
            print("\(forecast.spotName) removed from favorites.")
        } else {
            FavoritesManager.shared.addFavorite(forecast: forecast)
            print("\(forecast.spotName) added to favorites.")
        }
        
        updateFavoriteButton() // Reflect state change immediately
    }



    private func updateFavoriteButton() {
        guard let forecast = selectedForecast else { return }
        let isFavorite = FavoritesManager.shared.isFavorite(spotName: forecast.spotName)
        let title = isFavorite ? "Remove Favorite" : "Mark as Favorite"
        favoriteButton.setTitle(title, for: .normal)
    }



    // MARK: - Media Handling
    @IBAction func uploadMediaButtonTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.image", "public.movie"]

        let alert = UIAlertController(title: "Upload Media", message: "Choose a source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        })

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                picker.sourceType = .camera
                self.present(picker, animated: true)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            uploadImageToFirebase(image: image)
        } else if let videoURL = info[.mediaURL] as? URL {
            uploadVideoToFirebase(videoURL: videoURL)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func fetchMediaMetadata() {
        guard let spotID = selectedForecast?.spotName else {
            print("Missing selected forecast for media.")
            return
        }
        let sanitizedSpotID = sanitizeFirebaseKey(spotID)

        databaseRef.child("Media").child(sanitizedSpotID).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let currentTime = Date().timeIntervalSince1970
            self.mediaItems = snapshot.children.compactMap { child -> MediaItem? in
                guard let childSnapshot = child as? DataSnapshot,
                      let data = childSnapshot.value as? [String: Any],
                      let mediaURL = data["mediaURL"] as? String,
                      let uploadedAt = data["uploadedAt"] as? String,
                      let expirationTimestamp = data["expirationTimestamp"] as? TimeInterval else {
                    return nil
                }

                // Only include media that hasn't expired
                if currentTime <= expirationTimestamp {
                    return MediaItem(mediaURL: mediaURL, uploadedAt: uploadedAt)
                } else {
                    // Delete expired media
                    self.databaseRef.child("Media").child(sanitizedSpotID).child(childSnapshot.key).removeValue()
                    return nil
                }
            }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }




    private func saveMetadata(spotID: String, mediaID: String, mediaURL: String) {
        let sanitizedSpotID = sanitizeFirebaseKey(spotID)
        let currentTimestamp = Date().timeIntervalSince1970 // Current time in seconds
        let metadata: [String: Any] = [
            "mediaURL": mediaURL,
            "uploadedAt": ISO8601DateFormatter().string(from: Date()),
            "expirationTimestamp": currentTimestamp + (24 * 60 * 60) // 24 hours from now
        ]

        databaseRef.child("Media").child(sanitizedSpotID).child(mediaID).setValue(metadata) { error, _ in
            if let error = error {
                print("Failed to save metadata: \(error.localizedDescription)")
            } else {
                print("Metadata saved successfully!")
                self.fetchMediaMetadata() // Refresh media items after saving
            }
        }
    }




    private func uploadImageToFirebase(image: UIImage) {
        guard let spotID = selectedForecast?.spotName else { return }
        let mediaID = UUID().uuidString
        let filePath = "SurfSpots/\(spotID)/\(mediaID).jpg"
        let mediaRef = storageRef.child(filePath)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        mediaRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Image upload failed: \(error.localizedDescription)")
            } else {
                mediaRef.downloadURL { url, error in
                    guard let url = url else {
                        print("Failed to get download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    self.saveMetadata(spotID: spotID, mediaID: mediaID, mediaURL: url.absoluteString)
                }
            }
        }
    }

    private func uploadVideoToFirebase(videoURL: URL) {
        guard let spotID = selectedForecast?.spotName else { return }
        let mediaID = UUID().uuidString
        let filePath = "SurfSpots/\(spotID)/\(mediaID).mp4"
        let mediaRef = storageRef.child(filePath)

        if videoURL.pathExtension.lowercased() != "mp4" {
            convertMOVToMP4(originalURL: videoURL) { convertedURL in
                guard let convertedURL = convertedURL else { return }
                self.uploadVideoToFirebase(videoURL: convertedURL)
            }
            return
        }

        mediaRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Video upload failed: \(error.localizedDescription)")
            } else {
                mediaRef.downloadURL { url, error in
                    guard let url = url else {
                        print("Failed to get download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    self.saveMetadata(spotID: spotID, mediaID: mediaID, mediaURL: url.absoluteString)
                }
            }
        }
    }

    private func convertMOVToMP4(originalURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: originalURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            print("Unable to create AVAssetExportSession.")
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        exportSession.exportAsynchronously {
            completion(exportSession.status == .completed ? outputURL : nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath)
        let media = mediaItems[indexPath.row]

        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = nil // Reset image

            if media.mediaURL.contains(".mp4") {
                // Generate thumbnail for video
                generateThumbnail(for: media.mediaURL) { thumbnail in
                    DispatchQueue.main.async {
                        if let visibleCell = collectionView.cellForItem(at: indexPath),
                           let visibleImageView = visibleCell.contentView.viewWithTag(1) as? UIImageView {
                            visibleImageView.image = thumbnail
                        }
                    }
                }
            } else {
                // Load image from URL
                if let url = URL(string: media.mediaURL) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data else { return }
                        DispatchQueue.main.async {
                            if let visibleCell = collectionView.cellForItem(at: indexPath),
                               let visibleImageView = visibleCell.contentView.viewWithTag(1) as? UIImageView {
                                visibleImageView.image = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = mediaItems[indexPath.row]

        if media.mediaURL.contains(".mp4") {
            // Handle video playback
            playVideo(urlString: media.mediaURL)
        } else {
            // Handle image view
            viewImage(urlString: media.mediaURL)
        }
    }
    
    func viewImage(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL.")
            return
        }

        // Fetch the image asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                // Create an Image View Controller
                let imageViewController = UIViewController()
                imageViewController.view.backgroundColor = .black
                imageViewController.modalPresentationStyle = .fullScreen

                // Add an image view to the controller
                let imageView = UIImageView(frame: imageViewController.view.bounds)
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                imageView.isUserInteractionEnabled = true

                // Add tap gesture to dismiss
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
                imageView.addGestureRecognizer(tapGesture)

                imageViewController.view.addSubview(imageView)
                self.present(imageViewController, animated: true, completion: nil)
            }
        }.resume()
    }

    @objc func dismissFullscreenImage() {
        dismiss(animated: true, completion: nil)
    }
    
    func playVideo(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid video URL.")
            return
        }

        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        present(playerViewController, animated: true) {
            player.play()
        }
    }




    private func generateThumbnail(for videoURL: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: videoURL) else { completion(nil); return }
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)

        DispatchQueue.global().async {
            guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else {
                completion(nil)
                return
            }
            completion(UIImage(cgImage: cgImage))
        }
    }
}

// MARK: - MediaItem Model
struct MediaItem {
    let mediaURL: String
    let uploadedAt: String
}

