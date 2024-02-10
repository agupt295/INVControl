import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

class LocationManager: ObservableObject {
    static let defaultLocation = CLLocationCoordinate2D(
       latitude: 33.427,
       longitude: -111.939
   )
   
   // state property that represents the current map region
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
   @Published var markers = [
       Location(name: "Tempe", coordinate: defaultLocation)
   ]
}
