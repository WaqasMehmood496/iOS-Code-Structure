//
//  WebViewVC.swift
//  Evexia
//
//  Created by admin on 07.10.2021.
//

import UIKit
import WebKit

class WebViewVC: BaseViewController, StoryboardIdentifiable, WKUIDelegate {
    
    @IBOutlet private weak var webView: WKWebView!
    
    var viewModel: WebViewVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configWebView()
        self.configUI()
    }
    
    func configWebView() {
        let request = URLRequest(url: self.viewModel.url)
        self.webView.load(request)
        
        if let data = try? Data(contentsOf: self.viewModel.url) {
            webView.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: self.viewModel.url)
        }
    }
    
    func configUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    }
    
    @objc
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
