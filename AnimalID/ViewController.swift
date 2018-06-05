//
//  ViewController.swift
//  ml
//
//  Created by Samay Shamdasani on 5/30/18.
//  Copyright © 2018 Samay Shamdasani. All rights reserved.
//

import UIKit
import AVKit
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let background = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        setupIdentifierConfidenceLabel()
        
        
    }
    
    fileprivate func setupIdentifierConfidenceLabel() {
        background.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -15).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 15).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -15).isActive = true
        identifierLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: 15).isActive = true
        view.addSubview(background)
        background.contentMode = .scaleToFill
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        background.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        background.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        background.layer.cornerRadius = 5
        background.isHidden = true
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Frame captured:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else { return }
        let request = VNCoreMLRequest(model: model) {
            (observations, err) in
            
            guard let results = observations.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)

            DispatchQueue.main.async {
                self.background.isHidden = false
                self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)%"
            }
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

