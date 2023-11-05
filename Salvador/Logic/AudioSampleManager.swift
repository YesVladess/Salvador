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

class AudioSampleManager: NSObject {

    struct Layer {
        let sampleName: String
        // Unique by design
        let displayName: String
        let player: AVAudioPlayer
    }

    static let guitarSample = "useful_guitar_chords_60bpm"
    static let drumsSample = "anthem_drums_71bpm"
    static let synthSample = "urban_rnb_chords"

    typealias LayerDisplayName = String
    static let shared = AudioSampleManager()

    var guitarSamplesCount = 0
    var drumsSamplesCount = 0
    var synthSamplesCount = 0
    var recordingSamplesCount = 0

    let audioSession = AVAudioSession.sharedInstance()

    // TODO: Do we need ID? display name should be unic
    private var layers: [LayerDisplayName: Layer] = [:]

    var recorder: AVAudioRecorder!
    var recordingURL: URL?
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    let audioEngine = AVAudioEngine()
    let mixer = AVAudioMixerNode()
    var audioPlayer: AVAudioPlayerNode?

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

    func getLayersModels() -> [LayerViewModel] {
        self.layers.values.map { LayerViewModel(name: $0.displayName )}
    }

    func createAndPlayGuitarSample() -> String? {
        guitarSamplesCount += 1
        if let layerName = createLayer(withSampleName: Self.guitarSample, layerDisplayName: "Guitar_\(guitarSamplesCount)") {
            playLayer(layerName)
            return layerName
        }
        return nil
    }

    func createAndPlayDrumsSample() -> String? {
        drumsSamplesCount += 1
        if let layerName = createLayer(withSampleName: Self.drumsSample, layerDisplayName: "Drums_\(drumsSamplesCount)") {
            playLayer(layerName)
            return layerName
        }
        return nil
    }

    func createAndPlaySynthesizerSample() -> String? {
        synthSamplesCount += 1
        if let layerName = createLayer(withSampleName: Self.synthSample, layerDisplayName: "Synth_\(synthSamplesCount)") {
            playLayer(layerName)
            return layerName
        }
        return nil
    }

    func stopAllLayersPlaying() {
        layers.values.forEach { $0.player.stop() }
    }

    func playLayer(_ layerName: String, looped: Bool = false) {
        guard let layer = layers[layerName] else { return }
        prepareForPlaying()
        if layer.player.isPlaying {
            layer.player.stop()
        }
        if looped {
            layer.player.numberOfLoops = 50
        }
        if layer.player.play() {
            print("played successfully")
        } else {
            print("Play error")
        }
    }

    func stopLayer(_ layerName: String) {
        guard let layer = layers[layerName] else { return }
        layer.player.stop()
    }

    func pauseLayer(_ layerName: String) {
        guard let layer = layers[layerName] else { return }
        layer.player.pause()
    }

    func deleteLayer(_ layerName: String) {
        layers.removeValue(forKey: layerName)
    }

    private func createLayer(withSampleName sampleName: String, layerDisplayName: String, ofType type: String? = "wav") -> String? {
        guard let path = Bundle.main.path(forResource: sampleName, ofType: type) else {
            return nil
        }
        print("path: \(path)")
        let url = URL(fileURLWithPath: path)
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.enableRate = true
            let layer = Layer(sampleName: sampleName, displayName: layerDisplayName, player: player)
            layers[layerDisplayName] = layer
            return layer.displayName
        } catch {
            print("Error:")
            return nil
        }
    }

    private func createRecordingLayer(withRecordingURL url: URL, layerDisplayName: String) -> String? {
        print("url: \(url.absoluteString)")
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.enableRate = true
            let layer = Layer(sampleName: url.absoluteString, displayName: layerDisplayName, player: player)
            layers[layerDisplayName] = layer
            return layer.displayName
        } catch {
            print("Error:")
            return nil
        }
    }

    func changeSettingsFor(layerName: String, newRatePersentage: Float, newVolumePersentage: Float) {
        guard let layer = layers[layerName] else { return }
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
        self.recordingURL = audioURL
        print(audioURL.absoluteString)
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder.delegate = self
            recorder.record()
        } catch {
            let _ = finishRecording(success: false)
        }
    }

    func stopRecording() -> String? {
        return finishRecording(success: true)
    }

    private func finishRecording(success: Bool) -> String? {
        print("finishRecording with result \(success)")
        recorder.stop()
        recorder = nil
        // TODO: Command UI from here
        if success {
            guard let url = recordingURL else {
                print("Error: No recording URL")
                return nil
            }
            print("Playing recorded sample")
            recordingSamplesCount += 1
            if let layerName = createRecordingLayer(withRecordingURL: url, layerDisplayName: "Recording_\(recordingSamplesCount)") {
                playLayer(layerName)
                self.recordingURL = nil
                return layerName
            }
        } else {
            // TODO:
        }
        return nil
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

    // MARK: Mixing

    func startMixing() {
        print("startMixing")
        // do work in a background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.audioEngine.attach(self.mixer)
            self.audioEngine.connect(self.mixer, to: self.audioEngine.outputNode, format: nil)
            // !important - start the engine *before* setting up the player nodes
            try! self.audioEngine.start()

            // let fileManager = FileManager.default
            for layer in self.layers.values {
                // Create and attach the audioPlayer node for this file
                let audioPlayer = AVAudioPlayerNode()
                self.audioEngine.attach(audioPlayer)
                // Notice the output is the mixer in this case
                self.audioEngine.connect(audioPlayer, to: self.mixer, format: nil)


                let fileUrl = layer.player.url
                var file : AVAudioFile

                guard let url = fileUrl?.absoluteURL else { return }
                file = try! AVAudioFile(forReading: url)
                audioPlayer.scheduleFile(file, at: nil, completionHandler: nil)
            }
        }
    }

    func stopMixing() {
        print("stopMixing")
        stopAllLayersPlaying()
        let url = Self.getRecordingURL()
        do {
            let recordedOutputFile = try AVAudioFile(forWriting: url, settings: mixer.outputFormat(forBus: 0).settings)
            // Play it after recording
            let audioPlayer = AVAudioPlayerNode()
            audioPlayer.scheduleFile(recordedOutputFile, at: nil) {
                audioPlayer.play()
            }
        }
        catch {
            print("error")
        }
    }
}

extension AudioSampleManager: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            let _ = finishRecording(success: false)
        }
    }
}

