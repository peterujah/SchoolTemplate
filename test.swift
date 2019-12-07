//
//  ViewController.swift
//  FoodShop2U Seller Center
//
//  Created by MacBookAir on 08/08/2019.
//  Copyright © 2019 BlockByteTech LTD. All rights reserved.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge
import Alamofire
import CoreLocation
import SVProgressHUD
import AuthenticationServices
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

//import CropViewController


class ViewController: UIViewController, UIWebViewDelegate, CLLocationManagerDelegate, WKScriptMessageHandler, UIScrollViewDelegate{
    

    //var webView = WKWebView(frame: CGRect(), configuration: WKWebViewConfiguration())
    @IBOutlet weak var webView: WKWebView!
    /*@IBOutlet weak var noInternetView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var somethingView: UIView!*/

    var rootUrl = "https://foodshop2u.com/_www/_kitchen_f0b4b85899a4084bcc2cf695a1d54f4da/index.android.php?connection_node=IOSCreatedApp&app_version=1.0"
    var tokenAndLocationUpdate = "https://foodshop2u.com/_www/_apis/initializeToken.php?data="
    
    let objAJProgressView = AJProgressView()
    
    var locationManager: CLLocationManager!
    var localTimeZoneName: String { return TimeZone.current.identifier }
    var strLatitude = ""
    var strLongitude = ""
    var bridge: WKWebViewJavascriptBridge!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        webViewSetup()
        locationConfiguration()
        /*noInternetView.isHidden = true
        somethingView.isHidden = true
        retryButton.clipsToBounds = true
        retryButton.layer.cornerRadius = 3
        retryButton.layer.borderColor = UIColor.red.cgColor
        retryButton.layer.borderWidth = 1*/
         if Connectivity.isConnectedToInternet() {
            loadRootUrl()
         }
         else{
            /*noInternetView.isHidden = false
            somethingView.isHidden = true
            view.bringSubviewToFront(noInternetView)
            view.bringSubviewToFront(somethingView)*/
            loadLocalHtml(fileStr: "error.internet")
            showToast("No internet connection")
        }
        scheduledTimerWithTimeInterval()
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
            scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x, y:scrollView.contentSize.height - scrollView.frame.size.height), animated: false)
        }
    }
    
    //MARK: Progress View Functions
    func progressViewConfoguration(){
        objAJProgressView.imgLogo = UIImage(named:"progress_gray")!
        objAJProgressView.firstColor = #colorLiteral(red: 0.4073076421, green: 0.1554396455, blue: 0.3546419804, alpha: 1)
        objAJProgressView.secondColor = #colorLiteral(red: 0.4197691297, green: 0.1390994166, blue: 0.4001415403, alpha: 1)
        objAJProgressView.thirdColor = #colorLiteral(red: 0.3790285928, green: 0.1453439148, blue: 0.5, alpha: 1)
        objAJProgressView.duration = 5.0
        objAJProgressView.lineWidth = 5.0
        objAJProgressView.bgColor =  UIColor.black.withAlphaComponent(0.3)
        _ = objAJProgressView.isAnimating
    }
    
    func progressBarShow(){
        SVProgressHUD.show()
    }
    
    func progressBarHide(){
        SVProgressHUD.dismiss()
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkInternetAndHideAndShowViews), userInfo: nil, repeats: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*@IBAction func reloadButtonTapped(sender: UIButton){
        noInternetView.isHidden = true
        somethingView.isHidden = true
        if Connectivity.isConnectedToInternet() {
            loadRootUrl()
        }
        else{
            noInternetView.isHidden = false
            somethingView.isHidden = true
            view.bringSubviewToFront(noInternetView)
            view.bringSubviewToFront(somethingView)
        }
    }*/
    
    @objc func checkInternetAndHideAndShowViews(){
        if Connectivity.isConnectedToInternet() {
            /*noInternetView.isHidden = true
            somethingView.isHidden = true
            view.bringSubviewToFront(webView)
            view.bringSubviewToFront(noInternetView)*/
            //loadRootUrl()
        }
        else{
            /*noInternetView.isHidden = false
            somethingView.isHidden = true
            view.bringSubviewToFront(noInternetView)
            view.bringSubviewToFront(somethingView)*/
            //loadLocalHtml(fileStr: "error.internet")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scrollView = webView.subviews[0] as? UIScrollView
        webView.scrollView.contentSize = CGSize(width: webView.frame.size.width, height: webView.scrollView.contentSize.height)
        scrollView?.bounces = false
        scrollView?.decelerationRate = .fast
        scrollView?.showsHorizontalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        //let views : [String:Any] = ["webView":webView]
        let views : [String: WKWebView] = ["webView":webView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[webView]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[webView]-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            ])
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.bouncesZoom = false
    }
    
    //MARK: WEBKIT SETUP
    func webViewSetup(){
        let contentController = WKUserContentController();
        
        contentController.add(self, name: "callbackRefreshApi")
        contentController.add(self, name: "callbackInviteFriends")
        contentController.add(self, name: "callbackSavePreferences")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        //webView = WKWebView(frame: CGRect(), configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        bridge = WKWebViewJavascriptBridge(webView: webView)
        bridge.isLogEnable = true
    }
    

    func locationConfiguration(){
        if (CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        strLatitude = "\(location.coordinate.latitude)"
        strLongitude = "\(location.coordinate.longitude)"
        print("Latitude ===",strLatitude)
        print("Longitude ===",strLongitude)
        locationManager.stopUpdatingLocation()
        if UserDefaults.standard.object(forKey: "token_api_called") == nil {
            let getUserId = UserDefaults.standard.string(forKey: "userAccountReference") ?? "NULL"
            print("FIRST USER API", getUserId)
            updateTokenAndLocationAPI(userId: getUserId, action: "insert")
        }
    }
    
    
    func userContentController (_ userContentController:WKUserContentController,didReceive message: WKScriptMessage){
        print("CALLBACK==", message.name)
        if message.name == "callbackInviteFriends" {
            print("INVITE FRIENDS PRESSED")
            self.inviteFriends()
        }
        else if message.name == "callbackSavePreferences" {
            let userName = (message.body as? String)!
            self.savePreference(key: "userAccountReference", value: userName)
            print("USER PREFERENCE CALLED", userName)
        }
        else if message.name == "callbackRefreshApi"  {
            let requestUserId = (message.body as? String)!
            let getLastUserId = UserDefaults.standard.string(forKey: "lastUserId") ?? "NULL"
            print("REFRESH TOKEN CALLED", requestUserId)
            print("REFRESH TOKEN getLastUserId", getLastUserId)
            
            if !requestUserId.isEmpty && getLastUserId != "NULL" {
                if requestUserId != getLastUserId {
                    print("REFRESH TOKEN FOR CHANGED USER")
                    self.savePreference(key: "lastUserId", value: requestUserId)
                }
                else {
                    print("REFRESH TOKEN FOR OLD USER")
                }
            }else{
                print("REFRESH TOKEN FOR NEW USER")
                self.savePreference(key: "lastUserId", value: requestUserId)
            }
            
            UserDefaults.standard.removeObject(forKey: "token_api_called")
            UserDefaults.standard.synchronize()
            self.updateTokenAndLocationAPI(userId: requestUserId, action: "update")
        }
    }
    
    //MARK: WEBVIEW HANDLER
    func loadRootUrl() {
        //progressBarShow()
        //rootUrl = "\(rootUrl)\("\("&new_timezone")=\(localTimeZoneName)")"
        let url = URL(string: rootUrl)
        var requestURL: URLRequest? = nil
        if let url = url {
            requestURL = URLRequest(url: url)
        }
        if var requestURL = requestURL {
            requestURL.cachePolicy = .returnCacheDataElseLoad
            requestURL.setValue("ios", forHTTPHeaderField: "App-Requested-With")
            requestURL.setValue("com.foodshop2u.ios.shop", forHTTPHeaderField: "X-Requested-With")
            requestURL.setValue("https://com.foodshop2u.ios.shop", forHTTPHeaderField: "Referer")
            requestURL.setValue("WrmyMvaSYYo_BCkQFgg7MAM", forHTTPHeaderField: "Request-Authorization")
            webView.load(requestURL)
        }
    }
    
    func loadLocalHtml(fileStr: String){
        let rootFile = "\("html/")\(fileStr)"
        let url = Bundle.main.url(forResource: rootFile, withExtension: "html")
        let request = NSURLRequest(url: url!)
        webView.load(request as URLRequest)
    }
    
    func loadRequestURL(urlStr: String) {
        progressBarShow()
        let url = URL(string: urlStr)
        var requestURL: URLRequest? = nil
        if let url = url {
            requestURL = URLRequest(url: url)
        }
        if var requestURL = requestURL {
            requestURL.cachePolicy = .returnCacheDataElseLoad
            webView.load(requestURL)
        }
    }
    
    func showToast(_ message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4, delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    //MARK: ALERT
    func showAlert(msg: String){
        let alertController = UIAlertController(title: "FoodShop2U", message: msg, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        let keyWindow: UIWindow? = UIApplication.shared.keyWindow
        keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: INVITE FRIENDS
    func inviteFriends(){
        let shareItems = ["Hey, Check Out FoodShop2U App, You can order food from nearby restaurants and fresh grocery items, its Cash On Delivery.\n https://foodshop2u.com"]
        let avc = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        present(avc, animated: true)
    }
    
    //MARK: SAVE USER PREFRENCE
    func savePreference(key : String, value: String){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: TOKEN & LOCATION UPDATION API
    func updateTokenAndLocationAPI(userId: String, action: String){
        //hide progress bar because i want to do this in background
        //progressBarShow()
        if Connectivity.isConnectedToInternet() {
            if appDelegate.getDeviceToken() != "" && userId != "NULL" {
                UserDefaults.standard.setValue("yes", forKey: "token_api_called")
                UserDefaults.standard.synchronize()
            }
            let jsonUserDictionary = [
                "lat" : strLatitude,
                "long" : strLongitude,
                "device_type" : "ios",
                "from" : "seller",
                "timezone" : localTimeZoneName,
                "action" : action,
                "device_name" : UIDevice.current.name,
                "uniqueIdentifier" : appDelegate.getDeviceUniqueID,
                "fcmtoken" : appDelegate.getDeviceToken(),
                "clientId" : userId,
                "key" : "mrqPTrlu-2NVFRaVY4cXVoVjA2NVFRaVY4cXVoVjA0B_mrqPTrlu-2NVFRaVY4cXVoVjA"
            ]
            var mutArrData: [AnyHashable] = []
            mutArrData.append(jsonUserDictionary)
            
            let dictJsonData = [
                "" : mutArrData
            ]
            var _: Error?
            var jsonData: Data? = nil
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dictJsonData, options: [])
            } catch {
            }
            var jsonString = ""
            if let jsonData = jsonData {
                jsonString = (String(data: jsonData, encoding: String.Encoding.utf8) as String?)!
            }
            jsonString = (jsonString as NSString).substring(to: jsonString.count - 1)
            jsonString = (jsonString as NSString).substring(from: 1)
            jsonString = (jsonString as NSString).substring(from: 1)
            jsonString = (jsonString as NSString).substring(from: 1)
            jsonString = (jsonString as NSString).substring(from: 1)
            jsonString = jsonString.replacingOccurrences(of: " ", with: "")
            jsonString = jsonString.replacingOccurrences(of: "[", with: "")
            jsonString = jsonString.replacingOccurrences(of: "]", with: "")
            
            let apiUrl:String = "\(self.tokenAndLocationUpdate)\(jsonString)"
            print("REQUEST URL", apiUrl)
            let encodedUrl = apiUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            Alamofire.request(encodedUrl!, method: .get, parameters:nil, encoding: URLEncoding.default, headers:nil).responseJSON
                { (response) in
                    switch response.result{
                    case .success(let json):
                        self.progressBarHide()
                        let mainStatusCode:Int = (response.response?.statusCode)!
                        if let jsonResponse = json as? NSDictionary
                        {
                            print("STATUS CODE", mainStatusCode)
                            print("RESPONSE DATA", jsonResponse)
                            if (mainStatusCode == 200){
                                if ((jsonResponse.value(forKey: "response") as? NSDictionary) != nil){
                                    _ = jsonResponse.value(forKey: "response") as? NSDictionary
                                    //successBlock(resultDict, true, nil)
                                }else{
                                    if jsonResponse.allKeys.count > 0 {
                                        // successBlock(jsonResponse, true, nil)
                                    }
                                }
                            }
                            else if (mainStatusCode == 201){
                                if ((jsonResponse.value(forKey: "response") as? NSDictionary) != nil){
                                    _ = jsonResponse.value(forKey: "response") as? NSDictionary
                                    //successBlock(resultDict, true, nil)
                                }else{
                                    if jsonResponse.allKeys.count > 0 {
                                        //successBlock(jsonResponse, true, nil)
                                    }
                                }
                            }
                            else{
                                self.progressBarHide()
                                let boolAsString = jsonResponse.value(forKey: "error") as! Bool
                                print(boolAsString)
                                if (boolAsString){
                                    let errorMessage = jsonResponse.value(forKey: "code") as! Int
                                    print(errorMessage)
                                }
                            }
                        }else{
                            self.progressBarHide()
                            print("Json Object is not NSDictionary : Please Check this API")
                        }
                        break
                    case .failure(let error):
                        self.progressBarHide()
                        print(error)
                        print("Response Status Code :: \(String(describing: response.response?.statusCode))")
                        let datastring = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
                        print(datastring ?? "Test")
                        break
                    }
            }
        }else{
            self.progressBarHide()
            self.showAlert(msg: "Please check your internet connection")
        }
    }
    
}

/*INTERCEPT REQUEST CLASS*/
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webViewDidStartLoad")
        progressBarShow()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webViewDidFinishLoad")
        progressBarHide()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var requestUrlString = "\(navigationAction.request.url!)"
        let requestUrlScheme = "\(navigationAction.request.url!.scheme!)"
        let requestUrlHost = "\(navigationAction.request.url!.host ?? "no.app")"
        print("URL STRING======",requestUrlString)
        print("URL SCHEME======",requestUrlScheme)
        print("URL HOST======",requestUrlHost)
        
       if requestUrlScheme == "tel" {
            if let url = URL(string: requestUrlString) {
                UIApplication.shared.open(url, options:  [:], completionHandler: nil)
            }
            print("TEL CLICKED")
        }
        else if requestUrlScheme == "mailto" {
            if let url = URL(string: requestUrlString) {
                UIApplication.shared.open(url, options:  [:], completionHandler: nil)
            }
            print("MAILTO CLICKED")
        }
       else if requestUrlScheme == "refresh" {
        print("REFRESH CLICKED")
        loadRootUrl()
       }
       else if requestUrlHost == "app.refresh" {
        print("APP REFRESH CLICKED")
        loadRootUrl()
       }
        else if requestUrlScheme == "reload" {
            print("RELOAD CLICKED")
            loadRootUrl()
        }
        else if requestUrlScheme == "exit" {
            print("EXIT CLICKED")
            exit(0)
        }
        else if requestUrlScheme == "opentop" {
            requestUrlString = requestUrlString.replacingOccurrences(of: "opentop:", with: "")
            if let url = URL(string: requestUrlString) {
                UIApplication.shared.open(url, options:  [:], completionHandler: nil)
                webView.stopLoading()
            }
            print("OPENTOP CLICKED")
            print("OPENTOP URL = " + requestUrlString)
        }
        else if requestUrlScheme == "http" || requestUrlScheme == "https" {
            print("HTTP OR HTTPS CLICKED")
            if !requestUrlString.contains("foodshop2u.com") {
                if let url = URL(string: requestUrlString) {
                    UIApplication.shared.open(url, options:  [:], completionHandler: nil)
                    webView.stopLoading()
                }
            }
        }
        else if requestUrlScheme == "share" {
            requestUrlString = requestUrlString.removingPercentEncoding!
            requestUrlString = requestUrlString.replacingOccurrences(of: "share:", with: "")
            let shareItems = [requestUrlString]
            let avc = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            present(avc, animated: true)
        }
        else if requestUrlScheme == "rate" {
            print("RATE CLICKED")
            UIApplication.shared.open(URL(string: "itms://itunes.apple.com")!, options: [:], completionHandler: nil)
        }
        else if requestUrlScheme == "map" {
            requestUrlString = requestUrlString.replacingOccurrences(of: "map:", with: "")
            let directionsURL = "http://maps.apple.com/?address=\(requestUrlString)"
            
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                if #available(iOS 10.0, *) {
                    if let url = URL(string: directionsURL) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { success in
                        })
                    }
                } else {
                    if let url = URL(string: directionsURL) {
                        UIApplication.shared.open(url, options:  [:], completionHandler: nil)
                    }
                }
            } else {
                if let url = URL(string: directionsURL) {
                    UIApplication.shared.open(url, options:  [:], completionHandler: nil)
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
   func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
            print("decidePolicyFor Response Code == ", response.statusCode)
            if response.statusCode == 404 || response.statusCode == 500 {
                let url = Bundle.main.url(forResource: "html/index", withExtension: "html")
                let request = NSURLRequest(url: url!)
                webView.load(request as URLRequest)
                print("HTTP ERROR 400-500")
                showToast("HTTP ERROR 400-500")
            }
        }
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Event-didFailLoadWithError: \("didFailNavigation called")")
        print("WKNavigation == ", error)
        progressBarHide()
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("Event-url: Request UR")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Event-didFailLoadWithError: \("didFailNavigation called")")
        print("didFailNavigation == ", error)
        progressBarHide()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print("didFailProvisionalNavigation Error Occured")
        if error.code == -1001 { // TIMED OUT:
            // CODE to handle TIMEOUT
            showToast("TIMEOUT")
        } else if error.code == -1003 { // SERVER CANNOT BE FOUND
            // CODE to handle SERVER not found
            showToast("SERVER CANNOT BE FOUND")
        } else if error.code == -1100 { // URL NOT FOUND ON SERVER
            // CODE to handle URL not found
            showToast("URL NOT FOUND ON SERVER")
        }
        //loadLocalHtml(fileStr: "error.internet");
    }
}

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

