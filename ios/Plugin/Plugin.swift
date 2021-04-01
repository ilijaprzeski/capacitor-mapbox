import Foundation
import Capacitor

import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

struct Location: Codable {
    var longtitude: Double = 0.0
    var latitude: Double = 0.0
}

var lastLocation: Location?;
var locationHistory: NSMutableArray?;

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorMapboxNavigation)
public class CapacitorMapboxNavigation: CAPPlugin {
   
    @objc override public func load() {
        // Called when the plugin is first constructed in the bridge
        locationHistory = NSMutableArray();
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange(notification:)), name: .routeControllerProgressDidChange, object: nil)
    }
    
    @objc func progressDidChange(notification: NSNotification) {
        let location = notification.userInfo![RouteController.NotificationUserInfoKey.locationKey] as! CLLocation
        lastLocation?.latitude = location.coordinate.latitude;
        lastLocation?.longtitude = location.coordinate.longitude;
        locationHistory?.add(Location(longtitude: location.coordinate.longitude, latitude: location.coordinate.latitude));
        emitLocationUpdatedEvent();
    }
    
    func emitLocationUpdatedEvent() {
        let jsonEncoder = JSONEncoder()
        do {
            let swiftArray = locationHistory as AnyObject as! [Location]
            let locationHistoryJsonData = try jsonEncoder.encode(swiftArray)
            let locationHistoryJson = String(data: locationHistoryJsonData, encoding: String.Encoding.utf8) ?? ""
            
            self.bridge.triggerWindowJSEvent(eventName: "location_updated", data: locationHistoryJson)
            
        } catch {
            print("Error: Json Parsing Error");
        }
    }

    @objc func echo(_ call: CAPPluginCall) {
        
        let value = call.getString("value") ?? ""
       
        call.success([
            "value": value
        ])
    }
    
    @objc func history(_ call: CAPPluginCall) {
        let jsonEncoder = JSONEncoder()
        do {
            let lastLocationJsonData = try jsonEncoder.encode(lastLocation)
            let lastLocationJson = String(data: lastLocationJsonData, encoding: String.Encoding.utf8)
            
            let swiftArray = locationHistory as AnyObject as! [Location]
            let locationHistoryJsonData = try jsonEncoder.encode(swiftArray)
            let locationHistoryJson = String(data: locationHistoryJsonData, encoding: String.Encoding.utf8)
            
            call.success([
                "lastLocation": lastLocationJson ?? "",
                "locationHistory": locationHistoryJson ?? ""
            ])
        } catch {
            call.error("Error: Json Encoding Error")
        }
    }
    
    @objc func show (_ call: CAPPluginCall) {
        lastLocation = Location(longtitude: 0.0, latitude: 0.0);
        locationHistory?.removeAllObjects()
        
        let routes = call.getArray("routes", NSDictionary.self) ?? [NSDictionary]()
        for route in routes {
            guard (route["longtitude"] != nil && route["latitude"] != nil) else {
                call.error("Wrong format location.")
                return ;
            }
        }
        
        let mapType = call.getString("mapType") ?? "mapbox://styles/mapbox/satellite-streets-v9"
        
        var coordinates = [CLLocationCoordinate2D]();
        for route in routes {
            coordinates.append(CLLocationCoordinate2DMake(route["latitude"] as! CLLocationDegrees, route["longtitude"] as! CLLocationDegrees))
        }
        
        let routeOptions = NavigationRouteOptions(coordinates: coordinates)
         
        // Request a route using MapboxDirections.swift
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let response):
                    guard let route = response.routes?.first else {
                        return
                    }
                    
                    let topBanner = CustomTopBarViewController()
//                    let bottomBanner = CustomBottomBarViewController()
                    let navigationService = MapboxNavigationService(route: route, routeIndex: 0, routeOptions: routeOptions, simulating: .always)
                    let navigationOptions = NavigationOptions(styles: [CustomDayStyle(mapType: mapType), CustomNightStyle(mapType: mapType)], navigationService: navigationService, topBanner: topBanner)
                    
                    let viewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: routeOptions, navigationOptions: navigationOptions)
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.waypointStyle = .extrudedBuilding;
                    DispatchQueue.main.async {
                        self?.setCenteredPopover(viewController)
                        self?.bridge.viewController.present(viewController, animated: true, completion: nil)
                    }
            }
        }
        
        call.success()
    }
}

extension NavigationViewController {
    
}

class CustomDayStyle: DayStyle {
    required init(mapType: String) {
        super.init()
        mapStyleURL = URL(string: mapType)!
        styleType = .day
    }
    
    required init() {
        super.init()
        mapStyleURL = URL(string: "mapbox://styles/mapbox/satellite-streets-v9")!
        styleType = .day
    }
    
    override func apply() {
        super.apply()
    }
}

class CustomNightStyle: NightStyle {
    required init(mapType: String) {
        super.init()
        mapStyleURL = URL(string: mapType)!
        styleType = .night
    }
    
    required init() {
        super.init()
        mapStyleURL = URL(string: "mapbox://styles/mapbox/satellite-streets-v9")!
        styleType = .night
    }
     
    override func apply() {
        super.apply()
    }
}
