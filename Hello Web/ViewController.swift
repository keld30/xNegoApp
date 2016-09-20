//
//  ViewController.swift
//  Hello Web
//
//  Created by Darren Kim on 8/14/15.
//  Copyright (c) 2015 Darren Kim. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import GCDWebServers

var webView: WKWebView!

let gameUrl = "http://dev.negotools.fr/negosnap"

class ViewController: UIViewController, WKScriptMessageHandler {
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    let webServer = GCDWebServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // hide status bar
        UIApplication.sharedApplication().statusBarHidden = true
        
        var contentController = WKUserContentController();
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        contentController.addScriptMessageHandler(
            self,
            name: "speech"
        )
        
        initWebServer()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: view.bounds, configuration:configuration)
        
//        webView.scrollView.scrollEnabled = false;
//        webView.scrollView.panGestureRecognizer.enabled = false;
        webView.scrollView.bounces = false;
        
        view.addSubview(webView)
        
        webViewLoadUrl(gameUrl)
        print("start " + gameUrl)
        
        
    }
    
    func initWebServer() {
        print(NSHomeDirectory())
        print(NSBundle.mainBundle())
        var webRoot = NSBundle.mainBundle().resourcePath
        webServer.addGETHandlerForBasePath("/", directoryPath: webRoot, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
//        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
//            return GCDWebServerDataResponse(HTML:"<html><body><p>Hello World</p></body></html>")
//        })
        
        webServer.startWithPort(8080, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer.serverURL) in your web browser")
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
//            println("JavaScript is sending a message \(message.body)")
            
            let soundName = message.body as! String
    //        println(soundName);
                
                
            if let url = NSBundle.mainBundle().URLForResource(soundName,
                withExtension: "wav") {
                    let player = AVAudioPlayerPool.playerWithURL(url)
                    player?.play()
            }

    /*
            let file = NSBundle.mainBundle().pathForResource(soundName, ofType: "wav")
            if file != nil {
                var soundPath = NSURL(fileURLWithPath: file!)
                audioPlayer[soundName] = AVAudioPlayer(contentsOfURL: soundPath!, error: nil)
                audioPlayer[soundName]?.play()
                
            }
     */
            
            
        }
        
        if (message.name == "speech") {
            print("speech: \(message.body)")
            let text = message.body as! String
            
            myUtterance = AVSpeechUtterance(string: text)
            myUtterance.rate = 0.1
            synth.speakUtterance(myUtterance)
        }
        
        
    }
    
    func webViewLoadUrl(url: String) {
        
        if let url = NSURL(string: url) {
            let urlRequest = NSURLRequest(URL: url)
            webView.loadRequest(urlRequest)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

