//
//  CollectionViewCell.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 14.09.2021.
//

import UIKit
import Combine
import AVKit

// MARK: - CollectionVideoCell
class CollectionVideoCell: UICollectionViewCell, CellIdentifiable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var deleteVideoButton: UIButton!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var thumbnailsImageView: UIImageView!
    
    // MARK: - Properties
    var player: AVQueuePlayer?

    var deleteVideoPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?
    private var isPlay: Bool = false
    
    private var url: URL?
    private var isActivePlayer = false
    private var post: LocalPost?
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        unload()
        isActivePlayer = false
        thumbnailsImageView.image = nil
        url = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReadyToPlay(notification:)), name: .AVPlayerItemNewAccessLogEntry, object: player?.currentItem)
    }
    
    // MARK: - Methods
    @discardableResult
    func config(with videoURL: URL?, isHideButton: Bool, playPublisher: PassthroughSubject<Void, Never>?, post: LocalPost?) -> CollectionVideoCell {
        guard let videoURL = videoURL else { return self }
        self.url = videoURL
        self.post = post
        let url = URL(string: post?.videoPlaceholder ?? "")
        thumbnailsImageView.showActivityIndicator()
        thumbnailsImageView.kf.setImage(with: url) { [weak self] _ in
            self?.removeActivityIndicator()
        }
        thumbnailsImageView.layer.zPosition = 1
        
        if let playPublisher = playPublisher {
            playPublisher.sink(receiveValue: { [weak self] in
                self?.pause()
            }).store(in: &cancellables)
        }
        
        deleteVideoButton.isHidden = isHideButton ? true : false
        deleteVideoButton.layer.zPosition = isHideButton ? -1 : 1
        videoURLDidChange(videoURL: videoURL, isHideButton: isHideButton)
        
        return self
    }
    
    func pause() {
        player?.pause()
        isPlay = false
        UIView.animate(withDuration: 0.3, delay: 0, animations: { [weak self] in
            self?.playPauseImageView.alpha = 1
            self?.playPauseImageView.image = UIImage(named: "ico_community_play")
        }, completion: { _ in })
    }
    
    // MARK: - Action
    @IBAction func deleteVideo(_ sender: UIButton) {
        stop()
        deleteVideoPublisher.send()
    }
}

private extension CollectionVideoCell {
    
    func setupUI() {
        layer.cornerRadius = 12
    }
    
    func unload() {
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        playerLooper = nil
    }
    
    func addGesture() {
        let avatarGesture = UITapGestureRecognizer(target: self, action: #selector(tapPlayPause))
        contentView.addGestureRecognizer(avatarGesture)
    }
        
    @objc
    func tapPlayPause(_ sender: UITapGestureRecognizer) {
        isPlay ? pause() : play()
    }
    
    func play() {
        if !isActivePlayer {
            createPlayer(videoURL: url)
        }
        player?.play()
        isActivePlayer = true
        thumbnailsImageView.layer.zPosition = -1
        isPlay = true
        UIView.animate(withDuration: 0.3, delay: 1, animations: { [weak self] in
            self?.playPauseImageView.alpha = 0
            self?.playPauseImageView.image = UIImage(named: "ico_community_pause")
        }, completion: { _ in })
    }
    
    func stop() {
        self.player?.pause()
        self.player?.seek(to: .init(seconds: 0, preferredTimescale: 1))
    }
    
    func videoURLDidChange(videoURL: URL, isHideButton: Bool) {

        playPauseImageView.bringSubviewToFront(self)
        playPauseImageView.layer.zPosition = 1
    }
    
    func createPlayer(videoURL: URL?) {
        guard let videoURL = videoURL else { return }
        let playerItem = AVPlayerItem(url: videoURL)
        
        player = AVQueuePlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        
        guard let playerLayer = playerLayer, let player = player else { return }
        
        self.player?.seek(to: .init(seconds: 0, preferredTimescale: 1))

        playerLooper = .init(player: player, templateItem: playerItem)
        playerLayer.videoGravity = .resizeAspectFill
        setNeedsLayout()
        layoutIfNeeded()
        playerLayer.frame = contentView.bounds
        
        contentView.layer.addSublayer(playerLayer)
        deleteVideoButton.bringSubviewToFront(self)
        deleteVideoButton.layer.zPosition = 1
        player.play()
    }
    
    @objc
    func playerItemDidReadyToPlay(notification: Notification) {
        if (notification.object as? AVPlayerItem) != nil {
            
        }
    }
    
}
