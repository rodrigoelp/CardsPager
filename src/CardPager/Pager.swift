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
    private let views: [CenteredCard<Content>]
    private let cardSize: CGSize
    private let padding: CGFloat
    @State private var indexWindow: ItemsWindow? = nil // initialised in an invalid state.
    @GestureState private var dragState = DragState.inactive

    @inlinable init(spacing padding: CGFloat = 20,
                    cardSize: CGSize = .init(width: 300, height: 500),
                    @ViewBuilder content: @escaping () -> [Content]) {
        contentBuilder = content
        views = contentBuilder().map { view in CenteredCard { view } }
        self.padding = padding
        self.cardSize = cardSize
    }

    var body: some View {
        ZStack {
            ForEach(self.indexWindow?.nonActive ?? [], id: \.self) { index in
                self.views[index]
                    .offset(x: self.elementLateralOffset(index))
                    .animation(.interactiveSpring())
                    .scaleEffect(0.85)
            }

            self.indexWindow.map { window in
                self.views[window.active]
                    .offset(x: self.elementLateralOffset(window.active))
                    .animation(.easeInOut)
            }
            VStack {
                Spacer()
                Text("Active: \(String(describing: self.indexWindow?.active))")
                Text(String(describing: self.indexWindow?.nonActive))
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
        guard let indexWindow = indexWindow else { return }
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

        self.indexWindow = indexWindow.update(activeIndex: active)
    }

    private func elementLateralOffset(_ index: Int) -> CGFloat {
        guard let indexWindow = indexWindow else { return 9001 } // It's over 9000!
        if index == indexWindow.active { return dragState.translation.width }
        if index == indexWindow.left { return dragState.translation.width - (cardSize.width + padding) }
        if index == indexWindow.leftMost { return dragState.translation.width - 2*(cardSize.width + padding) }
        if index == indexWindow.right { return dragState.translation.width + cardSize.width + padding }
        if index == indexWindow.rightMost { return dragState.translation.width +  2 * (cardSize.width + padding) }
        return 9001 // It doesn't really matter what value is provided here, it won't be rendered
    }
}

private struct CenteredCard<Card>: View where Card: View {
    private let content: () -> Card
    @inlinable init(@ViewBuilder content: @escaping () -> Card) {
        self.content = content
    }

    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

/// Allows tracking elements in view or that could be displayed if the user dragged them as far as possible.
private struct ItemsWindow {
    let active: Int
    let leftMost: Int?
    let left: Int?
    let right: Int?
    let rightMost: Int?

    let nonActive: [Int]

    private let maxIndex: Int

    init(activeIndex: Int = 0, maxIndex: Int) {
        active = activeIndex
        left = Helper.getLeft(from: active, maxIndex: maxIndex)
        right = Helper.getRight(from: active, maxIndex: maxIndex)
        leftMost = left.flatMap { Helper.getLeft(from: $0, maxIndex: maxIndex) }
        rightMost = right.flatMap { Helper.getRight(from: $0, maxIndex: maxIndex) }
        self.maxIndex = maxIndex
        nonActive = [ leftMost, rightMost, left, right ].compactMap { $0 }
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
