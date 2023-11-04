//
//  Copyright (c) 2011-2022, Zingaya, Inc. All rights reserved.
//


import UIKit

class ViewController: UIViewController {

    var isRecording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var setupSampleView: UIView!
    
    @IBAction func tapGuitarButton(_ sender: Any) {
        SamplePlayer.shared.playGuitarSample()
    }

    @IBAction func tapDrumsButton(_ sender: Any) {
        SamplePlayer.shared.playDrumsSample()
    }

    @IBAction func tapSynthButton(_ sender: Any) {
        SamplePlayer.shared.playSynthesizerSample()
    }

    @IBAction func tapStartRecording(_ sender: Any) {
        if isRecording {
            SamplePlayer.shared.stopRecording()
        } else {
            SamplePlayer.shared.startRecording()
        }
        isRecording.toggle()
    }
}

