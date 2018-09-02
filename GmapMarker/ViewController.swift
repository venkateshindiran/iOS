//
//  ViewController.swift
//  GmapMarker
//
//  Created by Sarvesh on 01/09/18.
//  Copyright © 2018 venkatesh. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    var googleMapView : GMSMapView!
    var gmspath : GMSPath!
    
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer!
     var marker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
  
    override func loadView() {
        
        // Create a GMSCameraPosition
        let camera = GMSCameraPosition.camera(withLatitude: 28.524555,
                                              longitude: 77.275111,
                                              zoom: 11.0,
                                              bearing: 30,
                                              viewingAngle: 40)
        
         googleMapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        //Setting the googleView
        googleMapView.camera = camera
        googleMapView.settings.myLocationButton = true
        googleMapView.settings.compassButton = true
        googleMapView.settings.zoomGestures = true
        googleMapView.animate(to: camera)
        view = googleMapView

        
        // Creates a marker in the center of the map.
        //let marker = GMSMarker()
        self.marker.position = CLLocationCoordinate2D(latitude: 28.524555, longitude: 77.275111)
        self.marker.title = "loc1"
        self.marker.snippet = "India"
        self.marker.map = self.googleMapView
        
        //28.643091, 77.218280
        let marker1 = GMSMarker()
        marker1.position = CLLocationCoordinate2D(latitude: 28.643091, longitude: 77.218280)
        marker1.title = "loc2"
        marker1.snippet = "India"
        marker1.map = self.googleMapView
        
        
        //call API service For Getting Route
        
        self.drawRoute(from: self.marker.position, to: marker1.position)

  
       
    }
   
    func drawRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyAhATDtE1roZ5u9q_kG0O7oFDVbfyyDj_k")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                        return
                        }
                        
                    if routes.count > 0 {
                        
                        // Draw Routes between Two Location Using PolyLine
                        
                        DispatchQueue.main.async{
                        for route in routes
                            {
                                let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                                let points = routeOverviewPolyline.object(forKey: "points")
                                let path = GMSPath.init(fromEncodedPath: points! as! String)
                                self.gmspath = path
                                let polyline = GMSPolyline.init(path: path)
                                polyline.strokeWidth = 4
                                
                                let bounds = GMSCoordinateBounds(path: path!)
                                self.googleMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                                polyline.map = self.googleMapView
                                
                            }
                                // Call Move Marker Function
                            
                                self.timer = Timer.scheduledTimer(timeInterval: 0.003, target: self, selector: #selector(self.moveMarkerFromOnetoAnother), userInfo: nil, repeats: true)

                            }
                        
                        }
                        
                     
                        else {
                            
                            print("OverQuery Limit")
                            
                        }
                    }
                }
                catch {
                    
                    print("error in JSONSerialization")
                   
                }
            }
        })
        task.resume()
    }
    
    
    
    @objc func moveMarkerFromOnetoAnother() {
        
        if (self.i < self.gmspath.count()) {
            self.animationPath.add(self.gmspath.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.black
            self.animationPolyline.strokeWidth = 4
            self.animationPolyline.map = self.googleMapView
           
            self.marker.position = self.gmspath.coordinate(at: self.i)
         

            self.i += 1
            
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.timer.invalidate()
        
    }
  /*  func updateMarker(coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double,marker: GMSMarker) {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(10.0)
        marker.rotation = 180
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        marker.position = coordinates
        
        // Center Map View
        //let camera = GMSCameraUpdate.setTarget(coordinates)
        // self.googleView.animate(with: camera)
        
        CATransaction.commit()
    }*/
    
    /*      DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // change 2 to desired number of seconds
     // Your code with delay
     // self.updateMarker(coordinates: marker1.position, degrees: 45, duration: 10.0, marker: marker)
     let count = self.gmspath.count()
     
     for index in 0...count {
     print(self.gmspath.coordinate(at: index))
     // sleep(1)
     
     self.updateMarker(coordinates: self.gmspath.coordinate(at: index), degrees: 45, duration: 1.0, marker: marker)
     
     
     }
     
     }*/
    
    /*  DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
     DispatchQueue.global(qos: .utility).async {
     
     let count1 = self.gmspath.count()
     
     for index in 0...count1 {
     print(self.gmspath.coordinate(at: index))
     // sleep(1)
     DispatchQueue.main.async {
     // now update UI on main thread
     self.updateMarker(coordinates: self.gmspath.coordinate(at: index), degrees: 45, duration: 10.0, marker: marker)
     
     }
     
     
     
     }
     }
     }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

