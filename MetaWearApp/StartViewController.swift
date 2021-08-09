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




import SwiftUI

struct AnimatedStart: View {

    @Environment(\.colorSchemeContrast) var contrast
    @State private var viewDidAppear = false
    var body: some View {
        GeometryReader { geo in

            VStack(alignment: .center) {

                logo
                    .frame(width: geo.size.width * 0.3,
                           height: geo.size.height * 0.2,
                           alignment: .center)
                    .padding(.top, geo.size.height * 0.1)

                Spacer()

                instruction
                    .frame(width: min(300, geo.size.width * 0.5))
                    .opacity(viewDidAppear ? 1 : 0)
                    .offset(y: viewDidAppear ? 0 : 10)

                Spacer()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                devices.squared(geo.size.longestSide() * 1.2,
                                alignment: .bottom)
                    .offset(y: -geo.size.height * 0.02)
            )
        }
        .animation(.easeIn.delay(0.75), value: viewDidAppear)
        .background(Color("StartScreen").edgesIgnoringSafeArea(.all))
        .onAppear { viewDidAppear = true }

    }


    private var instruction: some View {
        Text("Tap\nto connect\nyour nearby\nMetaWears")
            .font(.largeTitle.weight(.medium))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .foregroundColor(logoColor)
    }

    private var logoColor: Color { contrast == .increased ? Color(.black) : .white }
    private var logo: some View {
        GlintingMLogo(
            baseColor: logoColor.opacity(0.7),
            glintColor: logoColor,
            strokeWidth: 3
        )
    }

    private var devices: some View {
        HStack {
            Image("metamotionS")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(-10))
                .frame(maxWidth: 700)

            Spacer()

            Image("metamotionC")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(10))
                .frame(maxWidth: 700)
        }
    }
}

extension CGSize {
    func shortestSide() -> CGFloat {
        min(width, height)
    }

    func longestSide() -> CGFloat {
        max(width, height)
    }
}

extension View {
    func squared(_ length: CGFloat, alignment: Alignment) -> some View {
        frame(width: length, height: length, alignment: alignment)
    }
}
