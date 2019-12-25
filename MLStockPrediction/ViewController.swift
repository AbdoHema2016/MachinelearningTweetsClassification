//
//  ViewController.swift
//  MLStockPrediction
//
//  Created by Abdelrahman-Arw on 12/25/19.
//  Copyright © 2019 Abdelrahman-Arw. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {

    //MARK: - Variables
    let sentimentClassifier = TweetSentimentClassifier()
    
    // Instantiation using Twitter's OAuth Consumer Key and secret
    let swifter = Swifter(consumerKey: "a3uWeLHeS94ZuB7AVnzjNF0va", consumerSecret: "bqM1bdMHSmh722ZUML0wrjXSNBG6nhiNu2XBeJU7M1elGztiOz")
    let tweetCount = 1000
    let locationManager = CLLocationManager()
    var langitude = String()
    var latitude = String()
    //MARK: - IBActions and Labels
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var lblSentiment: UILabel!
    
    @IBAction func btnPredict(_ sender: Any) {
        
       fetchTweets()
        
    }
    
    func fetchTweets(){
        
        if let searchText = textField.text {
            //Search twitter using swifter api for number of tweets on a topic using search text
            swifter.searchTweet(using: searchText, lang:"en", resultType: "mixed", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                //convert tweets into appropriate input for our classifier
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let classificationTweet = TweetSentimentClassifierInput(text: tweet)
                        
                        tweets.append(classificationTweet)
                    }
                }
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("there was an error\(error)")
            }
        }
    }
    
    func makePrediction(with tweets:[TweetSentimentClassifierInput]){
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for pred in predictions {
                let sentiment = pred.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
           
            updateUI(with: sentimentScore)
            
        } catch {
            print("There was an error making a prediction \(error)")
        }
    }
    
    func updateUI(with sentimentScore: Int){
        if sentimentScore > 20 {
            self.lblSentiment.text = "😍"
            self.backgroundView.backgroundColor = .white
        } else if sentimentScore > 10 {
            self.lblSentiment.text = "😁"
            self.backgroundView.backgroundColor = .orange
        } else if sentimentScore > 2 {
            self.lblSentiment.text = "🙂"
            self.backgroundView.backgroundColor = .green
        } else if sentimentScore > -2 {
            self.lblSentiment.text = "😐"
            self.backgroundView.backgroundColor = .white
        } else if sentimentScore > -10 {
            self.lblSentiment.text = "😕"
            self.backgroundView.backgroundColor = .brown
        } else if sentimentScore > -20 {
            self.lblSentiment.text = "😡"
            self.backgroundView.backgroundColor = .black
        } else {
            self.lblSentiment.text = "🤮"
            self.backgroundView.backgroundColor = .yellow
        }
    }

    //Get Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        langitude = String(locValue.longitude)
        latitude = String(locValue.latitude)
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
    }
    
    //MARK: - App lifeCyle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorization from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
       
        
        
    }
    
    


}

