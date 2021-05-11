//
//  UrbanAreaInfo.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/11/21.
//

import UIKit

class UrbanArea: NSObject, Decodable {
    var categories: [UrbanAreaData]?
    
    private enum CodingKeys: String, CodingKey {
        case categories
    }
}
