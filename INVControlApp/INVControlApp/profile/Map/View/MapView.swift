import MapKit
import SwiftUI

struct MapView: View {
    
    @StateObject var viewModel = MapViewModel()
    @State var wareHouseLocation : String
    
    var body: some View {
        VStack{
            Map(position: $viewModel.defaultRegion){
                Marker(wareHouseLocation , coordinate: viewModel.warehouseLoc)
            }
        }.onAppear{
            viewModel.setMap(cityName: wareHouseLocation)
            
        }.onChange(of: wareHouseLocation){
            viewModel.setMap(cityName: wareHouseLocation)
        }
    }
}
