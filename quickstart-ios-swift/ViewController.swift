//
//  ViewController.swift
//  quickstart-ios-swift
//
//  Created by Lara Vertlberg on 09/12/2019.
//  Copyright © 2019 Lara Vertlberg. All rights reserved.
//

import UIKit
import DeepAR
import AVKit
import AVFoundation

enum RecordingMode : String {
    case photo
    case video
    case lowQualityVideo
}


enum Effects: String, CaseIterable {
    case viking_helmet = "viking_helmet.deepar"
    case MakeupLook = "MakeupLook.deepar"
    case Split_View_Look = "Split_View_Look.deepar"
    case Emotions_Exaggerator = "Emotions_Exaggerator.deepar"
    case Emotion_Meter = "Emotion_Meter.deepar"
    case Stallone = "Stallone.deepar"
    case flower_face = "flower_face.deepar"
    case galaxy_background = "galaxy_background.deepar"
    case Humanoid = "Humanoid.deepar"
    case Neon_Devil_Horns = "Neon_Devil_Horns.deepar"
    case Ping_Pong = "Ping_Pong.deepar"
    case Pixel_Hearts = "Pixel_Hearts.deepar"
    case Snail = "Snail.deepar"
    case Hope = "Hope.deepar"
    case Vendetta_Mask = "Vendetta_Mask.deepar"
    case Fire_Effect = "Fire_Effect.deepar"
    case burning_effect = "burning_effect.deepar"
    case Elephant_Trunk = "Elephant_Trunk.deepar"
}

class ViewController: UIViewController {
    
    // MARK: - IBOutlets -

    @IBOutlet weak var switchCameraButton: UIButton!
    
    @IBOutlet weak var masksButton: UIButton!
    @IBOutlet weak var effectsButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var recordActionButton: UIButton!
    
    @IBOutlet weak var lowQVideoButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var arViewContainer: UIView!
    
    private var deepAR: DeepAR!
    private var arView: ARView!
    
    // This class handles camera interaction. Start/stop feed, check permissions etc. You can use it or you
    // can provide your own implementation
    private var cameraController: CameraController!
    
    // MARK: - Private properties -

    private var effectIndex: Int = 0
    private var effectPaths: [String?] {
        return Effects.allCases.map { $0.rawValue.path }
    }
    
    private var buttonRecordingModePairs: [(UIButton, RecordingMode)] = []
    private var currentRecordingMode: RecordingMode! {
        didSet {
            updateRecordingModeAppearance()
        }
    }
    
    private var isRecordingInProcess: Bool = false
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDeepARAndCamera()
        addTargets()
        buttonRecordingModePairs = [ (photoButton, RecordingMode.photo), (videoButton, RecordingMode.video), (lowQVideoButton, RecordingMode.lowQualityVideo)]
        currentRecordingMode = .photo    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        arView.frame = self.view.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // sometimes UIDeviceOrientationDidChangeNotification will be delayed, so we call orientationChanged in 0.5 seconds anyway
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.orientationDidChange()
        }
    }
    
    // MARK: - Private methods -
    
    private func setupDeepARAndCamera() {
        
        self.deepAR = DeepAR()
        self.deepAR.delegate = self
        self.deepAR.setLicenseKey("your_licence_key_here")
        
        cameraController = CameraController()
        cameraController.deepAR = self.deepAR
        self.deepAR.videoRecordingWarmupEnabled = false;
        
        self.arView = (self.deepAR.createARView(withFrame: self.arViewContainer.frame) as! ARView)
        self.arView.translatesAutoresizingMaskIntoConstraints = false
        self.arViewContainer.addSubview(self.arView)
        self.arView.leftAnchor.constraint(equalTo: self.arViewContainer.leftAnchor, constant: 0).isActive = true
        self.arView.rightAnchor.constraint(equalTo: self.arViewContainer.rightAnchor, constant: 0).isActive = true
        self.arView.topAnchor.constraint(equalTo: self.arViewContainer.topAnchor, constant: 0).isActive = true
        self.arView.bottomAnchor.constraint(equalTo: self.arViewContainer.bottomAnchor, constant: 0).isActive = true
    
        cameraController.startCamera()
    }
    
    private func addTargets() {
        switchCameraButton.addTarget(self, action: #selector(didTapSwitchCameraButton), for: .touchUpInside)
        recordActionButton.addTarget(self, action: #selector(didTapRecordActionButton), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    
        photoButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(didTapVideoButton), for: .touchUpInside)
        lowQVideoButton.addTarget(self, action: #selector(didTapLowQVideoButton), for: .touchUpInside)
    }
    
    private func updateRecordingModeAppearance() {
        buttonRecordingModePairs.forEach { (button, recordingMode) in
            button.isSelected = recordingMode == currentRecordingMode
        }
    }
    
    @objc
    private func orientationDidChange() {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else { return }
        switch orientation {
        case .landscapeLeft:
            cameraController.videoOrientation = .landscapeLeft
            break
        case .landscapeRight:
            cameraController.videoOrientation = .landscapeRight
            break
        case .portrait:
            cameraController.videoOrientation = .portrait
            break
        case .portraitUpsideDown:
            cameraController.videoOrientation = .portraitUpsideDown
        default:
            break
        }
        
    }
    
    @objc
    private func didTapSwitchCameraButton() {
        cameraController.position = cameraController.position == .back ? .front : .back
    }
    
    @objc
    private func didTapRecordActionButton() {
        
        if (currentRecordingMode == RecordingMode.photo) {
            deepAR.takeScreenshot()
            return
        }
        
        if (isRecordingInProcess) {
            deepAR.finishVideoRecording()
            isRecordingInProcess = false
            return
        }
        
        let width: Int32 = Int32(deepAR.renderingResolution.width)
        let height: Int32 =  Int32(deepAR.renderingResolution.height)
        
        if (currentRecordingMode == RecordingMode.video) {
            if(deepAR.videoRecordingWarmupEnabled) {
                deepAR.resumeVideoRecording()
            } else {
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
            isRecordingInProcess = true
            return
        }
        
        if (currentRecordingMode == RecordingMode.lowQualityVideo) {
            if(deepAR.videoRecordingWarmupEnabled) {
                NSLog("Can't change video recording settings when video recording warmap enabled")
                return
            }
            let videoQuality = 0.1
            let bitrate =  1250000
            let videoSettings:[AnyHashable : AnyObject] = [
                AVVideoQualityKey : (videoQuality as AnyObject),
                AVVideoAverageBitRateKey : (bitrate as AnyObject)
            ]
            
            let frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            
            deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height, subframe: frame, videoCompressionProperties: videoSettings, recordAudio: true)
            isRecordingInProcess = true
        }
        
    }
    
    @objc
    private func didTapPreviousButton() {
        var path: String?
        effectIndex = (effectIndex - 1 < 0) ? (effectPaths.count - 1) : (effectIndex - 1)
        path = effectPaths[effectIndex]
        deepAR.switchEffect(withSlot: "effect", path: path)
    }
    
    @objc
    private func didTapNextButton() {
        var path: String?
        effectIndex = (effectIndex + 1 > effectPaths.count - 1) ? 0 : (effectIndex + 1)
        path = effectPaths[effectIndex]
        deepAR.switchEffect(withSlot: "effect", path: path)
    }

    @objc
    private func didTapPhotoButton() {
        currentRecordingMode = .photo
    }
    
    @objc
    private func didTapVideoButton() {
        currentRecordingMode = .video
    }
    
    @objc
    private func didTapLowQVideoButton() {
        currentRecordingMode = .lowQualityVideo
    }
}

// MARK: - ARViewDelegate -

extension ViewController: DeepARDelegate {
    func didFinishPreparingForVideoRecording() {
        NSLog("didFinishPreparingForVideoRecording!!!!!")
    }
    
    func didStartVideoRecording() {
        NSLog("didStartVideoRecording!!!!!")
    }
    
    func didFinishVideoRecording(_ videoFilePath: String!) {
        
        NSLog("didFinishVideoRecording!!!!!")

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let components = videoFilePath.components(separatedBy: "/")
        guard let last = components.last else { return }
        let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsDirectory, last))
    
        let playerController = AVPlayerViewController()
        let player = AVPlayer(url: destination)
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func recordingFailedWithError(_ error: Error!) {}
    
    func didTakeScreenshot(_ screenshot: UIImage!) {
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        
        let imageView = UIImageView(image: screenshot)
        imageView.frame = view.frame
        view.insertSubview(imageView, aboveSubview: arView)
        
        let flashView = UIView(frame: view.frame)
        flashView.alpha = 0
        flashView.backgroundColor = .black
        view.insertSubview(flashView, aboveSubview: imageView)
        
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1
        }) { _ in
            flashView.removeFromSuperview()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                imageView.removeFromSuperview()
            }
        }
    }
    
    func didInitialize() {
        if (deepAR.videoRecordingWarmupEnabled) {
            DispatchQueue.main.async { [self] in
                let width: Int32 = Int32(deepAR.renderingResolution.width)
                let height: Int32 =  Int32(deepAR.renderingResolution.height)
                deepAR.startVideoRecording(withOutputWidth: width, outputHeight: height)
            }
        }
    }
    
    func didFinishShutdown (){
        NSLog("didFinishShutdown!!!!!")
    }
    
    func faceVisiblityDidChange(_ faceVisible: Bool) {}
}

extension String {
    var path: String? {
        return Bundle.main.path(forResource: self, ofType: nil)
    }
}
