//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct GlintingMLogo: View {

    var baseColor: Color
    var glintColor: Color
    var strokeWidth: CGFloat

    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().dropFirst()
    @State private var trimFrom: CGFloat = 0
    @State private var trimTo: CGFloat = 0

    var body: some View {
        ZStack {

            MbientLabLogoPath()
                .stroke(baseColor, style: .init(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .scaledToFit()

            MbientLabLogoPath()
                .trim(from: trimFrom, to: trimTo)
                .stroke(glintColor, style: .init(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .scaledToFit()
        }
        .animation(.spring(), value: trimTo)
        .animation(.spring(), value: trimFrom)
        .onReceive(timer) { _ in
            flash()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: flash)
        }
    }

    func flash() {

        trimTo = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            trimFrom = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                trimFrom = 0
                trimTo = 0
            }
        }

    }
}

struct MbientLabLogoPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.30369*width, y: 1.08766*height))
        path.addLine(to: CGPoint(x: 0.47925*width, y: 1.08766*height))
        path.addLine(to: CGPoint(x: 0.47925*width, y: 1.18805*height))
        path.addLine(to: CGPoint(x: 0.48169*width, y: 1.18805*height))
        path.addCurve(to: CGPoint(x: 0.50607*width, y: 1.14546*height), control1: CGPoint(x: 0.48738*width, y: 1.17386*height), control2: CGPoint(x: 0.4955*width, y: 1.15966*height))
        path.addCurve(to: CGPoint(x: 0.54386*width, y: 1.10744*height), control1: CGPoint(x: 0.51664*width, y: 1.13127*height), control2: CGPoint(x: 0.52923*width, y: 1.11859*height))
        path.addCurve(to: CGPoint(x: 0.59385*width, y: 1.08006*height), control1: CGPoint(x: 0.5585*width, y: 1.09628*height), control2: CGPoint(x: 0.57516*width, y: 1.08716*height))
        path.addCurve(to: CGPoint(x: 0.65481*width, y: 1.06942*height), control1: CGPoint(x: 0.61255*width, y: 1.07296*height), control2: CGPoint(x: 0.63287*width, y: 1.06942*height))
        path.addCurve(to: CGPoint(x: 0.76515*width, y: 1.10135*height), control1: CGPoint(x: 0.69626*width, y: 1.06942*height), control2: CGPoint(x: 0.73304*width, y: 1.08006*height))
        path.addCurve(to: CGPoint(x: 0.83769*width, y: 1.20174*height), control1: CGPoint(x: 0.79725*width, y: 1.12265*height), control2: CGPoint(x: 0.82143*width, y: 1.15611*height))
        path.addCurve(to: CGPoint(x: 0.9145*width, y: 1.09983*height), control1: CGPoint(x: 0.85882*width, y: 1.15408*height), control2: CGPoint(x: 0.88443*width, y: 1.12012*height))
        path.addCurve(to: CGPoint(x: 1.02544*width, y: 1.06942*height), control1: CGPoint(x: 0.94457*width, y: 1.07955*height), control2: CGPoint(x: 0.98155*width, y: 1.06942*height))
        path.addCurve(to: CGPoint(x: 1.12603*width, y: 1.09451*height), control1: CGPoint(x: 1.06527*width, y: 1.06942*height), control2: CGPoint(x: 1.0988*width, y: 1.07778*height))
        path.addCurve(to: CGPoint(x: 1.19064*width, y: 1.16296*height), control1: CGPoint(x: 1.15326*width, y: 1.11124*height), control2: CGPoint(x: 1.1748*width, y: 1.13406*height))
        path.addCurve(to: CGPoint(x: 1.22478*width, y: 1.26486*height), control1: CGPoint(x: 1.20649*width, y: 1.19185*height), control2: CGPoint(x: 1.21787*width, y: 1.22582*height))
        path.addCurve(to: CGPoint(x: 1.23515*width, y: 1.39035*height), control1: CGPoint(x: 1.23169*width, y: 1.3039*height), control2: CGPoint(x: 1.23515*width, y: 1.34573*height))
        path.addLine(to: CGPoint(x: 1.23515*width, y: 1.82688*height))
        path.addLine(to: CGPoint(x: 1.05227*width, y: 1.82688*height))
        path.addLine(to: CGPoint(x: 1.05227*width, y: 1.39643*height))
        path.addCurve(to: CGPoint(x: 1.03459*width, y: 1.30745*height), control1: CGPoint(x: 1.05227*width, y: 1.36196*height), control2: CGPoint(x: 1.04637*width, y: 1.3323*height))
        path.addCurve(to: CGPoint(x: 0.9718*width, y: 1.27019*height), control1: CGPoint(x: 1.0228*width, y: 1.28261*height), control2: CGPoint(x: 1.00187*width, y: 1.27019*height))
        path.addCurve(to: CGPoint(x: 0.91876*width, y: 1.28312*height), control1: CGPoint(x: 0.95067*width, y: 1.27019*height), control2: CGPoint(x: 0.93299*width, y: 1.2745*height))
        path.addCurve(to: CGPoint(x: 0.88463*width, y: 1.31886*height), control1: CGPoint(x: 0.90454*width, y: 1.29173*height), control2: CGPoint(x: 0.89316*width, y: 1.30365*height))
        path.addCurve(to: CGPoint(x: 0.86634*width, y: 1.3721*height), control1: CGPoint(x: 0.87609*width, y: 1.33407*height), control2: CGPoint(x: 0.87*width, y: 1.35181*height))
        path.addCurve(to: CGPoint(x: 0.86085*width, y: 1.43598*height), control1: CGPoint(x: 0.86268*width, y: 1.39238*height), control2: CGPoint(x: 0.86085*width, y: 1.41367*height))
        path.addLine(to: CGPoint(x: 0.86085*width, y: 1.82688*height))
        path.addLine(to: CGPoint(x: 0.67797*width, y: 1.82688*height))
        path.addLine(to: CGPoint(x: 0.67797*width, y: 1.43598*height))
        path.addCurve(to: CGPoint(x: 0.67676*width, y: 1.38731*height), control1: CGPoint(x: 0.67797*width, y: 1.4228*height), control2: CGPoint(x: 0.67757*width, y: 1.40657*height))
        path.addCurve(to: CGPoint(x: 0.66822*width, y: 1.33255*height), control1: CGPoint(x: 0.67594*width, y: 1.36804*height), control2: CGPoint(x: 0.6731*width, y: 1.34979*height))
        path.addCurve(to: CGPoint(x: 0.64445*width, y: 1.28844*height), control1: CGPoint(x: 0.66334*width, y: 1.31531*height), control2: CGPoint(x: 0.65542*width, y: 1.30061*height))
        path.addCurve(to: CGPoint(x: 0.59629*width, y: 1.27019*height), control1: CGPoint(x: 0.63348*width, y: 1.27627*height), control2: CGPoint(x: 0.61742*width, y: 1.27019*height))
        path.addCurve(to: CGPoint(x: 0.53899*width, y: 1.28616*height), control1: CGPoint(x: 0.57272*width, y: 1.27019*height), control2: CGPoint(x: 0.55362*width, y: 1.27551*height))
        path.addCurve(to: CGPoint(x: 0.50546*width, y: 1.32875*height), control1: CGPoint(x: 0.52436*width, y: 1.29681*height), control2: CGPoint(x: 0.51318*width, y: 1.311*height))
        path.addCurve(to: CGPoint(x: 0.49022*width, y: 1.38883*height), control1: CGPoint(x: 0.49774*width, y: 1.34649*height), control2: CGPoint(x: 0.49266*width, y: 1.36652*height))
        path.addCurve(to: CGPoint(x: 0.48656*width, y: 1.4588*height), control1: CGPoint(x: 0.48778*width, y: 1.41114*height), control2: CGPoint(x: 0.48656*width, y: 1.43446*height))
        path.addLine(to: CGPoint(x: 0.48656*width, y: 1.82688*height))
        path.addLine(to: CGPoint(x: 0.30369*width, y: 1.82688*height))
        path.addLine(to: CGPoint(x: 0.30369*width, y: 1.08766*height))
        path.closeSubpath()
        return path.applying(.init(translationX: width * -0.28, y: -height * 0.95))
    }
}
