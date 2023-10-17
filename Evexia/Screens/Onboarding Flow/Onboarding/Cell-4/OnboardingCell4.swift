//
//  OnboardingCell4.swift
//  Evexia
//
//  Created by Codes Orbit on 06/10/2023.
//

import UIKit
import Atributika
import RookSDK
import HealthKit

class OnboardingCell4: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: AttributedLabel!
    @IBOutlet weak var mySyncedDevicesView:UIView!
    @IBOutlet private weak var syncedDevicesButton: UISwitch!
    
    //MARK: - Properties
    private let permissionManager = RookConnectPermissionsManager()
    var healthStore: HKHealthStore?
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.blue84, .normal)
            .backgroundColor(.white)
            .font(UIFont(name: "Outfit-SemiBold", size: 24.0)!)
        
    }
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    //MARK: - Private Methods
    func setup() {
        self.mySyncedDevicesView.layer.cornerRadius = 20.0
        self.mySyncedDevicesView.layer.borderWidth = 1.0
        self.mySyncedDevicesView.layer.borderColor = UIColor(hex: "F5F5F5")?.cgColor
        self.mySyncedDevicesView.layer.cornerRadius = 20.0
    }
    
    // MARK: - Cell Configuration
    func configure(with model: Onboarding) {
        textLabel.attributedText = model.text.styleAll(self.plainAttributes)
        textLabel.textAlignment = .center
    }
    
    //MARK: - IBActions
    @IBAction func syncedDevicesButton(_ sender: UISwitch){
        rookConfiguration()
    }
    
    func rookConfiguration() {
        let healthStore = HKHealthStore()
        
        // Define the HealthKit data types your app needs access to.
        let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount
                                                                                                 )!]
        // Request HealthKit authorization.
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            if success {
                // Authorization granted, you can now use HealthKit data.
                print("Good to go!")
                DispatchQueue.main.async {
                    self.syncedDevicesButton.setOn(true, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    if self.syncedDevicesButton.isOn{
                        
                        self.syncedDevicesButton.setOn(false, animated: true)
                    }
                }
                
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
}
