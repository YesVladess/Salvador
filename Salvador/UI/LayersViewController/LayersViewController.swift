/*
 *  LayersViewController.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */

import UIKit

class LayersViewController: UIViewController {

    let audioSampleManager = AudioSampleManager.shared
    var layers: [LayerViewModel] = []
    var bottomOffset: CGFloat = 0

    @IBOutlet weak var layersTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        layers = audioSampleManager.getLayersModels()
        layersTableView.delegate = self
        layersTableView.dataSource = self
        let cell = UINib(nibName: "LayerTableViewCell", bundle: Bundle.main)
        layersTableView.register(cell, forCellReuseIdentifier: "layer")
        layersTableView.estimatedRowHeight = 60
        layersTableView.rowHeight = UITableView.automaticDimension
        layersTableView.layoutMargins = .zero
        layersTableView.separatorInset = .zero
    }

    override func updateViewConstraints() {

        let height: CGFloat = CGFloat(layersTableView.numberOfRows(inSection: 0)) * (layersTableView.estimatedRowHeight + 20)
        self.view.frame.size.height = height
        // reposition the view (if not it will be near the top)
        self.view.frame.origin.y = UIScreen.main.bounds.height - height - bottomOffset
        super.updateViewConstraints()
    }

}

extension LayersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parent = parent as? MainViewController {
            let layerViewModel = layers[indexPath.row]
            parent.currentLayerName = layerViewModel.name
            parent.layersVC = nil
            audioSampleManager.stopAllLayersPlaying()
            audioSampleManager.playLayer(layerViewModel.name)
        }
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension LayersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "layer", for: indexPath)
        if let layerCell = cell as? LayerTableViewCell {
            let model = layers[indexPath.row]
            layerCell.updateWith(model: model)
            layerCell.delegate = self
            layerCell.layoutMargins = .zero
            return layerCell
        }
        return cell
    }
}

extension LayersViewController: LayerTableViewCellDelegate {
    
    func didPressPlay(model: LayerViewModel) {
        audioSampleManager.playLayer(model.name, looped: true)
    }
    
    func didPressMute(model: LayerViewModel) {
        audioSampleManager.stopLayer(model.name)
    }

    func didPressPause(model: LayerViewModel) {
        audioSampleManager.pauseLayer(model.name)
    }

    func didPressUnmute(model: LayerViewModel) {
        audioSampleManager.playLayer(model.name, looped: true)
    }

    func didPressDelete(model: LayerViewModel) {
        audioSampleManager.deleteLayer(model.name)
        layers.removeAll(where: { $0.name == model.name })
        layersTableView.reloadData()
        updateViewConstraints()
    }
}
