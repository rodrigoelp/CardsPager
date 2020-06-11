//

import SwiftUI
import Pager

struct ContentView: View {
    var body: some View {
        Pager {
            [
                Group { Text("Page 0") }
                    .asCard(backgroundColor: .purple),

                Group { Text("Page 1") }
                    .asCard(backgroundColor: .blue),

                Group { Text("Page 2") }
                    .asCard(backgroundColor: .green),

                Group { Text("Page 3") }
                    .asCard(backgroundColor: .orange),

                Group { Text("Page 4") }
                    .asCard(backgroundColor: .yellow),

                Group { Text("Page 5") }
                    .asCard(backgroundColor: .red),

                Group { Text("Page 6") }
                    .asCard(backgroundColor: .purple)
            ]
        }
    }
}

extension View {
    func asCard(backgroundColor: Color, foregroundColor: Color = .white) -> some View {
        self
            .frame(width: 300, height: 500)
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
