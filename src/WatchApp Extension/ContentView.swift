//

import SwiftUI

struct ContentView: View {
    @State var isToggled: Bool = false
    var body: some View {
        GeometryReader { geometry in
            Pager(cardSize: CGSize(width: geometry.size.height - 20, height: geometry.size.height - 40)) {
                [
                    AnyView(
                        VStack {
                            Text("Some title.")
                            Toggle(isOn: self.$isToggled, label: { Text("Page 0") })
                        }.padding(20)
                    )
                        .asCard(geometry: geometry, backgroundColor: .purple),

                    AnyView(Text("Page 1") )
                        .asCard(geometry: geometry, backgroundColor: .blue),

                    AnyView(Text("Page 2") )
                        .asCard(geometry: geometry, backgroundColor: .green),

                    AnyView(Text("Page 3") )
                        .asCard(geometry: geometry, backgroundColor: .orange),

                    AnyView(Text("Page 4") )
                        .asCard(geometry: geometry, backgroundColor: .yellow),

                    AnyView(Text("Page 5") )
                        .asCard(geometry: geometry, backgroundColor: .red),
                    
                    AnyView(Text("Page 6") )
                        .asCard(geometry: geometry, backgroundColor: .purple)
                ]
            }
        }.sheet(isPresented: self.$isToggled, content: {
            VStack {
                Text("Something something dark side.")
            }
        })
            .edgesIgnoringSafeArea(.all)
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
