import SwiftUI

private enum DragState {
    case inactive
    case active(translation: CGSize)

    var isDragging: Bool {
        if case .active = self { return true }
        return false
    }

    var translation: CGSize {
        if case let .active(translation) = self {
            return translation
        }
        return .zero
    }
}

struct Pager<Content>: View where Content: View {
    private let contentBuilder: () -> [Content]
    private let views: [Content]
    private let cardSize: CGSize
    @State private var indexWindow = ItemsWindow(activeIndex: 0, maxIndex: 0) // initialised in an invalid state.
    @GestureState private var dragState = DragState.inactive

    @inlinable init(cardSize: CGSize = .init(width: 300, height: 500),
                    @ViewBuilder content: @escaping () -> [Content]) {
        contentBuilder = content
        views = contentBuilder()
        self.cardSize = cardSize
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
        .gesture(
            DragGesture()
                .updating(self.$dragState) { drag, state, trans in
                    state = .active(translation: drag.translation)
            }.onEnded(self.dragEnded))
            .onAppear(perform: {
                self.loadCards()
            })
    }

    private func loadCards() {
        let newWindow = ItemsWindow(activeIndex: 0, maxIndex: self.views.count)
        self.indexWindow = newWindow
        print(String(describing: indexWindow))
    }

    private func dragEnded(value: DragGesture.Value) {
        let halfway = cardSize.width * 0.51
        var active = indexWindow.active
        if value.predictedEndTranslation.width > halfway
            || value.translation.width > halfway {
            if active - 1 >= 0 {
                active = active - 1
            }
        } else if value.predictedEndTranslation.width < -halfway
            || value.translation.width < -halfway {
            if active + 1 < views.count {
                active = active + 1
            }
        }

        indexWindow = indexWindow.update(activeIndex: active)
    }

    private func elementLateralOffset(_ index: Int) -> CGFloat {
        if index == indexWindow.active { return 0 }
        if index == indexWindow.left { return -50 }
        if index == indexWindow.leftMost { return -100 }
        if index == indexWindow.right { return 50 }
        if index == indexWindow.rightMost { return 100 }
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
        guard maxIndex >= 1 && index + 1 < maxIndex else { return nil }
        return index + 1
    }
}
