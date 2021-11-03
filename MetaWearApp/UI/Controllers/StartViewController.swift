//
//  StartViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 11/2/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    let startScreen = UIHostingController(rootView: AnimatedStart())

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(startScreen)
        view.addSubview(startScreen.view)
        startScreen.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController?.delegate = self
        NSLayoutConstraint.activate([
            startScreen.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            startScreen.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            startScreen.view.topAnchor.constraint(equalTo: view.topAnchor),
            startScreen.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

        ])
    }

    @objc func segue() {
        performSegue(withIdentifier: "Scan", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UIColor(.accentColor)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}

extension StartViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let shouldHide = viewController === self
        navigationController.setNavigationBarHidden(shouldHide, animated: animated)
    }
}

// MARK: - Orange Splash Screen

import SwiftUI

struct AnimatedStart: View {

    @Environment(\.colorSchemeContrast) var contrast
    @State private var viewDidAppear = false
    var body: some View {
        GeometryReader { geo in
            let imageWidth = imageWidth(in: geo.size.width)
            let xPosition = xPosition(in: geo.size.width)
            let yPosition = yPosition(forWidth: imageWidth, in: geo.size.height)

            VStack(alignment: .center) {

                logo
                    .frame(width: geo.size.width * 0.3,
                           height: geo.size.height * 0.2,
                           alignment: .center)
                    .padding(.top, geo.size.height * 0.1)

                Spacer()

                instruction
                    .frame(width: min(300, geo.size.width * 0.5))

                Spacer()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Device images
            .background(
                metamotionS
                    .frame(width: imageWidth)
                    .position(x: xPosition.leading, y: yPosition)
            )
            .background(
                mirroredMetamotionS
                    .frame(width: imageWidth)
                    .position(x: xPosition.trailing, y: yPosition)
            )
        }
        .animation(.easeIn.delay(0.75), value: viewDidAppear)
        .background(Color.startScreen.edgesIgnoringSafeArea(.all))
        .onAppear { viewDidAppear = true }

    }

    private func xPosition(in width: CGFloat) -> (leading: CGFloat, trailing: CGFloat) {
        let offset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 25 : -6
        return (offset, width - offset)
    }

    private func imageWidth(in frameWidth: CGFloat) -> CGFloat {
        let max: CGFloat = 750
        let scale = UIDevice.current.userInterfaceIdiom == .pad ? 0.6 : 0.5
        return min(max, scale * frameWidth)
    }

    private func yPosition(forWidth imageWidth: CGFloat, in height: CGFloat) -> CGFloat {
        let scale = UIDevice.current.userInterfaceIdiom == .pad ? 0.4 : 0.66
        return height + (-imageWidth * scale)
    }

    private var instruction: some View {
        Text("Tap\nto connect\nyour nearby\nMetaWears")
            .font(.largeTitle.weight(.medium))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .foregroundColor(logoColor)
            .lineSpacing(5)

            .opacity(viewDidAppear ? 1 : 0)
            .offset(y: viewDidAppear ? 0 : 10)
    }

    private var logoColor: Color { contrast == .increased ? Color(.black) : .white }
    private var logo: some View {
        GlintingMLogo(
            baseColor: logoColor.opacity(0.7),
            glintColor: logoColor,
            strokeWidth: 3
        )
    }

    private var metamotionS: some View {
        Image(Images.metamotionSLarge.catalogName)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(-10))
    }

    private var mirroredMetamotionS: some View {
        Image(Images.metamotionSLarge.catalogName)
            .resizable()
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .scaledToFit()
            .rotationEffect(.degrees(10))
    }
}
