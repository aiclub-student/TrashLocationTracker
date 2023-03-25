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

import SwiftUI

struct MultiTabView: View {
    
    @StateObject var locationManager = LocationManager()
    
    @AppStorage("lat") var lat=0.0
    @AppStorage("lon") var lon=0.0
    var body: some View {
        
        ZStack {
            Color.blue.opacity(0.2).ignoresSafeArea()
            TabView{
                /*
                WebView(url:URL(string:"https://sites.google.com/students.harker.org/aquatamer/the-problem")!)
                    .tabItem{
                        Label("Drought",systemImage: "leaf.circle.fill")
                    }
                */
                ObjectDetectionView()
                    .tabItem{
                        Label("Picture",systemImage: "sprinkler.and.droplets.fill")
                    }
                TrashMapView(locationManager: locationManager)
                    .tabItem{
                        Label("Weather",systemImage: "cloud.rain.circle")
                    }
                SampleMapView(locationManager: locationManager)
                    .tabItem{
                        Label("Sample map",systemImage: "cloud.rain.circle")
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

