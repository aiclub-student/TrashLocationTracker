//
//  MultiTabView.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/20/23.
//

//
// Main Content container.
// Sets up Tabs for the rest
//

import SwiftUI

class RefreshManager: ObservableObject {
    @Published var refreshTab: Int
    
    init(refreshTab: Int) {
        self.refreshTab = refreshTab
    }
}

struct MultiTabView: View {
    
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var refreshManager:RefreshManager
    
    @AppStorage("lat") var lat=0.0
    @AppStorage("lon") var lon=0.0
    var body: some View {
        
        ZStack {
            Color.blue.opacity(0.2).ignoresSafeArea()
            TabView{
                ObjectDetectionView()
                    .tabItem{
                        Label("Detect trash",systemImage: "eye.circle.fill")
                    }
                 /*
                TrashMapView(locationManager: locationManager)
                    .tabItem{
                        Label("Weather",systemImage: "cloud.rain.circle")
                    }
                */
                SampleMapView(locationManager: locationManager)
                    .environmentObject(refreshManager)
                    .tabItem{
                        Label("Map",systemImage: "globe.americas.fill")
                    }
                    .onTapGesture {
                                       //refreshManager.refreshTab = 1
                                   }
                WebView(url:URL(string:"https://calrecycle.ca.gov/")!)
                    .tabItem{
                        Label("Recycle",systemImage: "arrow.3.trianglepath")
                    }
            }
        }
        .onAppear(){
            locationManager.requestLocation()
        }

    }
}

struct Tab1View: View {
    var body: some View {
        Text("Page 1")
    }
}

struct Tab2View: View {
    var body: some View {
        Text("Page 2")
    }
}

struct Tab3View: View {
    @AppStorage("lat") var lat=0.0
    @AppStorage("lon") var lon=0.0
    var body: some View {
        ZStack {
            Color.blue.opacity(0.20).ignoresSafeArea()
            WebView(url:URL(string:"https://forecast.weather.gov/MapClick.php?textField1=\(lat)&textField2=\(lon)")!)
        }
    }
}

struct MultiTabView_Previews: PreviewProvider {
    static var previews: some View {
        MultiTabView()
    }
}

