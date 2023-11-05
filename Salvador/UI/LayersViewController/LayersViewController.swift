/*
 *  LayersViewController.swift
 *  Salvador
 *
 *  Created by Vlad Kononenko on 04.11.2023
 *  All rights reserved.
 *
 */

import UIKit

// TODO: в отдельный файл
struct LayerViewModel {
    let name: String
}

class LayersViewController: UIViewController {

    let audioSampleManager = AudioSampleManager.shared
    var layers: [LayerViewModel] = []
    var bottomOffset: CGFloat = 0

    @IBOutlet private weak var layersTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        layers = audioSampleManager.getLayers()
        layersTableView.delegate = self
        layersTableView.dataSource = self
        let cell = UINib(nibName: "LayerTableViewCell", bundle: Bundle.main)
        layersTableView.register(cell, forCellReuseIdentifier: "layer")
        layersTableView.estimatedRowHeight = 44
        layersTableView.rowHeight = UITableView.automaticDimension
    }

    override func updateViewConstraints() {

        // calculate height of everything inside that stackview
        let height: CGFloat = layersTableView.contentSize.height

        // change size of Viewcontroller's view to that height
        self.view.frame.size.height = height
        // reposition the view (if not it will be near the top)
        self.view.frame.origin.y = UIScreen.main.bounds.height - height - bottomOffset
        // apply corner radius only to top corners
        //self.view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        super.updateViewConstraints()
    }

}

extension LayersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            return layerCell
        }
        return cell
    }
}

// TODO: to ext
// https://stackoverflow.com/a/41197790/225503
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
