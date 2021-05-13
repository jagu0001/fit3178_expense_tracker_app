//
//  CityData.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/13/21.
//

import Foundation

struct RootCityData: Codable {
    let embedded: Embedded
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct Embedded: Codable {
    let nearestUrbanAreas: [NearestUrbanAreas]
    
    enum CodingKeys: String, CodingKey {
        case nearestUrbanAreas = "location:nearest-urban-areas"
    }
}

struct NearestUrbanAreas: Codable {
    let links: NearestUrbanAreasLink
    
    enum CodingKeys: String, CodingKey {
        case links = "_links"
    }
}

struct NearestUrbanAreasLink: Codable {
    let nearestUrbanArea: NearestUrbanArea
    
    enum CodingKeys: String, CodingKey {
        case nearestUrbanArea = "location:nearest-urban-area"
    }
}

struct NearestUrbanArea: Codable {
    let href: String
    let name: String
}

extension RootCityData {
    init(data: Data) throws {
        self = try JSONDecoder().decode(RootCityData.self, from: data)
    }
}
