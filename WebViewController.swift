//
//  ViewController.swift
//  DemoWebview
//
//  Created by ShuftiPro on 28/05/2021.
//

import UIKit
import WebKit
import AVFoundation
import SystemConfiguration

class ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView?.navigationDelegate = self
        webView?.scrollView.bounces = false
        activity.center = self.view.center
        self.webView?.addSubview(self.activity)
        self.activity.startAnimating()
        self.activity.hidesWhenStopped = true
        camPermission()
        loadWebSiteView(url: "enter-your-url")// Pass url here 




    }
    private func camPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            ""//self.configureCameraController()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    DispatchQueue.main.async {
                        ""//self.configureCameraController()
                    }
                } else {
                    self.camDenied() //self.cameraErrorMessage(camErrMsg: "The user has not granted to access the camera")
                }
            }
        case .denied:
            ""
            camDenied()
        case .restricted:
            ""
            //self.cameraErrorMessage(camErrMsg: "The user can't give camera access due to some restriction.")
            
        default:
            ""
            //self.cameraErrorMessage(camErrMsg: "Something has wrong due to we can't access the camera.")
        }
    }
    func camDenied() {
        DispatchQueue.main.async {
            var alertText = "It looks like your privacy settings are preventing us from accessing your camera to record proof. You can fix this by doing the following:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Turn the Camera on.\n\n5. Open this app and try again."

            var alertButton = "OK"
            var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)

            if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
            {
                alertText = "It looks like your privacy settings are preventing us from accessing your camera to record proof. You can fix this by doing the following:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."

                alertButton = "Go"

                goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                    }
                })
            }

            let alert = UIAlertController(title: "Camera Access Needed", message: alertText, preferredStyle: .alert)
            alert.addAction(goAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func loadWebSiteView(url: String) {
        if Reachability.isConnectedToNetwork() == true {
            let req = URLRequest(url: URL(string: url)!)
            DispatchQueue.main.async {
                self.webView?.load(req)
                self.disableTextSelection()
                self.disableZoom()
            }
        }else{
            self.customAlertView(titleTxt: "No Internet Connection", messageTxt: "Make sure your device is connected to the internet.")
        }
    }



}

extension ViewController {
    
    //function for alert view
    func customAlertView(titleTxt: String, messageTxt: String) {
        let alertController = UIAlertController(title: titleTxt, message: messageTxt, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            //function to dismiss current controller
            //self.dismissCurrentViewController()
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func disableTextSelection(){
        let javascriptStyle = "var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);"
        webView?.evaluateJavaScript(javascriptStyle, completionHandler: nil)
    }
    
    func disableZoom() {
        // Disable zoom in web view
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd,
                                                forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(script)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activity.startAnimating()
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activity.stopAnimating()
    }

        @available(iOS 15.0, *)
    func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                 initiatedBy frame: WKFrameInfo,
                 type: WKMediaCaptureType) async -> WKPermissionDecision {
        return .grant;
    }

    
    /// When a navigation action occurs for a link to wikipedia, ensure it gets
    /// Moved out to the default browser.
    func webView(_: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // If we are loading for any reason other than a link activated
        // then just process it.
        guard decidePolicyFor.navigationType == .linkActivated else {
            decisionHandler(.allow)
            return
        }
        
        // Reroute any request for wikipedia out to the default browser
        // then cancel the request.
        let request = decidePolicyFor.request
        if let url = request.url {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
            decisionHandler(.cancel)
            return
        }
        
        // By default allow the other requests to continue
        decisionHandler(.allow)
    }
}
class Reachability: NSObject {
    //function that checks device connectivity to the internet
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

}
