//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailAccelerometerVM: DetailAccelerometerVM {



    private var accelerometerBMI160StepCount = 0
    private var accelerometerBMI160Data: [(Int64, MblMwCartesianFloat)] = []

    public var delegate: DetailAccelerometerVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailAccelerometerVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}


extension MWDetailAccelerometerVM {

    public func start() {
        if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER) == MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI160 {
            cell(accelerometerBMI160Cell, setHidden: false)
            bmi270 = false
            if loggers["acceleration"] != nil {
                accelerometerBMI160StartLog.isEnabled = false
                accelerometerBMI160StopLog.isEnabled = true
                accelerometerBMI160StartStream.isEnabled = false
                accelerometerBMI160StopStream.isEnabled = false
            } else {
                accelerometerBMI160StartLog.isEnabled = true
                accelerometerBMI160StopLog.isEnabled = false
                accelerometerBMI160StartStream.isEnabled = true
                accelerometerBMI160StopStream.isEnabled = false
            }
        } else if mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER) == MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI270 {
            cell(accelerometerBMI160Cell, setHidden: false)
            bmi270 = true
            if loggers["acceleration"] != nil {
                accelerometerBMI160StartLog.isEnabled = false
                accelerometerBMI160StopLog.isEnabled = true
                accelerometerBMI160StartStream.isEnabled = false
                accelerometerBMI160StopStream.isEnabled = false
            } else {
                accelerometerBMI160StartLog.isEnabled = true
                accelerometerBMI160StopLog.isEnabled = false
                accelerometerBMI160StartStream.isEnabled = true
                accelerometerBMI160StopStream.isEnabled = false
            }
        }
    }

    func updateAccelerometerBMI160Settings() {
        switch self.accelerometerBMI160Scale.selectedSegmentIndex {
        case 0:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_2G)
            self.accelerometerBMI160Graph.fullScale = 2
        case 1:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_4G)
            self.accelerometerBMI160Graph.fullScale = 4
        case 2:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_8G)
            self.accelerometerBMI160Graph.fullScale = 8
        case 3:
            mbl_mw_acc_bosch_set_range(device.board, MBL_MW_ACC_BOSCH_RANGE_16G)
            self.accelerometerBMI160Graph.fullScale = 16
        default:
            fatalError("Unexpected accelerometerBMI160Scale value")
        }
        mbl_mw_acc_set_odr(device.board, Float(accelerometerBMI160Frequency.titleForSegment(at: accelerometerBMI160Frequency.selectedSegmentIndex)!)!)
        mbl_mw_acc_bosch_write_acceleration_config(device.board)
    }
}

// MARK: - Intents

extension MWDetailAccelerometerVM {

    public func x() {
        guard let device = device else { return }


    }

    func userRequestedRequestedToEmailData() {
        var accelerometerData = Data()
        for dataElement in accelerometerBMI160Data {
            accelerometerData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        parent?.export(accelerometerData, titled: "AccData")
    }

    @IBAction func accelerometerBMI160StartStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = true
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = false
        updateAccelerometerBMI160Settings()
        accelerometerBMI160Data.removeAll()
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerBMI160Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            // Add data to data array for saving
            _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
        }
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)

        streamingCleanup[signal] = {
            mbl_mw_acc_stop(self.device.board)
            mbl_mw_acc_disable_acceleration_sampling(self.device.board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
    }


    @IBAction func accelerometerBMI160StopStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = true
        accelerometerBMI160StopStream.isEnabled = false
        accelerometerBMI160StartLog.isEnabled = true
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        streamingCleanup.removeValue(forKey: signal)?()
    }

    @IBAction func accelerometerBMI160StartLogPressed(_ sender: Any) {
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = true
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = false
        updateAccelerometerBMI160Settings()
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(device.board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggers[identifier] = logger!
        }
        mbl_mw_logging_start(device.board, 0)
        mbl_mw_acc_enable_acceleration_sampling(device.board)
        mbl_mw_acc_start(device.board)
    }

    @IBAction func accelerometerBMI160StopLogPressed(_ sender: Any) {
        accelerometerBMI160StartLog.isEnabled = true
        accelerometerBMI160StopLog.isEnabled = false
        accelerometerBMI160StartStream.isEnabled = true
        guard let logger = loggers.removeValue(forKey: "acceleration") else {
            return
        }
        mbl_mw_acc_stop(device.board)
        mbl_mw_acc_disable_acceleration_sampling(device.board)
        if bmi270 {
            mbl_mw_logging_flush_page(device.board)
        }

        updateMBProgressHUDToShowAdded()
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        accelerometerBMI160Data.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.accelerometerBMI160Graph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
            }
            // Add data to data array for saving
            _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
        }

        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: DeviceDetailViewController = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.hud.progress = Float(progress)
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.hud.mode = .indeterminate
                    _self.hud.label.text = "Clearing Log..."
                }
                _self.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.hud.hide(animated: true)
                        if error != nil {
                            _self.deviceConnected()
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            print("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            print("received_unhandled_entry")
        }
        mbl_mw_logging_download(device.board, 100, &handlers)
    }



    @IBAction func accelerometerBMI160StartOrientPressed(_ sender: Any) {
        if !bmi270 {
            accelerometerBMI160StartOrient.isEnabled = false
            accelerometerBMI160StopOrient.isEnabled = true
            updateAccelerometerBMI160Settings()
            let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(device.board)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let orientation: MblMwSensorOrientation = obj!.pointee.valueAs()
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                DispatchQueue.main.async {
                    switch orientation {
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT:
                        _self.accelerometerBMI160OrientLabel.text = "Portrait Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN:
                        _self.accelerometerBMI160OrientLabel.text = "Portrait Upside Down Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT:
                        _self.accelerometerBMI160OrientLabel.text = "Landscape Left Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT:
                        _self.accelerometerBMI160OrientLabel.text = "Landscape Right Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT:
                        _self.accelerometerBMI160OrientLabel.text = "Portrait Face Down"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN:
                        _self.accelerometerBMI160OrientLabel.text = "Portrait Upside Down Face Down"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT:
                        _self.accelerometerBMI160OrientLabel.text = "Landscape Left Face Down"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT:
                        _self.accelerometerBMI160OrientLabel.text = "Landscape Right Face Down"
                    default:
                        _self.accelerometerBMI160OrientLabel.text = "N/A"
                    }
                }
            }
            mbl_mw_acc_bosch_enable_orientation_detection(device.board)
            mbl_mw_acc_start(device.board)

            streamingCleanup[signal] = {
                mbl_mw_acc_stop(self.device.board)
                mbl_mw_acc_bosch_disable_orientation_detection(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        }
    }

    @IBAction func accelerometerBMI160StopOrientPressed(_ sender: Any) {
        if !bmi270 {
            accelerometerBMI160StartOrient.isEnabled = true
            accelerometerBMI160StopOrient.isEnabled = false
            let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(device.board)!
            streamingCleanup.removeValue(forKey: signal)?()
            accelerometerBMI160OrientLabel.text = "XXXXXXXXXXXXXX"
        }
    }

    @IBAction func accelerometerBMI160StartStepPressed(_ sender: Any) {
        if !bmi270 {
            accelerometerBMI160StartStep.isEnabled = false
            accelerometerBMI160StopStep.isEnabled = true
            updateAccelerometerBMI160Settings()
            let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(device.board)!
            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let _self: DeviceDetailViewController = bridge(ptr: context!)
                _self.accelerometerBMI160StepCount += 1
                DispatchQueue.main.async {
                    _self.accelerometerBMI160StepLabel.text = "Step Count: \(_self.accelerometerBMI160StepCount)"
                }
            }
            mbl_mw_acc_bmi160_enable_step_detector(device.board)
            mbl_mw_acc_start(device.board)

            streamingCleanup[signal] = {
                mbl_mw_acc_stop(self.device.board)
                mbl_mw_acc_bmi160_disable_step_detector(self.device.board)
                mbl_mw_datasignal_unsubscribe(signal)
            }
        }
    }

    @IBAction func accelerometerBMI160StopStepPressed(_ sender: Any) {
        if !bmi270 {
            accelerometerBMI160StartStep.isEnabled = true
            accelerometerBMI160StopStep.isEnabled = false
            let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(device.board)!
            streamingCleanup.removeValue(forKey: signal)?()
            accelerometerBMI160StepCount = 0
            accelerometerBMI160StepLabel.text = "Step Count: 0"
        }
    }
}
