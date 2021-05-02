//
//  Bill.swift
//  FIT3178-Assignment-Bill-Tracking-App
//
//  Created by user190204 on 4/27/21.
//

import UIKit

class Bill: NSObject {
    var biller: String
    var tag: String
    var amount: Float
    var billDescription: String
    var dueBy: String
    
    init(biller: String, tag: String, amount: Float, description: String, dueBy: String) {
        self.biller = biller
        self.tag = tag
        self.amount = amount
        billDescription = description
        self.dueBy = dueBy
    }
}
