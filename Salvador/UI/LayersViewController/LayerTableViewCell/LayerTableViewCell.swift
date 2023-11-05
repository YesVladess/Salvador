/*
 *  LayerTableViewCell.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */

import UIKit

protocol LayerTableViewCellDelegate: AnyObject {
    func didPressPlay(model: LayerViewModel)
    func didPressPause(model: LayerViewModel)
    func didPressMute(model: LayerViewModel)
    func didPressUnmute(model: LayerViewModel)
    func didPressDelete(model: LayerViewModel)
}

struct LayerViewModel {
    let name: String
    var isMuted = false
    var isPlaying = false
}

class LayerTableViewCell: UITableViewCell {

    @IBOutlet private weak var layerName: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var muteButton: UIButton!
    @IBOutlet private weak var stackView: UIStackView!
    var model: LayerViewModel?
    weak var delegate: LayerTableViewCellDelegate?

    func updateWith(model: LayerViewModel) {
        self.model = model
        self.layerName.text = model.name
        if model.isMuted {
            let image = UIImage(named: "soundOff")
            muteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "soundOn")
            muteButton.setImage(image, for: .normal)
        }
        if model.isPlaying {
            let image = UIImage(named: "pause")
            playButton.setImage(image, for: .normal)
            self.backgroundColor = .systemGreen
        } else {
            let image = UIImage(named: "play")
            playButton.setImage(image, for: .normal)
            self.backgroundColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func playPressed(_ sender: Any) {
        guard var model = model else { return }
        model.isPlaying.toggle()
        updateWith(model: model)
        if model.isPlaying {
            delegate?.didPressPlay(model: model)
        } else {
            delegate?.didPressPause(model: model)
        }
    }

    @IBAction private func mutePressed(_ sender: Any) {
        guard var model = model else { return }
        model.isMuted.toggle()
        updateWith(model: model)
        if model.isMuted {
            delegate?.didPressMute(model: model)
        } else {
            delegate?.didPressUnmute(model: model)
        }

    }

    @IBAction private func deletePressed(_ sender: Any) {
        guard let model = model else { return }
        delegate?.didPressDelete(model: model)
    }
    
}
