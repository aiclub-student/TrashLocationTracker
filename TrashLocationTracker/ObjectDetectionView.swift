//
//  ObjectDetectionView.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/21/23.
//

import SwiftUI
import CoreML
import Vision
import UIKit

import Alamofire
import SwiftyJSON


struct ObjectDetectionView: View {
    @State private var resultText=""
    @State private var showingImagePicker=false
    @State private var inputImage: UIImage? = UIImage(named:"trash")
    
    @State var detectedObjects: [String] = []
    @EnvironmentObject var refreshManager:RefreshManager
    
    
    //@State private var image: UIImage?
    //@State private var boxes: [ShapeView] = []
    
    var body: some View {
        HStack {
            VStack (alignment: .center,
                    spacing: 20){
                Text("Check for trash")
                    .font(.system(size:42))
                    .fontWeight(.bold)
                    .padding(10)
                /*
                if !detectedObjects.isEmpty {
                              Text("Detected Objects: \(detectedObjects.joined(separator: ", "))")
                          }
                 */
                //Text(resultText)
                Image(uiImage: inputImage!).resizable()
                    .aspectRatio(contentMode: .fit)
                Button("Is this trash?"){
                    self.buttonPressed()
                }
                .padding(.all, 14.0)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
                //Text(DataStore.label)
            }
                    .font(.title)
        }.sheet(isPresented: $showingImagePicker, onDismiss: detectObjects) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    /*
    func processImage() {
        self.showingImagePicker = false
        self.resultText="Checking..."
        guard let inputImage = inputImage else {return}
        print("Processing image due to Button press")
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPG).base64EncodedData()
        let uploadURL="https://askai.aiclub.world/5757c28f-6cee-4734-a4da-ff274e48438c"
        
        AF.upload(imageB64, to: uploadURL).responseJSON { response in
            
            debugPrint(response)
            switch response.result {
            case .success(let responseJsonStr):
                print("\n\n Success value and JSON: \(responseJsonStr)")
                let myJson = JSON(responseJsonStr)
                let predictedValue = myJson["predicted_label"].string
                print("Saw predicted value \(String(describing: predictedValue))")
                
                let predictionMessage = predictedValue!
                self.resultText=predictionMessage
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
    }
     */
    
    func detectObjects() {
        guard let inputImage=inputImage else {
            print("No image selected")
            return
        }
        let model1=TrashDetectionV1_1_Iteration_10000().model
        //let model1=ObjectDetector_CatsDogs_v2_1().model
        guard let model = try? VNCoreMLModel(for: model1) else {
                fatalError("Failed to load Core ML model.")
            }
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty else {
                    print("Unexpected result type from VNCoreMLRequest.")
                    return
                }
                // Draw bounding boxes around the detected objects
                let imageSize = inputImage.size
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
                let scale = CGAffineTransform.identity.scaledBy(x: imageSize.width, y: imageSize.height)
                let objectBoundsAndLabels = results.map { observation -> (CGRect, String) in
                         let observationBounds = observation.boundingBox
                         let objectBounds = observationBounds.applying(scale).applying(transform)
                         let label = observation.labels[0].identifier
                    
                         return (objectBounds, label)
                     }
                
                DispatchQueue.main.async {
                    self.inputImage = inputImage
                    self.refreshManager.refreshTab += 1
                    self.detectedObjects = results.map { observation in
                        return observation.labels[0].identifier
                    }
                    self.drawBoundingBoxes(on: &self.inputImage, with: objectBoundsAndLabels)
                    DataStore.updatedImage=self.inputImage
                }
            }
            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!)
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform detection: \(error.localizedDescription)")
            }
        }
    
    
    func drawBoundingBoxes(on image: inout UIImage?, with objectBoundsAndLabels: [(CGRect, String)]) {
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)
        image?.draw(in: CGRect(origin: CGPoint.zero, size: image!.size))
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(4.0)
        for (objectBounds, label) in objectBoundsAndLabels {
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.addRect(objectBounds)
            context?.drawPath(using: .stroke)
            
            context?.setFillColor(UIColor.red.cgColor)
            if ["plastic"].contains(label) {
                DataStore.label=label
                DataStore.seen=true
            }
            print("Object bounds are \(objectBounds) for label \(label) and label is \(label) and seen is \(DataStore.seen)")
            
            let labelRect = CGRect(x: objectBounds.origin.x, y: max(objectBounds.origin.y - 55,0), width: objectBounds.width, height: 55)
            context?.fill(labelRect)
            
            context?.setFillColor(UIColor.black.cgColor)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let labelFontAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ]
            let attributedLabel = NSAttributedString(string: label, attributes: labelFontAttributes)
            attributedLabel.draw(in: labelRect)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    
    
}


struct ObjectDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectDetectionView()
    }
}
    
    

/*
 
 ChatGPT code. Do not use.
 
 struct ObjectDetectionView: View {
 @State private var image: UIImage?
 @State private var boxes: [ShapeView] = []
 
 var body: some View {
 VStack {
 if let image = image {
 Image(uiImage: image)
 .resizable()
 .scaledToFit()
 .overlay(ShapeView(frame: .zero).opacity(0.3))
 .overlay(Group { ForEach(boxes, id:\.id) { $0 } })
 } else {
 Text("No image selected")
 }
 
 Button("Select Image") {
 let picker = UIImagePickerController()
 picker.sourceType = .photoLibrary
 picker.delegate = self
 UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
 }
 }
 }
 
 private func performObjectDetection() {
 guard let ciImage = CIImage(image: image!) else {
 fatalError("Failed to create CIImage from UIImage.")
 }
 
 let requestHandler = VNImageRequestHandler(ciImage: ciImage)
 
 guard let model = try? VNCoreMLModel(for: YourObjectDetectionModel().model) else {
 fatalError("Failed to load Core ML model.")
 }
 
 let request = VNCoreMLRequest(model: model) { [weak self] request, error in
 guard let self=self else {return}
 
 if let results = request.results as? [VNRecognizedObjectObservation] {
 for result in results {
 let objectBounds = result.boundingBox
 let x = objectBounds.origin.x * image!.size.width
 let y = (1 - objectBounds.origin.y) * image!.size.height
 let width = objectBounds.size.width * image!.size.width
 let height = objectBounds.size.height * image!.size.height
 let objectRect = CGRect(x: x, y: y, width: width, height: height)
 let box = ShapeView(frame: objectRect)
 self.boxes.append(box)
 }
 }
 }
 request.imageCropAndScaleOption = .centerCrop
 
 do {
 try requestHandler.perform([request])
 } catch {
 print("Failed to perform detection: \(error.localizedDescription)")
 }
 }
 }
 
 extension ObjectDetectionView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 picker.dismiss(animated: true)
 guard let uiImage = info[.originalImage] as? UIImage else {
 fatalError("Failed to get image from picker.")
 }
 image = uiImage
 boxes.removeAll()
 performObjectDetection()
 }
 }
 
 struct ShapeView: UIViewRepresentable {
 let id=UUID()
 let frame: CGRect
 
 func makeUIView(context: Context) -> UIView {
 let view = UIView(frame: frame)
 view.layer.borderColor = UIColor.red.cgColor
 view.layer.borderWidth = 2
 return view
 }
 
 func updateUIView(_ uiView: UIView, context: Context) {}
 }
 
 struct YourObjectDetectionModel {
 // Replace this with your own Core ML object detection model.
 var model: MLModel = {
 // Load your model from disk or download it from the internet.
 // Example: try! YourObjectDetectionModel_1(configuration: MLModelConfiguration())
 fatalError("Replace with your own Core ML object detection model.")
 }()
 }
 
 
 struct ObjectDetectionView_Previews: PreviewProvider {
 static var previews: some View {
 ObjectDetectionView()
 }
 }
 
 */
