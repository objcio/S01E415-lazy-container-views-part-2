//

import SwiftUI

struct LazyVStackLayout: Layout {
//    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {

        var result: CGSize = .zero

        for s in subviews {
            let size = s.sizeThatFits(.init(width: proposal.width, height: nil))
            result.height += size.height
            result.width = max(result.width, size.width)
        }
        return result
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentY: CGFloat = 0
        for s in subviews {
            var point = bounds.origin
            point.y += currentY
            let prop = ProposedViewSize(width: proposal.width, height: nil)
            let size = s.sizeThatFits(prop)
            s.place(at: point, proposal: prop)
            currentY += size.height
        }
    }
}

struct MyLazyVStack<Content: View>: View {
    @ViewBuilder var content: Content
    @State var numberOfSubviewsVisible = 1
    @State var maxY: CGFloat = 0

    var body: some View {
        LazyVStackLayout {
            Group(subviews: content) { coll in
                coll[0..<numberOfSubviewsVisible]
            }
        }
        // todo sequence is important
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.bounds(of: .scrollView)!.maxY
        } action: { newValue in
            maxY = newValue
        }
        .onGeometryChange(for: CGFloat.self, of: { $0.size.height }, action: { newValue in
            if newValue < maxY {
                numberOfSubviewsVisible += 1
            }
        })
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {
            MyLazyVStack {
                ForEach(0..<100) { ix in
                    Text("item \(ix)")
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .onAppear { print("onAppear", ix) }
                }
            }


        }
    }
}

#Preview {
    ContentView()
}
