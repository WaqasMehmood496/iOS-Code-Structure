//
//  VideoView.swift
//  Evexia
//
//  Created by admin on 06.10.2021.
//

import UIKit
import AVFoundation

class VideoView: UIView {
    
    private weak var playerLayer: AVPlayerLayer!
    
    weak var player: AVPlayer!
    
    func createVideoLayer(with player: AVPlayer) {
        if playerLayer != nil {
            DispatchQueue.main.async {
                self.playerLayer.removeFromSuperlayer()
            }
        }
        self.player = nil
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.contentsGravity = .resizeAspectFill
        layer.frame = self.bounds
        self.layer.addSublayer(layer)
        self.playerLayer = layer
    }
    
    override func draw(_ rect: CGRect) {
        self.playerLayer?.frame = self.bounds
        self.playerLayer?.cornerRadius = 8.0
    }
}
