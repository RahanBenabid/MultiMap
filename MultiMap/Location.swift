//
//  Location.swift
//  MultiMap
//
//  Created by Rahan Benabid on 27/6/2024.
//

import MapKit

// We use the hashable protocol so that we can place it inside a set
struct Location: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  /// tells swift it can calculate the hash value for each locatop struct just using the `id` property
    }
}
