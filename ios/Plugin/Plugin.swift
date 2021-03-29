import Foundation
import Capacitor

import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

struct Location {
    var longtitude = 0
    var latitude = 0
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorMapboxNavigation)
public class CapacitorMapboxNavigation: CAPPlugin {
    

    @objc func echo(_ call: CAPPluginCall) {
        
        let value = call.getString("value") ?? ""
       
        call.success([
            "value": value
        ])
    }
    
    @objc func show (_ call: CAPPluginCall) {
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
        
        TopBannerView.appearance().isHidden = true;
        BottomBannerView.appearance().isHidden = true;
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

        TopBannerView.appearance().backgroundColor = .red;
        TopBannerView.appearance().isHidden = true;
        BottomBannerView.appearance().isHidden = true;
        BottomBannerView.appearance().backgroundColor = .red;
        
        InstructionsBannerView.appearance().backgroundColor = .red;
        InstructionsBannerView.appearance().isHidden = false;
    }
}
