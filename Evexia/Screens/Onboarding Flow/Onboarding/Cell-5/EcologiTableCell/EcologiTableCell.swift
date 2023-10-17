//
//  ecologiTableCell.swift
//  Evexia Staging
//
//  Created by Codes Orbit on 09/10/2023.
//

import UIKit
import Kingfisher

class EcologiTableCell: UITableViewCell {

    static let Identifier = "EcologiTableCell"
    
    //MARK: - IBOutlets
    @IBOutlet weak private var whiteBackground: UIView!
    @IBOutlet weak private var title: UILabel!
    @IBOutlet weak private var subTitle: UILabel!
    @IBOutlet weak private var discription: UILabel!
    @IBOutlet weak private var imageTitle: UIImageView!
    // MARK: -  Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackground()
    }
    
    //MARK: - Private Functions
    func setupBackground() {
        self.whiteBackground.layer.cornerRadius = 16
        self.whiteBackground.clipsToBounds = true
        self.imageTitle.layer.cornerRadius = 8.0
    }
    
    func configure(data:Project ) {
        title.text = data.title
        let subTitleString = String(data.currency)+String(data.amount)+"/"+String(data.weightType)+" "+String(data.gas)
        subTitle.text = subTitleString
        discription.text = data.description
        imageTitle.kf.setImage(url: "http://18.133.13.117:4000/api/v1/attachment/"+data.image.fileURL, sizes: imageTitle.frame.size)
        
    }
}
