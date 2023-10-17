//
//  FocusCardView.swift
//  Evexia
//
//  Created by  Artem Klimov on 16.07.2021.
//

import UIKit
import Combine

class FocusCardView: UIView {
    
    var isSelected = PassthroughSubject<(FocusCardView, UIPanGestureRecognizer.State, CGPoint), Never>()
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var focusImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var currentCenter: CGPoint = .zero
    var originCenter: CGPoint
    var focus: Focus?
    
    @objc
    func detectPan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self.superview)
        self.center = location
        switch recognizer.state {
        case .began:
            DispatchQueue.main.async {
                self.superview?.bringSubviewToFront(self)
            }
            self.isSelected.send((self, .began, location: location))
        case .changed:
            self.isSelected.send((self, .changed, location: location))
        case .ended:
            self.isSelected.send((self, .ended, location: location))
        default:
            break
        }
    }
    
    override init(frame: CGRect) {
        self.originCenter = CGPoint(x: frame.midX, y: frame.midY)
        super.init(frame: frame)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
        self.nibSetup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.originCenter = .zero
        super.init(coder: aDecoder)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
        self.originCenter = CGPoint(x: frame.midX, y: frame.midY)
        self.nibSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Promote the touched view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.view.layer.cornerRadius = 6.0
        
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        setupBorder()
    }
    
    private func setupBorder() {
        self.view.layer.cornerRadius = 6.0
        self.view.layer.borderWidth = 2.0
        self.view.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true
    }
}
