//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public class AmbientLightSUIVC: MWAmbientLightVM, ObservableObject, AmbientLightVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class BarometerSUIVC: MWBarometerVM, ObservableObject, MWBarometerVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class BatterySUIVC: MWBatteryVM, ObservableObject, BatteryVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class FirmwareSUIVC: MWDetailFirmwareVM, ObservableObject, FirmwareVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class IdentifiersSUIVC: MWIdentifiersVM, ObservableObject, IdentifiersVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class iBeaconSUIVC: MWiBeaconVM, ObservableObject, IBeaconVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class LedSUIVC: MWLedVM, LedVMDelegate, ObservableObject {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

public class MechanicalSwitchSUIVC: MWMechanicalSwitchVM, MechanicalSwitchVMDelegate, ObservableObject {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}


public class ResetSUIVC: MWResetVM, ResetVMDelegate, ObservableObject {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public override init() {
        super.init()
        self.delegate = self
    }
}

