//
//  OnboardingCell6.swift
//  Evexia
//
//  Created by Codes Orbit on 06/10/2023.
//

import UIKit
import Atributika

class OnboardingCell6: UICollectionViewCell, CellIdentifiable {


    // MARK: - IBOutlets
    @IBOutlet private weak var textLabel: AttributedLabel!
    @IBOutlet private weak var sectionOneTextLabel: AttributedLabel!
    @IBOutlet private weak var sectionTwoTextLabel: AttributedLabel!
    @IBOutlet private weak var recycleTextLabel: AttributedLabel!
    @IBOutlet private weak var sectionOne: UIView!
    @IBOutlet private weak var sectionTwo: UIView!
    
    //MARK: - Properties
    var delegate: OnboardingCell6Delegate?
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.blue84, .normal)
            .backgroundColor(.white)
            .font(UIFont(name: "Outfit-SemiBold", size: 24.0)!)
    }
    
    private var LightAttributes: Style {
        return Style
            .foregroundColor(.blue, .normal)
            .font(UIFont(name: "Outfit-Light", size: 16.0)!)
    }
    
    private var BoldAttributes: Style {
        return Style("b")
            .foregroundColor(.blue, .normal)
            .font(UIFont(name: "Outfit-SemiBold", size: 18.0)!)
    }
    
    private var h1: Style {
        return Style("h1")
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "Outfit-SemiBold", size: 32.0)!)
    }
    
    private var h3: Style {
        return Style("h3")
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "NunitoSans-Bold", size: 18.0)!)
    }
    
    private var p: Style {
        return Style("p")
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "Outfit-Regular", size: 18.0)!)
    }
    
    let sectionOneLabelText = "<b>I'd like a tailored plan:</b>\nWe'll ask you a few questions\nabout your wellbeing goals and\ncreate a plan of activities to help\nyou to achieve them.".localized()
    let sectionTwoLabelText = "<b>Quick Start:</b>\nUse steps and recognising your\npeers to fund climate action.\nTrack your health and more.".localized()
    let recycleLabelText = "<h1>32.25</h1> <p>t</p>\n<h3>CO2 saving</h3>".localized()
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupLabels()
        self.setupSections()
    }
    
    func setupLabels(){
        self.sectionOneTextLabel.attributedText = sectionOneLabelText.style(tags: BoldAttributes).styleAll(LightAttributes)
        
        self.sectionTwoTextLabel.attributedText = sectionTwoLabelText.style(tags:BoldAttributes).styleAll(LightAttributes)
        
        self.recycleTextLabel.attributedText = recycleLabelText.style(tags: h1, p, h3)
        self.recycleTextLabel.textAlignment = .center

    }
    
    func setupSections()  {
        self.sectionOne.layer.cornerRadius = 16.0
        self.sectionTwo.layer.cornerRadius = 16.0
    }
    
    // MARK: - Cell Configuration
    func configure(with model: Onboarding) {
        textLabel.attributedText = model.text.styleAll(self.plainAttributes)
        textLabel.textAlignment = .center
    }
    
    //MARK: - IBActions
   @IBAction func quickStartButtonClick(_sender: UIButton) {
       self.delegate?.navigateToHome()
    }
   @IBAction func tailoredPlanButtonClick(_sender: UIButton) {
       self.delegate?.navigateToPersonalPlan()
    }
}
