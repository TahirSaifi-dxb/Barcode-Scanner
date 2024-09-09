//
//  ScannerVC.swift
//  Barcode-Scanner
//
//  Created by Tahir Saifi on 09/09/2024.
//

import AVFoundation
import UIKit

enum CameraError: String {
    case invalidDeviceInput = "Invalid device input"
    case invalidScannedValue =  "Invalid scanned value"
}

protocol ScannerVCDelagate: AnyObject {
    func didFind(barcode: String)
    func didSurfaceError(error: CameraError)
}

final class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelagate?
    
    init(scannerDelegate: ScannerVCDelagate){
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {
            scannerDelegate?.didSurfaceError(error: .invalidDeviceInput)
            return
        }
        
        previewLayer.frame = view.layer.bounds
        
    }
    
    private func setupCaptureSession(){
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.didSurfaceError(error: .invalidDeviceInput)
            return }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.didSurfaceError(error: .invalidDeviceInput)
            return
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        }else{
            scannerDelegate?.didSurfaceError(error: .invalidDeviceInput)
            return
        }
        
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput){
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
            
        }else{
            scannerDelegate?.didSurfaceError(error: .invalidScannedValue)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {
            scannerDelegate?.didSurfaceError(error: .invalidScannedValue)
            return }
        guard let machineReadableCode = object as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.didSurfaceError(error: .invalidScannedValue)
            return }
        guard let barcode = machineReadableCode.stringValue else {
            scannerDelegate?.didSurfaceError(error: .invalidScannedValue)
            return }
        scannerDelegate?.didFind(barcode: barcode)
    }
}


