//
//  MenuController.swift
//  OrderApp
//
//  Created by habiba abdeldayem on 09/08/2023.
//

import Foundation
import UIKit

class MenuController {
    static let shared = MenuController() // like URLSession singleton
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    
    
    let baseURL = URL(string: "http://localhost:8080/")!
    typealias MinutesToPrepare = Int
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound
        case menuItemsNotFound
        case orderRequestFailed
        case imageDataMissing
        
    }
    
    func fetchCategories() async throws -> [String] {
        let categoriesURL = baseURL.appendingPathComponent("categories")
        let (data, response) = try await URLSession.shared.data(from:categoriesURL)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.categoriesNotFound
        }
        
        let decoder = JSONDecoder()
        let categoriesResponse = try decoder.decode(CategoriesResponse.self, from: data)
        
        return categoriesResponse.categories
        
        
    }
    
    func fetchMenuItems(forCategory categoryName: String) async throws ->[MenuItem] {
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: initialMenuURL,resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = components.url!
        let (data, response) = try await URLSession.shared.data(from: menuURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 else {
            throw MenuControllerError.menuItemsNotFound
        }
        
        let decoder = JSONDecoder()
        let menuResponse = try decoder.decode(MenuResponse.self, from: data)
        
        return menuResponse.items
        
    
    }
    
    // “Unlike a GET, which appends query parameters to the URL, the data for a POST must be stored within the body of the request”
    
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        let orderURL = baseURL.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type") // “ you'll tell the server you'll be sending JSON data.
        let menuIdsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIdsDict)
        
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        
        let decoder = JSONDecoder()
        let orderResponse = try decoder.decode(OrderResponse.self, from: data)
        
        return orderResponse.prepTime
       
        
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
    
        guard let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }
    
        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDataMissing
        }
    
        return image
    }
    
}


