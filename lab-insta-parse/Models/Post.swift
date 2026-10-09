//
//  Post.swift
//  lab-insta-parse
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    // These are required by ParseObject.
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var caption: String?
    var user: User?
    var imageFile: ParseFile?
   
   

    // when the photo was taken (from the photo's info)
    var takenAt: Date?

    // where the photo was taken (latitude and longitude)
    var location: ParseGeoPoint?
}
