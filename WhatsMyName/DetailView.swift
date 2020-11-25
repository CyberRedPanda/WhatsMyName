//
//  DetailView.swift
//  WhatsMyName
//
//  Created by User23198271 on 8/26/20.
//  Copyright © 2020 Bryan. All rights reserved.
//

import SwiftUI
import CoreData


struct DetailView: View {
    let person: People
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var starterImage: UIImage?
    @State private var imageFinal: Image?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    func deletePerson() {
        moc.delete(person)
        try? self.moc.save()
        presentationMode.wrappedValue.dismiss()
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0].appendingPathComponent(person.id?.uuidString ?? "")
        
    }
    
    func loadImage() {
        guard let starterImage = UIImage(contentsOfFile: getDocumentsDirectory().path) else { return }
        imageFinal = Image(uiImage: starterImage)
    }

    
    var body: some View {
        VStack {
            if person.id != nil {
                imageFinal?
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 300, alignment: .center)
                    Spacer()
            } else {
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 300, height: 300)
            }
            Text("Name: \(person.name ?? "unknown")")
            Text("Date Met: \(dateFormatter.string(from: person.date ?? Date()))")
            Text("Location Met: \(person.location ?? "unknown")")
            Text("This is where you were when you met \(person.name ?? "unknown"):")
                .frame(width: 400)
                .padding(.top, 20)
                .padding(.bottom, 5)
            MapView(person: person)
                .edgesIgnoringSafeArea(.all)
        Spacer()
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("Delete Person"), message: Text("Are you sure you want to delete \(person.name ?? "unknown")?"), primaryButton: .destructive(Text("Delete")) {
                self.deletePerson()
                }, secondaryButton: .cancel()
            )
        }
    .onAppear(perform: loadImage)
        .navigationBarItems(trailing: Button(action: {
            self.showingAlert = true
        }) {
            Image(systemName: "trash")
        })
    }
}





