import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = false

    var body: some View {
        VStack {
            Button("Show Sheet") {
                isSheetPresented.toggle()
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            PresentedView()
                .background(Color.red.ignoresSafeArea())
        }
    }
}

struct PresentedView: View {
    var body: some View {
        Text("This is the presented view")
    }
}

#Preview{
    ContentView()
}
