//
//  ResponseModels.swift
//  OrderApp
//
//  Created by habiba abdeldayem on 09/08/2023.
//

import Foundation

struct MenuResponse: Codable {
    let items: [MenuItem]
}

struct CategoriesResponse: Codable {
    let categories: [String]
}

struct OrderResponse: Codable {
    let prepTime: Int

    enum CodingKeys: String, CodingKey {
        // to stick with naming conventions of swift
        case prepTime = "preparation_time"
    }
}

