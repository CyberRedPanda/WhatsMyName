//
//  MapView.swift
//  WhatsMyName
//
//  Created by User23198271 on 9/2/20.
//  Copyright © 2020 Bryan. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let person: People
    @Environment(\.managedObjectContext) var moc
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let annotation = MKPointAnnotation()
        annotation.title = "You met here!"
        // Come up with a better unwrap than london
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(person.latitude), longitude: CLLocationDegrees(person.longitude))
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
