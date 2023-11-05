/*
 *  SamplePlayer.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */

import AVFoundation
import Foundation

struct Layer {
    let sampleName: String
    let displayName: String
    let player: AVAudioPlayer
}

class AudioSampleManager: NSObject {

    static let guitarSample = "useful_guitar_chords_60bpm"
    static let drumsSample = "anthem_drums_71bpm"
    static let synthSample = "urban_rnb_chords"

    typealias LayerId = String
    static let shared = AudioSampleManager()

    var guitarSamplesCount = 0
    var drumsSamplesCount = 0
    var synthSamplesCount = 0
    var recordingSamplesCount = 0

    let audioSession = AVAudioSession.sharedInstance()

    // TODO: Do we need ID? display name should be unic
    private var layers: [LayerId: Layer] = [:]

    var recorder: AVAudioRecorder!
    var recordingURL: String?
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    private override init() {
    }

    // MARK: Playing

    private func prepareForPlaying() {
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }

    // TODO: Refactor
    func getLayers() -> [LayerViewModel] {
        var layers = [LayerViewModel]()
        for (_, layer) in self.layers {
            let layer = LayerViewModel(name: layer.displayName)
            layers.append(layer)
        }
        return layers
    }

    func createAndPlayGuitarSample() -> Layer? {
        guitarSamplesCount += 1
        if let layer = createLayer(withSampleName: Self.guitarSample, layerName: "Guitar_\(guitarSamplesCount)") {
            playLayer(layer)
            return layer
        }
        return nil
    }

    func createAndPlayDrumsSample() -> Layer? {
        drumsSamplesCount += 1
        if let layer = createLayer(withSampleName: Self.drumsSample, layerName: "Drums_\(drumsSamplesCount)") {
            playLayer(layer)
            return layer
        }
        return nil
    }

    func createAndPlaySynthesizerSample() -> Layer? {
        synthSamplesCount += 1
        if let layer = createLayer(withSampleName: Self.synthSample, layerName: "Synth_\(synthSamplesCount)") {
            playLayer(layer)
            return layer
        }
        return nil
    }

    func stopAllLayers() {
        layers.values.forEach { $0.player.stop() }
    }

    func playLayer(_ layer: Layer) {
        prepareForPlaying()
        if layer.player.isPlaying {
            layer.player.stop()
        }
        if layer.player.play() {
            print("played successfully")
        } else {
            print("Play error")
        }
    }

    private func createLayer(withSampleName sampleName: String, layerName: String, ofType type: String? = "wav") -> Layer? {
        guard let path = Bundle.main.path(forResource: sampleName, ofType: type) else {
            return nil
        }
        print("path: \(path)")
        let url = URL(fileURLWithPath: path)
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.enableRate = true
            let layer = Layer(sampleName: sampleName, displayName: layerName, player: player)
            layers[UUID().uuidString] = layer
            return layer
        } catch {
            print("Error:")
            return nil
        }
    }

    func changeSettingsFor(layer: Layer, newRatePersentage: Float, newVolumePersentage: Float) {
        // TODO: 1- чтоб перевернуть ось Y
        let newCalculatedVolume = 1 - newVolumePersentage
        print("newCalculatedVolume \(newCalculatedVolume)")
        layer.player.volume = newCalculatedVolume
        // TODO: улучшить формулу, беру значения от 0.66 до 2, то есть не весь диапозон
        let newCalculatedRate = (2 * (newRatePersentage + 0.5)) / 1.5
        print("newCalculatedRate \(newCalculatedRate)")
        layer.player.rate = newCalculatedRate
    }

    // MARK: Recording

    private func prepareForRecording() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            guard audioSession.recordPermission != .granted else { return }
            audioSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        // self.loadRecordingUI()
                        print("Recording permission given")
                    } else {
                        // self.loadFailUI()
                        print("Failed to get record permission")
                    }
                }
            }
        } catch {
            print(error)
        }
    }

    func startRecording() {
        print("finishRecording")
        prepareForRecording()
        let audioURL = Self.getRecordingURL()
        self.recordingURL = audioURL.relativePath
        print(audioURL.absoluteString)
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder.delegate = self
            recorder.record()
        } catch {
            finishRecording(success: false)
        }
    }

    func stopRecording() {
        finishRecording(success: true)
    }

    private func finishRecording(success: Bool) {
        print("finishRecording with result \(success)")
        recorder.stop()
        recorder = nil
        // TODO: Command UI from here
        if success {
            guard let urlString = recordingURL else {
                print("Error: No recording URL")
                return
            }
            print("Playing recorded sample")
            if let layer = createLayer(withSampleName: urlString, layerName: "Recording \(recordingSamplesCount += 1)", ofType: nil) {
                playLayer(layer)
            }
        } else {
            // TODO:
        }
        self.recordingURL = nil
    }

    class func getDocumentsDirectory() -> URL {
        // TODO: Сохранять не в доки а внутри аппки?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    class func getRecordingURL() -> URL {
        let name = UUID().uuidString + "micSample.m4a"
        return getDocumentsDirectory().appendingPathComponent(name)
    }
}

extension AudioSampleManager: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
              finishRecording(success: false)
          }
    }
}

