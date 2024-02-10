import SwiftUI
import CoreLocation

struct earthquakedata: Decodable {
    let earthquakes: [Earthquake]
}

struct Earthquake: Decodable {
    let datetime: String
    let depth: Double
    let lng: Double
    let src: String
    let eqid: String
    let magnitude: Double
    let lat: Double
}

struct WebAPIView: View {
    @State private var user: DBUser? = nil
    
    @State private var Magnitudes = [String]()
    @State private var DateTime = [String]()
    @State var location: String = ""
    @State var lat: String = "NULL"
    @State var long: String = "NULL"
    @State var eqView: Bool = false
    @State var isLoading = true
    @State var latLonFound = false
    
    var body: some View {
        
        if isLoading && !latLonFound {
            VStack{
                Text("Loading...")
                Text("Retrieving Data From Database...")
            }
            .onAppear {
                Task {
                    await loadCurrentUser()
                    location = (user?.warehouseLocation)!
                    
                    Task {
                        do {
                            let coordinate = try await getCoordinates(for: location)
                            self.long = String(format: "%.2f", coordinate.longitude)
                            self.lat = String(format: "%.2f", coordinate.latitude)
                            
                            if (self.long != "NULL" && self.lat != "NULL") {
                                // Construct the URL using lat and long here...
                                let urlAsString = "http://api.geonames.org/earthquakesJSON?north=\(Double(self.long)! + 10.0)&south=\(Double(self.long)! - 10.0)&east=\(Double(self.lat)! + 10.0)&west=\(Double(self.lat)! - 10.0)&username=agupt295"
                                
                                let url = URL(string: urlAsString)!
                                let urlSession = URLSession.shared
                                let (data, _) = try await urlSession.data(from: url)
                                let decodedData = try JSONDecoder().decode(earthquakedata.self, from: data)
                                
                                for i in 0..<min(10, decodedData.earthquakes.count) {
                                    self.Magnitudes.append(String(decodedData.earthquakes[i].magnitude))
                                    self.DateTime.append(decodedData.earthquakes[i].datetime)
                                }
                            }
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                    latLonFound = true
                    isLoading = false
                }
            }
            
        } else {
            VStack {
                Text("Recent EQ_data")
                    .font(.title)
                
                if !Magnitudes.isEmpty && !DateTime.isEmpty {
                    ForEach(0..<min(10, min(Magnitudes.count, DateTime.count))) { index in
                        HStack {
                            Text("Magnitude:\(Magnitudes[index])")
                            Text("Date/Time:\(DateTime[index])")
                        }
                    }
                }
                Spacer()
                
                Button(action: {
                    UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: HomePage())
                }) {
                    Image(systemName: "house.circle.fill") .font(.system(size: 40))
                }
            }
        }
    }
    
    func getCoordinates(for address: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location else {
            throw NSError(domain: "LocationErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location not found"])
        }
        return location.coordinate
    }
    
    func loadCurrentUser() async {
        do {
            let authDataResult = AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult!.uid)
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
