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

class SamplePlayer: NSObject {

    static let shared = SamplePlayer()

    let audioSession = AVAudioSession.sharedInstance()

    private var players: [String: AVAudioPlayer] = [:]

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

    func playGuitarSample() {
        prepareForPlaying()
        playSample(named: "useful_guitar_chords_60bpm")
    }

    func playDrumsSample() {
        prepareForPlaying()
        playSample(named: "anthem_drums_71bpm")
    }

    func playSynthesizerSample() {
        prepareForPlaying()
        playSample(named: "urban_rnb_chords")
    }

    private func playSample(named sampleName: String, ofType type: String? = "wav") {
        // TODO: временный кейс для проигрывания с микры
        var path: String
        if type == nil {
            path = sampleName
        } else {
            path = Bundle.main.path(forResource: sampleName,
                                        ofType: type)!
        }

        // print("path: \(path)")
        let url = URL(fileURLWithPath: path)

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            players[sampleName] = player
            // TODO: временный кейс для проигрывания с микры
            if type == nil {
                player.numberOfLoops = 50
            }
            player.play()
            // print("Sound was played")
        } catch {
            print("Error: coudn't load file!")
        }
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
        let audioURL = Self.getWhistleURL()
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
            playSample(named: urlString, ofType: nil)
        } else {

        }
        self.recordingURL = nil
        prepareForPlaying()
    }

    class func getDocumentsDirectory() -> URL {
        // TODO: Сохранять не в доки а внутри аппки?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    class func getWhistleURL() -> URL {
        let name = UUID().uuidString + "micSample.m4a"
        return getDocumentsDirectory().appendingPathComponent(name)
    }
}

extension SamplePlayer: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
              finishRecording(success: false)
          }
    }
}

