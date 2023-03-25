//
//  LocationManager.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/20/23.
//

//
// Core location library
//

import CoreLocation
import MapKit
import SwiftUI


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @AppStorage("lat") var lat=0.0
    @AppStorage("lon") var lon=0.0
    

    @Published var location: CLLocationCoordinate2D?
    @Published var area=MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5, longitude: -121.9), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        print("Start request location")
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        guard let location = location else {
            return
        }
        print("Got updated Location information: \(location)")
        lat=location.latitude
        lon=location.longitude
        DataStore.lat=lat
        DataStore.lon=lon
        
        area=MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("Saw Location error \(error)")
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
