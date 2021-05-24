//
//  UrbanAreaData.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 5/11/21.
//

import UIKit

class UrbanAreaData: NSObject, Decodable {
    var publicTransportCost: Float?
    var mealCost: Float?
    var fitnessCost: Float?
    var movieCost: Float?
    
    private enum RootKeys: String, CodingKey {
        case data
        case id
        case label
    }
    
    private struct DataKeys: Decodable {
        var currency_dollar_value: Float
        var id: String
        var label: String
        var type: String
    }
    
    required init(from decoder: Decoder) throws {
        // Get root container
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        let dataList = try rootContainer.decode([FailableDecodable<DataKeys>].self, forKey: .data).compactMap( {$0.base} )
        
        for data in dataList {
            if data.label == "Monthly public transport" {
                publicTransportCost = data.currency_dollar_value
            }
            else if data.label == "Lunch" {
                mealCost = data.currency_dollar_value
            }
            else if data.label == "Monthly fitness club membership" {
                fitnessCost = data.currency_dollar_value
            }
            else if data.label == "Movie ticket" {
                movieCost = data.currency_dollar_value
            }
        }
    }
}

struct FailableDecodable<Base : Decodable> : Decodable {
    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
