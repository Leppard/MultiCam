//
//  ViewController.swift
//  MultiCam
//
//  Created by Leppard on 2020/4/7.
//  Copyright © 2020 Leppard. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet var frontBtn: UIButton!
    @IBOutlet var backBtn: UIButton!
    
    @IBOutlet var captureBtn: UIView!
    @IBAction func frontBtnDidTap(_ sender: UIButton) {
        frontBtn.isSelected.toggle()
        toggleFrontSession(enabled: frontBtn.isSelected)
    }
    
    @IBAction func backBtnDidTap(_ sender: UIButton) {
        backBtn.isSelected.toggle()
        toggleBackSession(enabled: backBtn.isSelected)
    }
    
    
    let frontLayer = AVCaptureVideoPreviewLayer()
    let backLayer  = AVCaptureVideoPreviewLayer()
    
    let session = AVCaptureMultiCamSession()
     
    var frontConnection: AVCaptureConnection!
    var backConnection:  AVCaptureConnection!
    
    let photoOutput = AVCapturePhotoOutput()
    
    var orientation = UIDevice.current.orientation

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        printSupportedCombination()
        
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("Multi Camera Not Supported")
            return
        }

        frontLayer.setSessionWithNoConnection(session)
        backLayer.setSessionWithNoConnection(session)

        guard let frontDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .depthData, position: .front) else {
            print("ERROR: Device Not Suppored")
            return
        }
        guard let backDevice  = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("ERROR: Device Not Suppored")
            return
        }

        do {
            let frontInput = try AVCaptureDeviceInput(device: frontDevice)
            let backInput  = try AVCaptureDeviceInput(device: backDevice)

            if session.canAddInput(frontInput) {
                session.addInputWithNoConnections(frontInput)
            }

            if session.canAddInput(backInput) {
                session.addInputWithNoConnections(backInput)
            }
            

            if let fPort = frontInput.ports(for: .video, sourceDeviceType: frontDevice.deviceType, sourceDevicePosition: frontDevice.position).first {
                frontConnection = AVCaptureConnection(inputPort: fPort, videoPreviewLayer: frontLayer)
                
            }

            if let bPort = backInput.ports(for: .video, sourceDeviceType: backDevice.deviceType, sourceDevicePosition: backDevice.position).first {
                backConnection = AVCaptureConnection(inputPort: bPort, videoPreviewLayer: backLayer)
            }
        } catch {
            print("", error)
        }
        
        session.addOutput(photoOutput)
        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        photoOutput.enabledSemanticSegmentationMatteTypes = photoOutput.availableSemanticSegmentationMatteTypes

        session.startRunning()
    }
    
    
    func printSupportedCombination() {
        let deviceTypes = [AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                           .builtInTelephotoCamera,
                           .builtInUltraWideCamera,
                           .builtInTrueDepthCamera, .builtInDualCamera, .builtInTripleCamera]
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
        print("================================")
        session.supportedMultiCamDeviceSets.forEach { (devices) in
            print(Array(devices).map({ $0.position.rawString + " " + $0.deviceType.rawValue }))
        }
        print("================================")
    }
    
    private func toggleFrontSession(enabled: Bool) {
        if enabled {
            session.addConnection(frontConnection)
        } else {
            session.removeConnection(frontConnection)
        }
    }
    
    private func toggleBackSession(enabled: Bool) {
        if enabled {
            session.addConnection(backConnection)
        } else {
            session.removeConnection(backConnection)
        }
    }
    
    private func setup() {
        self.navigationController?.navigationBar.isHidden = true
        
        captureBtn.layer.cornerRadius = 32
        let tap = UITapGestureRecognizer(target: self, action: #selector(capture))
        captureBtn.addGestureRecognizer(tap)
        
        self.view.layer.addSublayer(frontLayer)
        self.view.layer.addSublayer(backLayer)
        frontLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.height)
        backLayer.frame = CGRect(x: self.view.frame.width/2, y: 0, width: self.view.frame.width/2, height: self.view.frame.height)
    }
    
    @objc private func capture() {
        guard frontBtn.isSelected else {
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.enabledSemanticSegmentationMatteTypes = photoOutput.enabledSemanticSegmentationMatteTypes
        settings.isDepthDataDeliveryEnabled = true
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let viewController = self.storyboard?.instantiateViewController(identifier: "MatteVC")
        guard let vc = viewController as? MatteViewController else { return }
        
        if let hair = photo.semanticSegmentationMatte(for: .hair) {
            vc.hairImage = UIImage(ciImage: CIImage(semanticSegmentationMatte: hair) ?? CIImage())
        }
        if let tooth = photo.semanticSegmentationMatte(for: .teeth) {
            vc.toothImage = UIImage(ciImage: CIImage(semanticSegmentationMatte: tooth) ?? CIImage())
        }
        if let skin = photo.semanticSegmentationMatte(for: .skin) {
            vc.skinImage = UIImage(ciImage: CIImage(semanticSegmentationMatte: skin) ?? CIImage())
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        self.orientation = UIDevice.current.orientation
    }
}






extension AVCaptureDevice.Position {
    var rawString: String {
        switch self {
        case .back:
            return "Back"
        case .front:
            return "Front"
        case .unspecified:
            return "Unspecified"
        }
    }
}
