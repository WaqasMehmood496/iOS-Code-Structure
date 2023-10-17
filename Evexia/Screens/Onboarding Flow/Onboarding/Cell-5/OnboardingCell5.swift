//
//  OnboardingCell5.swift
//  Evexia
//
//  Created by Codes Orbit on 06/10/2023.
//

import UIKit
import Atributika

class OnboardingCell5: UICollectionViewCell, CellIdentifiable {

    // MARK: - IBOutlets
    @IBOutlet private weak var textLabel: AttributedLabel!
    @IBOutlet private weak var recycleTextLabel: AttributedLabel!
    @IBOutlet private weak var projectListTable: UITableView!
    //Variables
    private var projectsData:[Project] = []
    var delegate: OnboardingCell5Delegate?
    
    //MARK: - Properties
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
    
    private var plainAttributes: Style {
        return Style
            .foregroundColor(.blue84, .normal)
            .backgroundColor(.white)
            .font(UIFont(name: "Outfit-SemiBold", size: 24.0)!)
        
    }
    
    private var p: Style {
        return Style("p")
            .foregroundColor(.blue84, .normal)
            .font(UIFont(name: "Outfit-Regular", size: 18.0)!)
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
        setupTableView()
    }
    
    //MARK: - Private Methods
    func setupLabels(){
        self.recycleTextLabel.attributedText = "<h1>1.25</h1> <p>t</p>\n<h3>CO2 saving</h3>".localized()
            .style(tags: h1, p, h3)
        self.recycleTextLabel.textAlignment = .center

    }

    func setupTableView() {
        self.projectListTable.register(UINib(nibName: EcologiTableCell.Identifier,bundle: nil), forCellReuseIdentifier: EcologiTableCell.Identifier)
        self.projectListTable.register(UINib(nibName: TitleCell.Identifier,bundle: nil), forCellReuseIdentifier: TitleCell.Identifier)
        self.projectListTable.dataSource = self
        self.projectListTable.delegate = self
    }
    
    // MARK: - Cell Configuration
    func configure(with model: Onboarding,projectsData:[Project]) {
        textLabel.attributedText = model.text.styleAll(self.plainAttributes)
        textLabel.textAlignment = .center
        
        //Projects data
        self.projectsData = projectsData
    }
}


// MARK: - Table View
extension OnboardingCell5: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.projectsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: TitleCell.Identifier, for: indexPath) as? TitleCell{
                cell.selectionStyle = .none
                    return cell
                }
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: EcologiTableCell.Identifier, for: indexPath) as? EcologiTableCell {
                cell.configure(data: self.projectsData[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.delegate?.rowSelectInTableView(project: projectsData[indexPath.row])
    }
}
