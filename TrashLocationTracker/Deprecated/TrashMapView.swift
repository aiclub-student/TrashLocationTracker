//
//  TrashMapView.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/20/23.
//

//
// Original map display code. Will deprecate.
//

import SwiftUI
import CoreLocationUI
import MapKit

struct TrashMapView: View {
    
    @ObservedObject var locationManager : LocationManager
    
    @State var tracking=MapUserTrackingMode.follow
    @State var annotation=MKPointAnnotation()
    
    var body: some View {
        Map(coordinateRegion:$locationManager.area, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: [annotation.coordinate]) {_ in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: locationManager.location!.latitude, longitude: locationManager.location!.longitude))
            
        }

    }
}

struct TrashMapView_Previews: PreviewProvider {
    static var previews: some View {
        TrashMapView(locationManager: LocationManager())
    }
}
