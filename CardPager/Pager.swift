import SwiftUI

struct Pager<Content>: View where Content: View {
    private let contentBuilder: () -> [Content]
    private let views: [Content]
    @State private var indexWindow = ItemsWindow(activeIndex: 0, maxIndex: 0) // initialised in an invalid state.

    @inlinable init(@ViewBuilder content: @escaping () -> [Content]) {
        contentBuilder = content
        views = contentBuilder()
    }

    var body: some View {
        ZStack {
            ForEach(0..<self.views.count) { index in
                VStack {
                    Spacer()
                    self.views[index]
                    Spacer()
                }.offset(x: self.elementLateralOffset(index))
            }
        }
            .onAppear(perform: {
                self.loadCards()
            })
    }

    private func loadCards() {
        let newWindow = ItemsWindow(activeIndex: 0, maxIndex: self.views.count)
        self.indexWindow = newWindow
        print(String(describing: indexWindow))
    }

    private func elementLateralOffset(_ index: Int) -> CGFloat {
        if index == indexWindow.active { return 0 }
        if index == indexWindow.left { return -5 }
        if index == indexWindow.leftMost { return -10 }
        if index == indexWindow.right { return 5 }
        if index == indexWindow.rightMost { return 10 }
        return 900
    }
}

/// Allows tracking elements in view or that could be displayed if the user dragged them as far as possible.
private struct ItemsWindow {
    let active: Int
    let leftMost: Int?
    let left: Int?
    let right: Int?
    let rightMost: Int?

    private let maxIndex: Int

    init(activeIndex: Int = 0, maxIndex: Int) {
        active = activeIndex
        left = Helper.getLeft(from: active, maxIndex: maxIndex)
        right = Helper.getRight(from: active, maxIndex: maxIndex)
        leftMost = left.flatMap { Helper.getLeft(from: $0, maxIndex: maxIndex) }
        rightMost = right.flatMap { Helper.getRight(from: $0, maxIndex: maxIndex) }
        self.maxIndex = maxIndex
    }

    func update(activeIndex: Int) -> ItemsWindow {
        return .init(activeIndex: activeIndex, maxIndex: maxIndex)
    }
}

private enum Helper {
    static func getLeft(from index: Int, maxIndex: Int) -> Int? {
        guard maxIndex >= 1 && index > 0 else {
            // not much to do here, uh? no element to the left of the current one.
            return nil
        }
        return index - 1
    }

    static func getRight(from index: Int, maxIndex: Int) -> Int? {
        guard maxIndex >= 1 && index < maxIndex else { return nil }
        return index + 1
    }
}
