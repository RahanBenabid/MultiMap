//
//  ContentView.swift
//  MultiMap
//
//  Created by Rahan Benabid on 27/6/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var locations = [Location]()
    @State private var twice: Bool = false
    @AppStorage("searchText") private var searchText = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span:  MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @State private var selectedLocations = Set<Location>()
    
    // handles searching
    func runSearch() {
        let searchRequest = MKLocalSearch.Request()
        
        
        searchRequest.naturalLanguageQuery = searchText
        //searchRequest.region = region /// does something idk lol, add later and see
        
        let search = MKLocalSearch(request: searchRequest)
            
        search.start { response, error in
            guard let response = response else { return }   // we make sure we get a response
            guard let item = response.mapItems.first else { return }    // give us the top research hit
            guard let itemName = item.name, let itemLocation = item.placemark.location, let itemCountry = item.placemark.country else { return }
            
            let newLocation = Location(name: itemName, latitude: itemLocation.coordinate.latitude, longitude: itemLocation.coordinate.longitude, country: itemCountry)
            
            locations.contains { Location in
                if (Location.name == newLocation.name) {
                    twice = true
                    return false
                }
                return true
            }
                
            locations.append(newLocation)
            selectedLocations = [newLocation]
            searchText = ""
        }
    }
    
    // hendles when the user wants to delete locations they don't want, it runs whenever the user presses backspace or delete
    func delete(_ location: Location) {
        guard let index = locations.firstIndex(of: location) else { return }
        locations.remove(at: index)
    }
    
    var body: some View {
        NavigationView {
            List(locations, selection: $selectedLocations) { location in
                Text(location.name)
                    .tag(location) // the tag location tells SwiftUI that the text views indentify as the locations themselves
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            delete(location)
                        }
                    }
            }
            .frame(minWidth: 200)
            .searchable(text: $searchText, placement: .sidebar)
            .onSubmit(of: .search, runSearch)
            .onDeleteCommand {
                for location in selectedLocations {
                    delete(location)
                }
            }
            .alert("You entered this location already!", isPresented: $twice) {}
            
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Text(location.name)
                        .font(.headline)
                        .padding(5)
                        .padding(.horizontal, 5)
                        .background(.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .ignoresSafeArea(.all)
        }
        // Whenever our selection changes
        .onChange(of: selectedLocations, {_, _ in
            var visibleMap = MKMapRect.null
            for location in selectedLocations {
                let mapPoint = MKMapPoint(location.coordinate)
                let pointRect = MKMapRect(x: mapPoint.x - 100_000, y: mapPoint.y - 100_000, width: 200_000, height: 200_000)
                visibleMap = visibleMap.union(pointRect)
            }
            var newRegion = MKCoordinateRegion(visibleMap)
            newRegion.span.latitudeDelta *= 1.5
            newRegion.span.longitudeDelta *= 1.5
            withAnimation {
                region = newRegion
            }
        })
    }
}

#Preview {
    ContentView()
}
