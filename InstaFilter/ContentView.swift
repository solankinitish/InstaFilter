//
//  ContentView.swift
//  InstaFilter
//
//  Created by Nitish Solanki on 14/03/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var radius = 0.5
    @State private var scale = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    @State private var disabled = true
    
    var body: some View {
        NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in applyProcessing()}
                }
                HStack {
                    Text("Radius")
                    Slider(value: $radius)
                        .onChange(of: radius) { _ in applyProcessing()}
                }
                HStack {
                    Text("Scale")
                    Slider(value: $scale)
                        .onChange(of: scale) { _ in applyProcessing()}
                    
                }

                
                
                HStack{
                    Button("Change Filter"){
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(disabled)
                }
            }
            .padding([.horizontal,.bottom])
            .navigationTitle("InstaFilter")
            .onChange(of: inputImage){ _ in loadImage() }
            .sheet(isPresented: $showingImagePicker){
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Button("Crystallize"){ setFilter(CIFilter.crystallize())}
                Button("Edges"){ setFilter(CIFilter.edges())}
                Button("Gaussian Blur"){ setFilter(CIFilter.gaussianBlur())}
                Button("Pixellate"){ setFilter(CIFilter.pixellate())}
                Button("Sepia Tone"){ setFilter(CIFilter.sepiaTone())}
                Button("Unsharp Mask"){ setFilter(CIFilter.unsharpMask())}
                Button("Vignette"){ setFilter(CIFilter.vignette())}
                Button("Cancel", role: .cancel){}
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        disabled = false
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()

    }
    
    func save() {
        
        guard let processedImage = processedImage else {
            return
        }
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        
        imageSaver.writeToPhotoAlbum(image: processedImage)

    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(scale * 10, forKey: kCIInputScaleKey)
        }
        
        
        guard let outputImage = currentFilter.outputImage else {return}
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
 
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
