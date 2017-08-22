//
//  CNLCodeScanner.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 12/11/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

import CNLFoundationTools

public protocol CNLCodeScannerDelegate: class {
    func codeScanner(_ codeScanner: CNLCodeScanner, didScanObject object: AVMetadataObject, screenshot: UIImage?)
    func codeScanner(_ codeScanner: CNLCodeScanner, didTakePhoto image: UIImage?)
    func codeScannerError(_ codeScanner: CNLCodeScanner)
}

public enum CNLCodeScannerMode {
    case scanCode
    case takePhoto
}

open class CNLCodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    open weak var delegate: CNLCodeScannerDelegate?
    
    var captureSession: AVCaptureSession!
    var captureDevice: AVCaptureDevice!
    var captureMetadataOutput: AVCaptureMetadataOutput!
    var captureImageOutput: AVCaptureStillImageOutput!
    var videoPreviewView: UIView!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    open private(set) var isReading = false
    open var userData: Any?
    open var mode: CNLCodeScannerMode = .scanCode
    
    @discardableResult
    open func startReading(_ inView: UIView, isFront: Bool) -> Bool {
        #if swift(>=4.0)
            let devices = AVCaptureDevice.devices(for: AVMediaType.video)
            // most cases: we run in simulator
            guard devices.count != 0 else {
                delegate?.codeScannerError(self)
                return false
            }
        #else
            let possibleDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            // most cases: we run in simulator
            guard let devices = possibleDevices, devices.count != 0 else {
                delegate?.codeScannerError(self)
                return false
            }
        #endif
        
        captureDevice = nil
        for device in devices {
            #if swift(>=4.0)
                if isFront {
                    if device.position == .front {
                        captureDevice = device
                        break
                    }
                } else {
                    if device.position == .back {
                        captureDevice = device
                        break
                    }
                }
            #else
                if let device = device as? AVCaptureDevice {
                    if isFront {
                        if device.position == .front {
                            captureDevice = device
                            break
                        }
                    } else {
                        if device.position == .back {
                            captureDevice = device
                            break
                        }
                    }
                }
            #endif
        }
        
        if captureDevice == nil {
            // most cases: we run in simulator
            delegate?.codeScannerError(self)
            return false
        }
        
        do {
            try captureDevice.lockForConfiguration()
        } catch _ as NSError {
            
        }
        captureDevice.videoZoomFactor = 1.0
        
        // capability check
        if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
            captureDevice.focusMode = .continuousAutoFocus
        } else {
            if captureDevice.isFocusModeSupported(.autoFocus) {
                captureDevice.focusMode = .autoFocus
            } else {
                if captureDevice.isFocusModeSupported(.locked) {
                    captureDevice.focusMode = .locked
                }
            }
        }
        // capability check
        if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
            captureDevice.exposureMode = .continuousAutoExposure
        } else {
            if captureDevice.isExposureModeSupported(.autoExpose) {
                captureDevice.exposureMode = .continuousAutoExposure
            } else {
                if captureDevice.isExposureModeSupported(.locked) {
                    captureDevice.exposureMode = .locked
                }
            }
        }
        
        captureDevice?.unlockForConfiguration()
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            #if swift(>=4.0)
                captureSession.sessionPreset = AVCaptureSession.Preset.high
            #else
                captureSession.sessionPreset = AVCaptureSessionPresetHigh
            #endif
            captureSession.addInput(input)
            
            captureImageOutput = AVCaptureStillImageOutput()
            captureSession?.addOutput(captureImageOutput)
            
            switch mode {
            case .scanCode:
                let dispatchQueue = DispatchQueue(label: "barCodeQueue", attributes: [])
                
                captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue:dispatchQueue)
                #if swift(>=4.0)
                    captureMetadataOutput.metadataObjectTypes = [
                        AVMetadataObject.ObjectType.qr,
                        AVMetadataObject.ObjectType.upce,
                        AVMetadataObject.ObjectType.code39,
                        AVMetadataObject.ObjectType.code39Mod43,
                        AVMetadataObject.ObjectType.ean13,
                        AVMetadataObject.ObjectType.ean8,
                        AVMetadataObject.ObjectType.code93,
                        AVMetadataObject.ObjectType.code128,
                        AVMetadataObject.ObjectType.pdf417,
                        AVMetadataObject.ObjectType.aztec
                    ]
                #else
                    captureMetadataOutput.metadataObjectTypes = [
                        AVMetadataObjectTypeQRCode,
                        AVMetadataObjectTypeUPCECode,
                        AVMetadataObjectTypeCode39Code,
                        AVMetadataObjectTypeCode39Mod43Code,
                        AVMetadataObjectTypeEAN13Code,
                        AVMetadataObjectTypeEAN8Code,
                        AVMetadataObjectTypeCode93Code,
                        AVMetadataObjectTypeCode128Code,
                        AVMetadataObjectTypePDF417Code,
                        AVMetadataObjectTypeAztecCode
                    ]
                #endif
            case .takePhoto: break
            }
            captureImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            #if swift(>=4.0)
                videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            #else
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            #endif
            videoPreviewLayer.frame = inView.layer.bounds
            inView.layer.addSublayer(videoPreviewLayer)
            videoPreviewView = inView
            
            updateOrientation()
            captureSession.startRunning()
            return true
        } catch _ as NSError {
            return false
        }
    }
    
    open func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil
        captureMetadataOutput = nil
        captureImageOutput = nil
        videoPreviewView = nil
        isReading = false
    }
    
    // AVCaptureMetadataOutputObjectsDelegate delegate
    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if !isReading {
            isReading = true
            if metadataObjects != nil && metadataObjects.count > 0 {
                if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                    asyncMain( {
                        let objectFrame = UIView()
                        objectFrame.backgroundColor = UIColor.clear
                        
                        //self.highlightView.frame = self.videoPreviewLayer.transformedMetadataObjectForMetadataObject(metadataObj).bounds
                        //self.highlightView.hidden = false
                        self.captureImage { image in
                            self.delegate?.codeScanner(self, didScanObject: metadataObj, screenshot: image)
                            self.stopReading()
                        }
                    })
                }
            }
        }
        
    }
    
    open func setFocusPoint(_ point: CGPoint) {
        do {
            try captureDevice.lockForConfiguration()
        } catch _ as NSError {
        }
        if captureDevice.isFocusPointOfInterestSupported {
            captureDevice.focusPointOfInterest = point
        }
        if captureDevice.isExposurePointOfInterestSupported {
            captureDevice.exposurePointOfInterest = point
        }
        captureDevice.unlockForConfiguration()
    }
    
    func updateOrientation() {
        guard
            videoPreviewLayer != nil,
            let connection = videoPreviewLayer.connection
        else { return }
        videoPreviewLayer.frame = videoPreviewView.bounds
        switch UIApplication.shared.statusBarOrientation {
        case .portrait: connection.videoOrientation = .portrait
        case .landscapeLeft: connection.videoOrientation = .landscapeLeft
        case .landscapeRight: connection.videoOrientation = .landscapeRight
        case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
        default: break //videoPreviewLayer.connection.videoOrientation = lastOrientation
        }
    }
    
    open func captureImage(_ completion: @escaping (_ image: UIImage?) -> Void) {
        guard let captureImageOutput = captureImageOutput else {
            completion(nil)
            return
        }
        var videoConnection: AVCaptureConnection? = nil
        for connection in captureImageOutput.connections {
            #if swift(>=4.0)
                if (connection.inputPorts.contains { $0.mediaType == AVMediaType.video }) {
                    videoConnection = connection
                    break
                }
                if videoConnection != nil {
                    break
                }
            #else
                if let connection = connection as? AVCaptureConnection {
                    if (connection.inputPorts.contains {
                        if let inputPort = $0 as? AVCaptureInputPort {
                            return inputPort.mediaType == AVMediaTypeVideo
                        }
                        return false
                    }) {
                        videoConnection = connection
                        break
                    }
                    if videoConnection != nil {
                        break
                    }
                }
            #endif
        }
        
        captureImageOutput.captureStillImageAsynchronously(from: videoConnection!) { (imageSampleBuffer: CMSampleBuffer?, _: Error?) -> Void in
            //let exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, nil)
            guard
                let sampleBuffer = imageSampleBuffer,
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer),
                let image = UIImage(data: imageData)
                else {
                    completion(nil)
                    return
                }
            completion(image.adoptToDevice(CGSize(width: image.size.width / 2.0, height: image.size.height / 2.0), scale: 1.0))
        }
    }
    
}
