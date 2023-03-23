//
//  ViewController.swift
//  GeofencingDemo
//
//  Created by Debashis Pal on 13/03/23.
//

import UIKit
import CoreLocation
import GoogleMaps
import Toast
import MapKit
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
            let resultsVC = searchController.searchResultsController as? ResultsViewController else {
                return
            
        }
        resultsVC.delegate = self
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result{
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
                print(places)
            case .failure(let error):
                print(error)
            }
        }
    }
    

    var locationManager = HelperLocationManager.sharedInstance
    var locationManager1:CLLocationManager!
    
    let searchVc = UISearchController(searchResultsController: ResultsViewController())
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBAction func BtnClear(_ sender: Any) {
        let _ =  userDrawablePolygons.map{ $0.map = nil }
        let _ = polygonDeleteMarkers.map{ $0.map = nil}
        polygonDeleteMarkers.removeAll()
        userDrawablePolygons.removeAll()
        cancelDrawingBtn.isHidden = true
        self.coordinates.removeAll() //---added on 21st march
        self.coordinatePoint.removeAll()
        locationTest = ""
        UserDefaults.standard.removeObject(forKey: "coordinates")
        
        self.locationManager1.stopUpdatingLocation()
    }
    
    @IBOutlet weak var BtnDraw: UIButton!{
        didSet{
            BtnDraw.backgroundColor = UIColor.lightGray
            
        }
    }
    @IBAction func BtnDraw(_ sender: Any) {
        //---added on 21st march, code starts
            let _ =  userDrawablePolygons.map{ $0.map = nil }
            let _ = polygonDeleteMarkers.map{ $0.map = nil}
            polygonDeleteMarkers.removeAll()
            userDrawablePolygons.removeAll()
            cancelDrawingBtn.isHidden = true
            self.coordinates.removeAll() //---added on 21st march
            self.coordinatePoint.removeAll()
            locationTest = ""
            UserDefaults.standard.removeObject(forKey: "coordinates")
        //---added on 21st march, code ends
        
//        self.coordinates.removeAll()
        self.view.addSubview(canvasView)
//        drawBtn.tintColor = UIColor.systemGray
        BtnDraw.backgroundColor = UIColor.green
    }
    
    
    @IBAction func BtnLocation(_ sender: Any) {
        locationManager1 = CLLocationManager()
        locationManager1.delegate = self;
        locationManager1.desiredAccuracy = kCLLocationAccuracyBest
        locationManager1.requestAlwaysAuthorization()
        locationManager1.startUpdatingLocation()
    }
    @IBOutlet weak var cancelDrawingBtn: UIButton!{
        
        didSet{
            
            cancelDrawingBtn.isHidden = true
            let origImage = UIImage(named: "cross-1")
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cancelDrawingBtn.setImage(tintedImage, for: .normal)
            cancelDrawingBtn.tintColor = UIColor.blue
            cancelDrawingBtn.backgroundColor = UIColor.white
            
        }
    }
    
    @IBAction func cancelDrawingActn(_ sender: AnyObject?) {
        
        isDrawingModeEnabled = false
        let _ =  userDrawablePolygons.map{ $0.map = nil }
        let _ = polygonDeleteMarkers.map{ $0.map = nil}
        polygonDeleteMarkers.removeAll()
        userDrawablePolygons.removeAll()
        cancelDrawingBtn.isHidden = true
        self.coordinates.removeAll() //---added on 21st march
        self.coordinatePoint.removeAll()
        locationTest = ""
        UserDefaults.standard.removeObject(forKey: "coordinates")
        
        
    }
    
    @IBOutlet weak var drawBtn: UIButton!{
        didSet{
            let origImage = UIImage(named: "pen")
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            drawBtn.setImage(tintedImage, for: .normal)
            drawBtn.tintColor = UIColor.blue
            drawBtn.backgroundColor = UIColor.white
            
        }
        
    }
    
    @IBAction func drawActn(_ sender: AnyObject?) {
        //---added on 21st march, code starts
            let _ =  userDrawablePolygons.map{ $0.map = nil }
            let _ = polygonDeleteMarkers.map{ $0.map = nil}
            polygonDeleteMarkers.removeAll()
            userDrawablePolygons.removeAll()
            cancelDrawingBtn.isHidden = true
            self.coordinates.removeAll() //---added on 21st march
            self.coordinatePoint.removeAll()
            locationTest = ""
            UserDefaults.standard.removeObject(forKey: "coordinates")
        //---added on 21st march, code ends
        
//        self.coordinates.removeAll()
        self.view.addSubview(canvasView)
        let origImage = UIImage(named: "pen")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        drawBtn.setImage(tintedImage, for: .normal)
        drawBtn.tintColor = UIColor.white
        drawBtn.backgroundColor = UIColor.red
        
    }
    
    lazy var canvasView:CanvasView = {
        
        var overlayView = CanvasView(frame: self.googleMapView.frame)
        overlayView.isUserInteractionEnabled = true
        overlayView.delegate = self
        return overlayView
        
    }()
    
    var isDrawingModeEnabled = false
    var coordinates = [CLLocationCoordinate2D]()
    var coordinatePoint = [CGPoint]()
    var userDrawablePolygons = [GMSPolygon]()
    var polygonDeleteMarkers = [DeleteMarker]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleMapView.delegate = self
        drawBtn.isHidden = true //---added on 22nd march
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:.sendLocation,object:nil, queue:nil) {  notification in
            // Handle notification
            guard let userInfo = notification.userInfo,
                  let currentLocation = userInfo["location"] as? CLLocation else {
                    
                    return
            }
            //---added on 10th march, code starts
            var locManager = CLLocationManager()
            locManager.requestWhenInUseAuthorization()
            
            var currentLocation1: CLLocation!

            if
               CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() ==  .authorizedAlways
            {
                currentLocation1 = locManager.location
            }
            
            print("Latitude-=>",currentLocation.coordinate.latitude)
            print("Longitude-=>",currentLocation.coordinate.longitude)
            
            let marker = GMSMarker()
//                marker.position = CLLocationCoordinate2D(latitude: 22.574094272114884, longitude: 88.43488970437336)
            
            marker.position = CLLocationCoordinate2D(latitude: currentLocation1.coordinate.latitude, longitude: currentLocation1.coordinate.longitude)
            //---added on 10th march code ends
            
            let cameraPos = GMSCameraPosition(target: currentLocation1.coordinate, zoom: 15, bearing: 0, viewingAngle: 0) //----added on 10th march
//            let cameraPos = GMSCameraPosition.camera(withLatitude: 22.574094272114884, longitude: 88.43488970437336, zoom: 15)
//            let cameraPos = GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0) //---commenetd on 10th march
            self.googleMapView.animate(to: cameraPos)
            marker.map = self.googleMapView
            
            
            //---added on 21st March 2023, code starts
           /* let coordinatesDefaults = UserDefaults.standard
            if !coordinatesDefaults.bool(forKey: "SavedCoordinatesStringArray").description.isEmpty {
                let coordinatesArray = coordinatesDefaults.value(forKey: "SavedCoordinatesStringArray") ?? [CLLocationCoordinate2D]()
                self.coordinates = coordinatesArray as! [CLLocationCoordinate2D]
                if self.coordinates.count > 0 {
                    self.createPolygonFromTheDrawablePoints()
                }
            }*/
            self.coordinates = self.loadCoordinates() ?? []
            if self.coordinates.count > 0 {
                self.createPolygonFromTheDrawablePoints()
            }
            
            self.coordinatePoint = self.loadCoordinatesPoint() ?? []
            
            //---added on 21st March 2023, code ends
            
            //---added on 21st March 2023, code starts
            if self.getLiveLocationStatus() == true {
                self.locationManager1 = CLLocationManager()
                self.locationManager1.delegate = self;
                self.locationManager1.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager1.requestAlwaysAuthorization()
                self.locationManager1.startUpdatingLocation()
            }
            //---added on 21st March 2023, code ends
        }
        searchVc.searchResultsUpdater = self
        searchVc.searchBar.searchTextField.backgroundColor = UIColor.white
        navigationItem.searchController = searchVc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.removeObserver(self, name: .sendLocation, object: nil)
        
    }
    
    //---function to store/retrieve liveLocation status, code starts
    func storeLiveLocationStatus(status: Bool){
        
        UserDefaults.standard.set(status, forKey: "LiveLocationStatus")
        UserDefaults.standard.synchronize()
    }
    
    func getLiveLocationStatus() -> Bool {
        
        guard let status = UserDefaults.standard.object(forKey: "LiveLocationStatus") as? Bool else {
            return false
        }
        return status
    }
    //---function to store/retrieve liveLocation status, code ends
    
    // Store an array of CLLocationCoordinate2D
    func storeCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        let locations = coordinates.map { coordinate -> CLLocation in
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        let archived = NSKeyedArchiver.archivedData(withRootObject: locations)
        UserDefaults.standard.set(archived, forKey: "coordinates")
        UserDefaults.standard.synchronize()
    }

    // Return an array of CGPoint
    func loadCoordinatesPoint() -> [CGPoint]? {
        guard let archived = UserDefaults.standard.object(forKey: "coordinates") as? Data,
            let locations = NSKeyedUnarchiver.unarchiveObject(with: archived) as? [CLLocation] else {
                return nil
        }

        let coordinates = locations.map { location -> CGPoint in
            return CGPointMake(location.coordinate.latitude, location.coordinate.longitude)
        }

        return coordinates
    }
    
    // Return an array of CLLocationCoordinate2D
    func loadCoordinates() -> [CLLocationCoordinate2D]? {
        guard let archived = UserDefaults.standard.object(forKey: "coordinates") as? Data,
            let locations = NSKeyedUnarchiver.unarchiveObject(with: archived) as? [CLLocation] else {
                return nil
        }

        let coordinates = locations.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }

        return coordinates
    }
    
    
    func createPolygonFromTheDrawablePoints(){
        
        let numberOfPoints = self.coordinates.count
        //do not draw in mapview a single point
        if numberOfPoints > 2 { addPolyGonInMapView(drawableLoc: coordinates) }//neglects a single touch
        coordinates = []
        self.canvasView.image = nil
        self.canvasView.removeFromSuperview()
        
        let origImage = UIImage(named: "pen")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        drawBtn.setImage(tintedImage, for: .normal)
        drawBtn.tintColor = UIColor.red
        drawBtn.backgroundColor = UIColor.white
        BtnDraw.backgroundColor = UIColor.lightGray
        
    }
    
    func  addPolyGonInMapView( drawableLoc:[CLLocationCoordinate2D]){
        
        isDrawingModeEnabled = true
        let path = GMSMutablePath()
        for loc in drawableLoc{
            
            path.add(loc)
            
        }
        let newpolygon = GMSPolygon(path: path)
        newpolygon.strokeWidth = 3
        newpolygon.strokeColor = UIColor.black
        newpolygon.fillColor = UIColor.black.withAlphaComponent(0.5)
        newpolygon.map = googleMapView
//        if cancelDrawingBtn.isHidden == true{ cancelDrawingBtn.isHidden = false } //---commented on 23rd march
        userDrawablePolygons.append(newpolygon)
//        addPolygonDeleteAnnotation(endCoordinate: drawableLoc.last!,polygon: newpolygon)
    }
    
    func addPolygonDeleteAnnotation(endCoordinate location:CLLocationCoordinate2D,polygon:GMSPolygon){
        
        let marker = DeleteMarker(location: location,polygon: polygon)
        let deletePolygonView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deletePolygonView.layer.cornerRadius = 15
        deletePolygonView.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.center = deletePolygonView.center
        imageView.image = UIImage(named: "delete")
        deletePolygonView.addSubview(imageView)
        marker.iconView = deletePolygonView
        marker.map = googleMapView
        polygonDeleteMarkers.append(marker)
    }
    
    
    @IBAction func BtnGetLocation(_ sender: Any) {
        locationManager1 = CLLocationManager()
        locationManager1.delegate = self;
        locationManager1.desiredAccuracy = kCLLocationAccuracyBest
        locationManager1.requestAlwaysAuthorization()
        locationManager1.startUpdatingLocation()
        
        
//        self.view.makeToast("\(String(describing: locationTest))", duration: 3.0, position: .bottom)
        
    }
    var locationTest = ""
    let synthesizer = AVSpeechSynthesizer()
    var isCheckedIn: Bool = false
    var message: String = ""
    let DestinationMarker = GMSMarker()
    var cirlce = GMSCircle()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //----show current location updates, code starts

        if let location = locations.last{
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            
            
           /* self.DestinationMarker.map?.clear()
            DestinationMarker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            DestinationMarker.map = self.googleMapView */
//            cirlce = GMSCircle(position: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: 10)
//            cirlce.map?.clear()
//            cirlce.fillColor = UIColor.red.withAlphaComponent(0.5)
            DestinationMarker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            DestinationMarker.map = self.googleMapView
            
           /* cirlce = GMSCircle(position: camera.target, radius: 100000)
                    cirlce.fillColor = UIColor.redColor().colorWithAlphaComponent(0.5)
                    cirlce.map = mapView*/
            }
        //---show current location, code ends
        
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        var checkCoordinatePoint = containsPointInsidePolygon(polygon: coordinatePoint, test: CGPointMake(locValue.latitude, locValue.longitude))
        print("Coordinate Test-=>", checkCoordinatePoint)
//        locationTest?.append("\(String(CGPointMake(locValue.latitude, locValue.longitude)))")
//        locationTest?.append("Latitude:\(String(locValue.latitude)) || Longitude:\(String() \n")
        var lat : String = locValue.latitude.description
        var lng : String = locValue.longitude.description
        
        print("LocationTest-=>\(locationTest)")
        if checkCoordinatePoint == true{
            
            locationTest.append("Latitude: \(lat) , Longitude: \(lng) => In Range: True\n")
            
            if isCheckedIn == false {
                isCheckedIn = true
                message = "You are checked in"
            }else if isCheckedIn == true {
                isCheckedIn = false
                message = "You are checked out"
            }
            
            self.view.makeToast(message, duration: 3.0, position: .top)
            let utterance = AVSpeechUtterance(string: message)
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//            AVSpeechSynthesisVoiceGender.female
//            utterance.rate = 0.1
            
            synthesizer.speak(utterance)
            
        }else if checkCoordinatePoint == false {
        
            self.view.makeToast("Not in range", duration: 3.0, position: .top)
            locationTest.append("Latitude: \(lat) , Longitude: \(lng) => In Range: False\n")
            
            let string = "You are not in range"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
        
       /* let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        marker.map = self.googleMapView*/
        
//        locationManager1.stopUpdatingLocation()
        if getLiveLocationStatus() == false {
            locationManager1.stopUpdatingLocation()
        }
        
    }
    
    //---added on 14th march 2023, code starts
    func containsPointInsidePolygon(polygon: [CGPoint], test: CGPoint) -> Bool {
        if polygon.count <= 1 {
            return false //or if first point = test -> return true
        }
        let p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        p.move(to: firstPoint)
        for index in 1...polygon.count-1 {
            p.addLine(to: polygon[index] as CGPoint)
        }
        p.close()
        return p.contains(test)
    }
    
    
    //---added on 14th march 2023, code ends
    
    @IBAction func BtnLocationSettings(_ sender: Any) {
        openLiveLocationSettingsPopup()
    }
    
    @IBAction func BtnLiveLocationSettings(_ sender: Any) {
        openLiveLocationSettingsPopup()
    }
    
    //==============////--LiveLocationDialog code starts--/////================
    @IBOutlet var viewLiveLocationSettingsPopup: UIView!
    
    func openLiveLocationSettingsPopup(){
        
        if getLiveLocationStatus() == true {
            BtnLiveLocationSwitch.isOn = true
        }
        blurEffect()
        self.view.addSubview(viewLiveLocationSettingsPopup)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewLiveLocationSettingsPopup.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewLiveLocationSettingsPopup.center = self.view.center
        viewLiveLocationSettingsPopup.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewLiveLocationSettingsPopup.alpha = 0
        viewLiveLocationSettingsPopup.sizeToFit()
        
        UIView.animate(withDuration: 0.3){
            self.viewLiveLocationSettingsPopup.alpha = 1
            self.viewLiveLocationSettingsPopup.transform = CGAffineTransform.identity
        }
    }
    func cancelLiveLocationSettingsPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLiveLocationSettingsPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewLiveLocationSettingsPopup.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewLiveLocationSettingsPopup.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    @IBOutlet weak var BtnLiveLocationSwitch: UISwitch!
    
    @IBAction func BtnLiveLocationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            print("True")
            storeLiveLocationStatus(status: true)
            locationManager1.startUpdatingLocation()
        }else{
            print("False")
            storeLiveLocationStatus(status: false)
            locationManager1.stopUpdatingLocation()
        }
    }
    
    
    @IBAction func BtnLiveLocationClose(_ sender: Any) {
        cancelLiveLocationSettingsPopup()
    }
    //==============////--LiveLocationDialog code ends--/////================
    
    
    // ====================== Blur Effect Defiend START ================= \\
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var blurEffectView: UIVisualEffectView!
    var loader: UIVisualEffectView!
    func loaderStart() {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        loader = UIVisualEffectView(effect: blurEffect)
        loader.frame = view.bounds
        loader.alpha = 2
        view.addSubview(loader)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.white
        loadingIndicator.startAnimating();
        loader.contentView.addSubview(loadingIndicator)
        
        // screen roted and size resize automatic
        loader.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
    }
    
    func loaderEnd() {
        self.loader.removeFromSuperview();
    }
    // ====================== Blur Effect Defiend END ================= \\
    
    // ====================== Blur Effect START ================= \\
    func blurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.9
        view.addSubview(blurEffectView)
//        ScrollView.addSubview(blurEffectView)
        // screen roted and size resize automatic
        blurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
    }
    func canelBlurEffect() {
        self.blurEffectView.removeFromSuperview();
    }
    // ====================== Blur Effect END ================= \\
}

//MARK: MAPVIEW DELEGATE METHODS
extension ViewController:GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        //do not accept touch of current location marker
        if let deletemarker = marker as? DeleteMarker{
            
            if let index = userDrawablePolygons.index(of: deletemarker.drawPolygon){
                
                userDrawablePolygons.remove(at: index)
                
            }
            if let  indexToRemove =  polygonDeleteMarkers.index(of: deletemarker){
                
                polygonDeleteMarkers.remove(at: indexToRemove)
                
            }
            
            deletemarker.drawPolygon.map = nil
            deletemarker.map = nil
            if userDrawablePolygons.count == 0{ cancelDrawingActn(nil) }
            return true
        }
        return false
    }
}

//MARK: GET DRAWABLE COORDINATES
extension ViewController:NotifyTouchEvents{
    
    func touchBegan(touch:UITouch){
        
        let location = touch.location(in: self.googleMapView)
        let coordinate = self.googleMapView.projection.coordinate(for: location)
        print("CoordinateBegan-=>", coordinate)
        self.coordinates.append(coordinate)
        self.coordinatePoint.append(CGPointMake(coordinate.latitude, coordinate.longitude)) //---added on 14th March 2023
        
    }
    
    func touchMoved(touch:UITouch){
        
        let location = touch.location(in: self.googleMapView)
        let coordinate = self.googleMapView.projection.coordinate(for: location)
        print("CoordinateMoved-=>", coordinate)
        self.coordinates.append(coordinate)
        self.coordinatePoint.append(CGPointMake(coordinate.latitude, coordinate.longitude)) //---added on 14th March 2023
        
    }
    
    func touchEnded(touch:UITouch){
        
        let location = touch.location(in: self.googleMapView)
        let coordinate = self.googleMapView.projection.coordinate(for: location)
        print("CoordinateEnded-=>", coordinate)
        self.coordinates.append(coordinate)
        self.coordinatePoint.append(CGPointMake(coordinate.latitude, coordinate.longitude)) //---added on 14th March 2023
        
        
        //----code to save in userdefault, starts
        storeCoordinates(coordinates)
        
        let coordinatePointDefaults = UserDefaults.standard
        let coordinatesPointArrayToString = coordinatePoint.description
        coordinatePointDefaults.set(coordinatesPointArrayToString, forKey: "SavedcoordinatePointStringArray")
        //----code to save in userdefault, ends
        
        
        createPolygonFromTheDrawablePoints()
    }
};

extension ViewController: ResultsViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVc.searchBar.resignFirstResponder()
        searchVc.dismiss(animated: true, completion: nil)
        //---Remove all map pins
        
        //---Add a map pin
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let cameraPos = GMSCameraPosition(target: coordinates, zoom: 15, bearing: 0, viewingAngle: 0) //----added on 10th march
//            let cameraPos = GMSCameraPosition.camera(withLatitude: 22.574094272114884, longitude: 88.43488970437336, zoom: 15)
//            let cameraPos = GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0) //---commenetd on 10th march
        self.googleMapView.animate(to: cameraPos)
        marker.map = self.googleMapView
    }
}

