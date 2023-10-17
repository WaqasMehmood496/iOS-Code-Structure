//
//  ViewController+WebView.swift
//  Evexia
//
//  Created by Oleksandr Kovalov on 01.09.2021.
//

import Foundation

import UIKit
import WebKit
import Combine
import Reachability

class ExternalVC: BaseViewController, StoryboardIdentifiable, WKUIDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var webContainer: UIView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    // MARK: - Properties
    var viewModel: SocialVMType!
    
    private let signIn = PassthroughSubject<Result<AuthResponseModel, ServerError>, Never>()
    private var cancellables: [AnyCancellable] = []
    private let reachability = try! Reachability()
    
    private lazy var initialNavigationBarHidden = navigationController?.navigationBar.isHidden ?? false
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        return webView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(to: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        guard isMovingToParent else { return }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent else { return }
        navigationController?.setNavigationBarHidden(initialNavigationBarHidden, animated: animated)
    }
    
    // MARK: - Methods
    func bind(to viewModel: SocialVMType) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let input = SocialVMInput(sigInWithApple: signIn.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.sink { [unowned self] state in
            self.render(state)
        }.store(in: &cancellables)
    }
    
    func render(_ state: SocialAuthState) {
        switch state {
        case let .appleSignIn(state):
            dismiss(animated: true, completion: { [weak self] in
                self?.viewModel.dismissSocialWebView.send(state)
            })
        case let .failure(error):
            modalAlert(modalStyle: error.errorCode, completion: { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
    }
}

// MARK: - WKNavigationDelegate
extension ExternalVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let pref = WKWebpagePreferences()
        pref.preferredContentMode = .recommended
        decisionHandler(.allow, pref)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let url = navigationResponse.response.url {
            let query = URLComponents(string: url.absoluteString)
            if let lastPath = query?.url?.lastPathComponent {
                if lastPath == "success#" {
                    decisionHandler(.cancel)
                } else if lastPath == "cancel" {
                    decisionHandler(.cancel)
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        // connected observer
        reachability.whenReachable = { _ in
          print("Connected to Internet")
        }

        // disconnected observer
        reachability.whenUnreachable = { [weak self] _ in
            let error = ServerError(errorCode: .networkConnectionError)
            self?.modalAlert(modalStyle: error.errorCode, completion: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            return
        }
        
        // start reachability observer
        do {
          try reachability.startNotifier()
        } catch {
          print("Unable to start notifier")
        }
        
        switch viewModel.webViewtype {
        case .signInWithApple:
            if !webView.canGoBack, !webView.isLoading {
                navigationController?.dismiss(animated: true, completion: nil)
            }
        case .signInWithGoogle:
            navigationController?.dismiss(animated: true, completion: nil)
        default: break
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        switch viewModel.webViewtype {
        case .signInWithGoogle:
            getResponseSignInWithAppleAndGoogle(webView: webView)
        case .signInWithApple:
            getResponseSignInWithAppleAndGoogle(webView: webView)
        default: break
        }
        
        loaderIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let error = ServerError(errorCode: .networkError)
        modalAlert(modalStyle: error.errorCode)
        loaderIndicator.stopAnimating()
    }
        
    private func getResponseSignInWithAppleAndGoogle(webView: WKWebView) {
        webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML") { [weak self] innerHTML, _ in
            let str = (innerHTML as! String).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            do {
                let dat = str.data(using: .utf8) ?? Data()
                let response: AuthResponseModel = try JSONDecoder().decode(AuthResponseModel.self, from: dat)
                self?.webView.isHidden = true
                self?.signIn.send(.success(response))
            } catch {
                do {
                    let dat = str.data(using: .utf8) ?? Data()
                    let serverError: ServerError = try JSONDecoder().decode(ServerError.self, from: dat)
                    self?.webView.isHidden = true
                    self?.signIn.send(.failure(serverError))
                } catch { }
            }
        }
    }
}

// MARK: - Private Extension
private extension ExternalVC {
    func setupUI() {
        setupWebView()
        setupNavigation()
    }
    
    func setupNavigation() {
        applyDefaultTitle(viewModel.getTitle())
        applyDefaultNavigationBarStyle()
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        leftButton.tintColor = .systemBlue
        let rightButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadPage))
        rightButton.tintColor = .systemBlue
       
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = leftButton
    }
    
    func setupWebView() {
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        webContainer.addSubview(webView)
        webContainer.bringSubviewToFront(loaderIndicator)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: webContainer.leftAnchor),
            webView.rightAnchor.constraint(equalTo: webContainer.rightAnchor),
            webView.topAnchor.constraint(equalTo: webContainer.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webContainer.bottomAnchor)
        ])
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        if let url = viewModel.getTypeUrl() {
            load(url)
        }
    }
    
    func load(_ url: URL) {
        let request = URLRequest(url: url)
        loaderIndicator.startAnimating()
        webView.load(request)
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func reloadPage() {
        if let url = viewModel.getTypeUrl() {
            load(url)
        }
    }
}
