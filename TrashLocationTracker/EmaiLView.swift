//
//  EmaiLView.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 4/4/23.
//

import SwiftUI
import UIKit
import MessageUI

struct EmailView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    let image: UIImage?
    let mapImage: UIImage?
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = context.coordinator
        mailComposeViewController.setToRecipients(recipients)
        mailComposeViewController.setSubject(subject)
        let emailMsg=body+"<p>Location: \(DataStore.lat),\(DataStore.lon)"+"\n\n<p> <a href=\"https://www.google.com/maps/@\(DataStore.lat),\(DataStore.lon),10z\">Map</a>\n"
        mailComposeViewController.setMessageBody(emailMsg, isHTML: true)
        
        // Convert UIImage to NSData
        if let imageData = image.flatMap({ $0.pngData() }) {
            mailComposeViewController.addAttachmentData(imageData, mimeType: "image/png", fileName: "image.png")
        }
        
        if let mapImageData = mapImage.flatMap({ $0.pngData() }) {
            mailComposeViewController.addAttachmentData(mapImageData, mimeType: "image/png", fileName: "mapImage.png")
        }
        
        
        return mailComposeViewController
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // Do nothing
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
