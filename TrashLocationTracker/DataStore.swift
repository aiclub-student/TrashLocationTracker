//
//  DataStore.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/24/23.
//

import Foundation
import MapKit


struct Annotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
}

class DataStore {
    static var label = "UNKNOWN"
    static var lat: Double = 0.0
    static var lon: Double = 0.0
    static var seen: Bool = false
    
    
    static var annotations = [
        Annotation(coordinate: CLLocationCoordinate2D(latitude: 37.33233141, longitude: -122.0312186), title: "Apple Park", subtitle: " "),
        Annotation(coordinate: CLLocationCoordinate2D(latitude: 37.773972, longitude: -122.431297), title: "Golden Gate Bridge", subtitle: " "),
        Annotation(coordinate: CLLocationCoordinate2D(latitude: 47.606209, longitude: -122.332071), title: "Space Needle", subtitle: " ")
    ]
    
    static func getAnnotations() -> [Annotation] {
        if seen {
            annotations.append(Annotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), title: label, subtitle: ""))
        }
        print("Annotations are \(annotations)")
        return annotations
    }
}
