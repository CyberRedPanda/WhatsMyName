//
//  ContentView.swift
//  WhatsMyName
//
//  Created by User23198271 on 8/26/20.
//  Copyright © 2020 Bryan. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var showingDetailView = false
    @State private var imageFinalForMainView = [Image?]()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: People.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \People.name, ascending: true)
    ]) var people: FetchedResults<People>
    
    func deletePerson(at offsets: IndexSet) {
        for offset in offsets {
          //find person in fetch request
            let person = people[offset]
            
            //delete them from the context
            moc.delete(person)
        }
        try? moc.save()
    }
    
    func getDocumentsDirectory(i: Int) -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0].appendingPathComponent(people[i].id?.uuidString ?? "")
    }
    
    func loadImage() {
        var i = 0
        for _ in people {
            guard let starterImage = UIImage(contentsOfFile: getDocumentsDirectory(i: i).path) else { return }
            imageFinalForMainView.append(Image(uiImage: starterImage))
            i += 1
//            print(i)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(people, id: \.self) { person in
                // Navigation link to transfer to detail view on tap
                    NavigationLink(destination: DetailView(person: person)) {
                        if self.imageFinalForMainView.count > 0 {
                        if person.id != nil {
                            self.imageFinalForMainView[self.people.firstIndex(of: person) ?? 0]?
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            }
                        }
                        Text(person.name ?? "Don't know their name!")
                    }.onAppear(perform: self.loadImage)
                }.onDelete(perform: deletePerson)
            }
        .navigationBarTitle("What's My Name?")
    // Button to add new items to list. Image for button is sys plus wrapped in cricle and scaled up
                .navigationBarItems(leading: EditButton(), trailing: Button(action : {
            self.showingDetailView.toggle()
            }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
        .sheet(isPresented: $showingDetailView) {
            AddView(isPresented: self.$showingDetailView).environment(\.managedObjectContext, self.moc)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
