//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            Pager(cardSize: CGSize(width: geometry.size.height - 20, height: geometry.size.height - 40)) {
                [
                    Group { Text("Page 0") }
                        .asCard(geometry: geometry, backgroundColor: .purple),

                    Group { Text("Page 1") }
                        .asCard(geometry: geometry, backgroundColor: .blue),

                    Group { Text("Page 2") }
                        .asCard(geometry: geometry, backgroundColor: .green),

                    Group { Text("Page 3") }
                        .asCard(geometry: geometry, backgroundColor: .orange),

                    Group { Text("Page 4") }
                        .asCard(geometry: geometry, backgroundColor: .yellow),

                    Group { Text("Page 5") }
                        .asCard(geometry: geometry, backgroundColor: .red),

                    Group { Text("Page 6") }
                        .asCard(geometry: geometry, backgroundColor: .purple)
                ]
            }
        }.edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
    }
}

extension View {
    func asCard(geometry: GeometryProxy,
                backgroundColor: Color,
                foregroundColor: Color = .white) -> some View {
        self
            .frame(width: geometry.size.height - 20, height: geometry.size.height)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
