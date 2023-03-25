//
//  TrashCheckerView.swift
//  TrashLocationTracker
//
//  Created by Amit Gupta on 3/20/23.
//

//
// Code borrowed from EvapoTranspiration. Likely we will not use
//

import SwiftUI





import SwiftUI
import Alamofire
import SwiftyJSON

import CoreLocationUI
import MapKit


struct TrashCheckerView: View {

    
    @State var visibleStatus = "Click on the green button to start"
    @State var uploadLabel = "Select plant"
    @State var visibleLog = " "
    
    @State private var showingUpload = true
    @State private var showingImagePicker = false
    @State private var showingMap = true
    @State private var showLocationButton = false
    
    @State private var inputImage: UIImage? = UIImage(systemName: "list")

    @State private var treeName=""
    @State private var minutesWatering=""
    
    @State private var calculatedET=0.0
    let SQFEET_TO_GALLON=0.623
    let GALLONS_PER_MINUTE = 2.0
    let AVG_SQ_FEET = 600.0
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2)
                .ignoresSafeArea()
            VStack {
                Text("AquaTamer")
                    .font(.system(size:40))
                    .foregroundColor(.blue)
                Text(visibleStatus)
                    .padding(10)
                    .foregroundColor(.blue)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                
                
                if let inputImage=inputImage {
                    Image(uiImage: inputImage).resizable()
                        .frame(height: 400.0)
                        .aspectRatio(contentMode: .fill)
                }



                Spacer()
                if showingUpload {
                    Button(uploadLabel){
                        self.buttonPressed()
                    }
                    .padding(.all, 14.0)
                    .foregroundColor(.white)
                    .background(Color.green)
                .cornerRadius(10)
                }
                


            }
        }.sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }

    }
    
    func buttonPressed() {
        print("Button pressed")
        
        self.showingImagePicker = true
        showingMap = false
        showingUpload = false
    }
    
    func processAIResult(_ result:String) {
        print("In processAIResult, with result=\(result)")
        treeName=result
        visibleStatus = "Identified \(treeName). Click on Location button."
        showLocationButton = true

    }
    
    func processImage() {
        showingImagePicker = false
        visibleStatus="Checking..."
        guard let inputImage = inputImage else {return}
        self.visibleStatus="Calling AI to identify the plant"
        print("Wrong AI: Processing image due to Button press")
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPG).base64EncodedData()
        let uploadURL="https://askai.aiclub.world/be4bbb1e-5a20-47fc-b996-1ae894435d8b"
        
        AF.upload(imageB64, to: uploadURL).responseString { response in
            
            //debugPrint(response)
            switch response.result {
            case .success(let responseJsonStr):
                //print("\n\n Success value and JSON: \(responseJsonStr)")
                let myJson = JSON(parseJSON: responseJsonStr)
                let predictedValue = myJson["predicted_label"].string
                print("Saw predicted value \(String(describing: predictedValue))")
                
                let predictionMessage = predictedValue!
                self.visibleStatus=predictionMessage
                processAIResult(predictedValue!)
                processAIResult(predictedValue!)
                
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
    }
        
        
        func callETAPI(_ plantName:String) {
            print("Called ET API with  plant \(plantName)")
            let api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY2NDU1MjQ0MywianRpIjoiYmUyZmFhZTItNDQ1NS00OWZjLTgyOWUtNTI1MjliMTU5ZWU0IiwibmJmIjoxNjY0NTUyNDQzLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiaXFwdGZocU1YRFNRTUJSVGhWYzJHTE5ocVF5MSIsImV4cCI6MTY4MDEwNDQ0Mywicm9sZXMiOiJ1c2VyIiwidXNlcl9pZCI6ImlxcHRmaHFNWERTUU1CUlRoVmMyR0xOaHFReTEifQ.2FLQnEmS8Q1mcm_bH7lDOYBUulG15l40lerMfd-O5DQ"
            
            let urlToCall = "https://openet.dri.edu/raster/timeseries/point"
            var args:[String:String] = [:]
            let headers: HTTPHeaders = [
                         "Authorization": api_key
                    ]

            let dateFormatter: DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.dateFormat="yyyy-MM-dd"
                    return formatter
                }()
            let startDate=Calendar.current.date(byAdding: .day, value: -10, to: Date())!
            let endDate=Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            args["start_date"]=dateFormatter.string(from: startDate)
            args["end_date"]=dateFormatter.string(from: endDate)
            args["interval"]="daily"           // time interval
            // spatial options

            // OpenEt options
            args["model"]="ensemble"         // model selection (ensemble, geesebal, ssebop, eemetric, sims, disalexi, ptjpl)
            args["variable"]="et"               // variable to retrieve (ndvi, etf, eto, et)
            args["ref_et_source"]="gridmet"          // reference et collection (cimis, gridmet)
            // data processing options
            args["units"]="metric"      // output units (metric [mm], english [in])
            args["output_file_format"]="csv"        // file extension (csv, json)
            
            print("Calling remote ET API with p=\(plantName), args=\(args)")
            AF.request(urlToCall, method: .get, parameters: args, headers:headers ).responseString { response in
                switch response.result {
                case .success(let responseJsonStr):
                    let ma=getCSVAvg(responseJsonStr,1)
                    print("MA Is \(ma)")
                    calculatedET=ma
                    calculateWateringNeeds()
                case .failure(let error):
                    print("\n\n Request failed with error: \(error)")
                }
            }
        }
        
    func getCSVAvg(_ s:String, _ n:Int) -> Double {
        var sum=0.0
        var count=0
        let sa: [String] = s.components(
            separatedBy: "\n"
        )
        for st in sa {
            let sb:[String]=st.components(separatedBy: ",")
            //print("SB is \(sb)")
            if sb.count<2 {
                continue
            }
            if let l=Double(sb[1].filter { !$0.isWhitespace }) {
                sum+=l
                count+=1
                //print("Saw \(l), now sum is \(sum), count=\(count)")
            }
        }
        let avg=sum/Double(count)
        return avg
        
    }
    
    func calculateWateringNeeds() {
        // Update state variables as needed
        print("****** Calculating watering needs based on ET=\(calculatedET) and Tree=\(treeName)")
        let kcFactor=LoadTrashData.getKc(treeName)
        let minutesPerWeek=calculatedET*kcFactor*SQFEET_TO_GALLON*AVG_SQ_FEET/(GALLONS_PER_MINUTE*30.0/7.0)
        minutesWatering="\(minutesPerWeek)"
        visibleStatus=String(format: "Water \(treeName) for %.0f minutes this week", minutesPerWeek)
        uploadLabel = "Select next plant"
        showingUpload = true
        
    }
    
}

struct TrashCheckerView_Previews: PreviewProvider {
    static var previews: some View {
        TrashCheckerView()
    }
}
