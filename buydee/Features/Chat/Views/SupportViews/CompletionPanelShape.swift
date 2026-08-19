import SwiftUI

struct CompletionPanelShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curveDepth = min(64, rect.height * 0.12)

        path.move(to: CGPoint(x: 0, y: curveDepth))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: curveDepth),
            control: CGPoint(x: rect.midX, y: -curveDepth)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
