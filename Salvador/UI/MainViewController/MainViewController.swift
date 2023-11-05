/*
 *  ViewController.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */

import UIKit

class MainViewController: UIViewController {

    let audioSampleManager = AudioSampleManager.shared

    var currentLayer: Layer? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.layersButton.setTitle(self?.currentLayer?.displayName, for: .normal)
            }
        }
    }
    var isRecording: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSampleView.delegate = self
        layersButton.titleLabel?.text = "Layers"
    }

    @IBOutlet private weak var bottomButtons: UIStackView!
    @IBOutlet private weak var layersButton: UIButton!
    @IBOutlet private weak var setupSampleView: SetupSampleView!
    @IBOutlet private weak var sampleVisualizationView: UIView!

    @IBAction private func tapGuitarButton(_ sender: Any) {
        audioSampleManager.stopAllLayers()
        currentLayer = audioSampleManager.createAndPlayGuitarSample()
    }

    @IBAction private func tapDrumsButton(_ sender: Any) {
        audioSampleManager.stopAllLayers()
        currentLayer = audioSampleManager.createAndPlayDrumsSample()
    }

    @IBAction private func tapSynthButton(_ sender: Any) {
        audioSampleManager.stopAllLayers()
        currentLayer = audioSampleManager.createAndPlaySynthesizerSample()
    }

    @IBAction private func tapLayersButton(_ sender: Any) {
        let myViewController = LayersViewController.loadFromNib()
        addChild(myViewController)
        let rect = CGRect(
            origin: sampleVisualizationView.frame.origin,
            size: CGSize(width: view.frame.width, height: 0)
        )
        myViewController.bottomOffset = bottomButtons.frame.height + 50
        myViewController.view.frame = rect
        view.addSubview(myViewController.view)
        myViewController.didMove(toParent: self)
    }
    
    @IBAction private func tapStartRecording(_ sender: Any) {
        if isRecording {
            audioSampleManager.stopRecording()
        } else {
            audioSampleManager.startRecording()
        }
        isRecording.toggle()
    }
}

extension MainViewController: SetupSampleViewDelegate {
    func userDidTapViewAt(location: CGPoint) {
        let ratePersentage = Float(location.x) / Float(setupSampleView.frame.width)
        let volumePersentage = Float(location.y) / Float(setupSampleView.frame.height)
        guard let layer = currentLayer else { return }
        audioSampleManager.changeSettingsFor(layer: layer,
                                             newRatePersentage: ratePersentage,
                                             newVolumePersentage: volumePersentage)
        audioSampleManager.playLayer(layer)
    }
}

// TODO: убрать в ext
extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        return instantiateFromNib()
    }
}

