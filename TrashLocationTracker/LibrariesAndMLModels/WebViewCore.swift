//
//  WebViewCore.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/20/23.
//

import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        DispatchQueue.main.async {
            webView.load(request)
          }
        //webView.load(request)
        print("Loaded request for URL=",url)
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url:URL(string:"http://www.aquatamer.org")!)
    }
}
