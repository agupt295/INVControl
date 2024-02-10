import SwiftUI
import MapKit

struct MapView2: View {
    var cityName: String
    @ObservedObject var mapInfo: LocationManager
    
    var body: some View {
        
        VStack {
            Map(coordinateRegion: $mapInfo.region,
                interactionModes: .all,
                annotationItems: mapInfo.markers) { location in
                    MapAnnotation(coordinate: location.coordinate){
                        VStack {
                            Text(location.name)
                                .font(.caption)
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
            }
                .ignoresSafeArea()
            
            HStack(spacing: 10){
                TextField("", text: .constant(" Longitude: \(mapInfo.markers.first?.coordinate.longitude ?? 0.0)"))
                    .disabled(true)
                TextField("", text: .constant(" Latitude: \(mapInfo.markers.first?.coordinate.latitude ?? 0.0)"))
                    .disabled(true)
            }
        }
        .onAppear {
            geoCoder(city_name: "India") // self.user?.warehouseLocation
        }
    }
    
    func geoCoder(city_name: String) {
        let geocoder = CLGeocoder()
        let addressString = city_name
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error != nil {
                print("Geocode failed: \(error!.localizedDescription)")
                
            } else if placemarks!.count > 0 {
                let location = placemarks![0].location
                
                DispatchQueue.main.async
                {
                    self.mapInfo.region.center = location!.coordinate
                  //  self.mapInfo.markers[0].name = placemarks![0].locality!
                    self.mapInfo.markers[0].coordinate = location!.coordinate
                }
            }
        }
    }
}
