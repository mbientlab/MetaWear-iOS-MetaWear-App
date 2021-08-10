//
//  Menus.swift
//  Menus
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct Menus: Commands {

    @ObservedObject var prefs: PreferencesStore

    var body: some Commands {
        HelpMenuCommands()
        SidebarCommands()
        ViewMenuCommands(prefs: prefs)
    }
}

/// Removes the help dialog as we have not built the HTML package
struct HelpMenuCommands: Commands {

    var body: some Commands {
        CommandGroup(replacing: .help) {

        }
    }
}

struct ViewMenuCommands: Commands {

    @ObservedObject var prefs: PreferencesStore

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            FontFacePicker(prefs: prefs)
        }
    }

    struct FontFacePicker: View {

        @ObservedObject var prefs: PreferencesStore
        var label: String = "Fonts for Dyslexia"

        private var binding: Binding<FontFace> {
            Binding { [weak prefs] in
                prefs?.font ?? .system
            } set: { [weak prefs] newState in
                prefs?.setFont(face: newState)
            }
        }

        var body: some View {
            Picker(label, selection: binding) {
                ForEach(FontFace.allCases) { face in
                    Text(face.name).tag(face)
                }
            }
        }
    }
}

