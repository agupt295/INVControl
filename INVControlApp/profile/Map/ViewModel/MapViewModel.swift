import MapKit
import SwiftUI

@MainActor
final class MapViewModel : ObservableObject{
    @Published var warehouseLoc : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00)
    @Published var selectedRegion : MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 33.414, longitude: -111.921) , latitudinalMeters: 10000 , longitudinalMeters: 10000)
    @Published var defaultRegion : MapCameraPosition = .region(.userRegion)
    
    func setMap(cityName : String){
        getCoordinates(cityName: cityName) { coordinateRegion, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCoordinates(cityName: String, completion: @escaping (MKCoordinateRegion?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let coordinates = location.coordinate
                let coordinateRegion = MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 1000 , longitudeDelta: 1000)
                )
                self.warehouseLoc = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                self.selectedRegion = MKCoordinateRegion(center: self.warehouseLoc , latitudinalMeters: 50000, longitudinalMeters: 50000)
                self.defaultRegion = .region(self.selectedRegion)
                completion(coordinateRegion, nil)
                
            } else {
                completion(nil, nil)
            }
        }
    }
}

extension CLLocationCoordinate2D{
    static var userLocation : CLLocationCoordinate2D{
        return .init(latitude: 33.414, longitude: -111.921)
    }
}

extension MKCoordinateRegion {
    static var userRegion : MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}
