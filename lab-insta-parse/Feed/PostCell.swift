//
//  PostCell.swift
//  lab-insta-parse
//

import UIKit
import Alamofire
import AlamofireImage
import ParseSwift
import CoreLocation

class PostCell: UITableViewCell {

    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    private var imageDataRequest: DataRequest?

    //turns coordinates into a place name
    private let geocoder = CLGeocoder()

    //remembers place names we already looked up so we don't ask again
    private static var placeCache = [String: String]()

    // which post this cell is showing right now
    private var currentPostId: String?

    // blur that covers the photo if the user hasn't posted yet
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    override func awakeFromNib() {
        super.awakeFromNib()

        // put the blur on top of foto
        blurView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: postImageView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor)
        ])
        blurView.isHidden = true
    }

    func configure(with post: Post) {
        currentPostId = post.objectId

        // Username
        if let user = post.user {
            usernameLabel.text = user.username
        }

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {

            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                }
            }
        }

        // Caption
        captionLabel.text = post.caption

        // Date and location
        showDateAndLocation(for: post)

        // only show the photo if it was posted within 24 hours of my last post
        if let lastPostedDate = User.current?.lastPostedDate,
           let postDate = post.createdAt {
            let hoursApart = abs(postDate.timeIntervalSince(lastPostedDate)) / 3600
            blurView.isHidden = hoursApart < 24
        } else {
            // never posted, so blur everything
            blurView.isHidden = false
        }
    }

    private func showDateAndLocation(for post: Post) {
        // older posts don't have takenAt, so just show the posted date like before
        guard let takenAt = post.takenAt else {
            if let date = post.createdAt {
                dateLabel.text = DateFormatter.postFormatter.string(from: date)
            }
            return
        }

        // format 
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let timeText = formatter.string(from: takenAt)

        // no location saved, just show the time
        guard let point = post.location else {
            dateLabel.text = timeText
            return
        }

        // show the time right away, the place name gets added when it loads
        dateLabel.text = timeText

        let key = "\(point.latitude),\(point.longitude)"

        // already looked this place up before
        if let place = PostCell.placeCache[key] {
            dateLabel.text = "📍 \(place) · \(timeText)"
            return
        }

        // ask Apple for the place name
        let postId = post.objectId
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else { return }

            let parts = [placemark.locality, placemark.country].compactMap { $0 }
            let place = parts.joined(separator: ", ")
            if place.isEmpty { return }

            PostCell.placeCache[key] = place

            DispatchQueue.main.async {
                // make sure this cell is still showing the same post
                if self.currentPostId == postId {
                    self.dateLabel.text = "📍 \(place) · \(timeText)"
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the image so a recycled cell doesn't show the previous post's photo.
        postImageView.image = nil

        // Cancel any in-flight image request
        imageDataRequest?.cancel()

        // stop any place lookup and clear the old text
        geocoder.cancelGeocode()
        dateLabel.text = nil
        currentPostId = nil

        // reset the blur
        blurView.isHidden = true
    }
}
