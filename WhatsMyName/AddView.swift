//
//  AddView.swift
//  WhatsMyName
//
//  Created by User23198271 on 8/26/20.
//  Copyright © 2020 Bryan. All rights reserved.
//

import SwiftUI
import CoreLocation

struct AddView: View {
    let locationFetcher = LocationFetcher()
    @State private var name = ""
    @State private var location = ""
    @State private var dateMet = Date()
    @State private var coordinates = CLLocationCoordinate2D()
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) var moc
    // State value for image selection
    @State private var image: Image?
    // State for whether image picker is being shown
    @State private var showingImagePicker = false
    @State private var idForImage = UUID()
    // State variable to store selected image
    @State private var inputImage: UIImage?
    // Method to save image to the above variable
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    // Method to get documetns directory
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func saveAsJPEG() {
        if inputImage != nil {
            let saveThisImage = inputImage!
        if let jpegData = saveThisImage.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: self.getDocumentsDirectory().appendingPathComponent(idForImage.uuidString), options: [.atomicWrite, .completeFileProtection])
            }
        }
    }
    
    var body: some View {
        NavigationView {
        VStack {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Location Met", text: $location)
            }
            Section {
                DatePicker("When did you meet?", selection: $dateMet, in: ...Date(), displayedComponents: .date)
            }
            Section {
                    VStack {
                    Button("Save Location Met") {
                        if let location = self.locationFetcher.lastKnownLocation {
                            print("Your location is \(location)")
                            self.coordinates = location
                        } else {
                            print("Your location is unknown")
                        }
                    }
                }
            }
            Button(action: {
                self.showingImagePicker = true
            }) {
                HStack {
                    Spacer()
                    if image != nil {
                        image?
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300, alignment: .center)
                                Spacer()
                    } else {
                        Image(systemName: "person.badge.plus.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100, alignment: .center)
                                Spacer()
                        }
                    }
                }
            }
        }
    .navigationBarTitle("Whats My Name?")
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .navigationBarItems(trailing: Button(action: {
            // Attempt to convert image to jpeg data and save to documents directory
            self.saveAsJPEG()
            
            let newPerson = People(context: self.moc)
            newPerson.name = self.name
            newPerson.id = self.idForImage
            newPerson.location = self.location
            newPerson.date = self.dateMet
            newPerson.latitude = Int16(self.coordinates.latitude)
            newPerson.longitude = Int16(self.coordinates.longitude)
            
            try? self.moc.save()
            
            self.isPresented = false
        }) {
            Text("save")
            })
        }
    }
}

// Class to get user's location

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}
