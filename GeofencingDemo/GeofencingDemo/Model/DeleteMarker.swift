//
//  DeleteMarker.swift
//  GeofencingDemo
//
//  Created by Debashis Pal on 13/03/23.
//

import Foundation
import GoogleMaps

class DeleteMarker: GMSMarker {
    
    var drawPolygon:GMSPolygon
    var markers:[GMSMarker]?
    
    init(location:CLLocationCoordinate2D,polygon:GMSPolygon) {
        
        
        self.drawPolygon = polygon
        super.init()
        super.position = location
        
    }
    
}
