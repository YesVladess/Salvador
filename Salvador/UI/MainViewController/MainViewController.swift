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
    var layersVC: LayersViewController?
    var currentLayerName: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.layersButton.setTitle(self?.currentLayerName ?? "Layers", for: .normal)
            }
        }
    }
    var isRecording: Bool = false
    var isMixing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSampleView.delegate = self
        layersButton.titleLabel?.text = "Layers"
        layersButton.tintColor = .black
        layersButton.layer.cornerRadius = 10.0
        micButton.layer.cornerRadius = 10.0
        recordButton.layer.cornerRadius = 10.0
        playButton.layer.cornerRadius = 10.0
    }

    @IBOutlet private weak var bottomButtons: UIStackView!
    @IBOutlet private weak var layersButton: UIButton!
    @IBOutlet private weak var setupSampleView: SetupSampleView!
    @IBOutlet private weak var sampleVisualizationView: UIView!
    @IBOutlet private weak var micButton: UIButton!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBAction private func tapGuitarButton(_ sender: Any) {
        audioSampleManager.stopAllLayersPlaying()
        currentLayerName = audioSampleManager.createAndPlayGuitarSample()
        if let layersVC = layersVC {
            layersVC.layersTableView.reloadData()
        }
    }

    @IBAction private func tapDrumsButton(_ sender: Any) {
        audioSampleManager.stopAllLayersPlaying()
        currentLayerName = audioSampleManager.createAndPlayDrumsSample()
        if let layersVC = layersVC {
            layersVC.layersTableView.reloadData()
        }
    }

    @IBAction private func tapSynthButton(_ sender: Any) {
        audioSampleManager.stopAllLayersPlaying()
        currentLayerName = audioSampleManager.createAndPlaySynthesizerSample()
        if let layersVC = layersVC {
            layersVC.layersTableView.reloadData()
        }
    }

    @IBAction private func tapLayersButton(_ sender: Any) {
        audioSampleManager.stopAllLayersPlaying()
        guard audioSampleManager.getLayersModels().count != 0 else { return }
        if let vc = layersVC {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            layersVC = nil
        } else {
            let layersVC = LayersViewController.loadFromNib()
            addChild(layersVC)
            let rect = CGRect(
                origin: sampleVisualizationView.frame.origin,
                size: CGSize(width: view.frame.width, height: 0)
            )
            layersVC.bottomOffset = bottomButtons.frame.height + 50
            layersVC.view.frame = rect
            view.addSubview(layersVC.view)
            layersVC.didMove(toParent: self)
            self.layersVC = layersVC
        }
    }
    
    @IBAction private func tapStartRecording(_ sender: Any) {
        audioSampleManager.stopAllLayersPlaying()
        if isRecording {
            currentLayerName = audioSampleManager.stopRecording()
        } else {
            audioSampleManager.startRecording()
        }
        isRecording.toggle()
    }

    @IBAction private func tapCreateMix(_ sender: Any) {
        if isMixing {
            audioSampleManager.stopMixing()
        } else {
            audioSampleManager.startMixing()
        }
        isMixing.toggle()
    }

    @IBAction private func tapPlayMix(_ sender: Any) {

    }
}

extension MainViewController: SetupSampleViewDelegate {
    func userDidTapViewAt(location: CGPoint) {
        let ratePersentage = Float(location.x) / Float(setupSampleView.frame.width)
        let volumePersentage = Float(location.y) / Float(setupSampleView.frame.height)
        guard let currentLayerName = currentLayerName else { return }
        audioSampleManager.changeSettingsFor(layerName: currentLayerName,
                                             newRatePersentage: ratePersentage,
                                             newVolumePersentage: volumePersentage)
        audioSampleManager.playLayer(currentLayerName)
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

