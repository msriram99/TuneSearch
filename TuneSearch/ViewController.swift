//
//  ViewController.swift
//  TuneSearch
//
//  Created by Himaja Motheram on 4/9/17.
//  Copyright © 2017 Sriram Motheram. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet internal var searchButton: UIButton!
    
    @IBOutlet internal var artistNameTextField: UITextField!
    
    @IBOutlet var ArtistView: UITableView!
    
    var artistName: String = ""
    var albumName: String = ""
    var songName: String = ""
    var d: NSMutableData = NSMutableData()
    
    //var tData: NSArray = NSArray()
    
    var artistData   = [String]()
    var albumData  = [String]()
    var songData   = [String]()
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artistData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistViewCell", for: indexPath)
        
        //print("here1")
        
         songName = self.songData[indexPath.row]
         artistName = self.artistData[indexPath.row]
         albumName = self.albumData[indexPath.row]
        
         cell.textLabel?.text = " Artist: \(artistName)  Album: \(albumName) "
         cell.detailTextLabel?.text = "Song: \(songName) "

         return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           
        }
    }

    @IBAction func searchPressed(button: UIButton) {
        
        artistName = artistNameTextField.text!
        
       
        artistData.removeAll()
        albumData.removeAll()
        songData.removeAll()
        
        TuneSearch ()
        
    }
    
    
    func parseJson(data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print("JSON:\(jsonResult)")
            let resultsArray = jsonResult["results"] as! [[String:Any]]
           
            for resultDictionary in resultsArray {
                //print("Flavor:\(flavorDict)")
                
                
                print("Artist Name:\(resultDictionary["artistName"])")
                print("Album Name:\(resultDictionary["collectionCensoredName"])")
                print("Song Name:\(resultDictionary["trackCensoredName"])")
                guard let artist = resultDictionary["artistName"] else {
                    continue
                }
                guard let album = resultDictionary["collectionCensoredName"] else {
                    continue
                }
                guard let song = resultDictionary["trackCensoredName"] else {
                    continue
                }
              
                //self.tData.append(album as! String)
                self.albumData.append(album as! String)
                self.artistData.append(artist as! String)
                self.songData.append(song as! String)
            }
            
        } catch {
            print("JSON Parsing Error")
        }
         ArtistView.reloadData()
        
        DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    func TuneSearch( )
    {
         UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        artistName = artistNameTextField.text!
        
        let urlString = "https://itunes.apple.com/search?term=" + artistName
        
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let recvData = data else {
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            if recvData.count > 0 && error == nil {
                print("Got Data:\(recvData)")
                let dataString = String.init(data: recvData, encoding: .utf8)
                print("Got Data String:\(dataString)")
                self.parseJson(data: recvData)
            } else {
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()

    }

    
       
}

