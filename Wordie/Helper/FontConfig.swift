//
//  FontConfig.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/12.
//

import Foundation

struct FontConfig: Codable {
    
    let font: FontDetails
    
    enum CodingKeys: String, CodingKey {
        case font = "Font"
    }
}

struct FontDetails: Codable {
    
    let english: FontDetail
    let phonetic: FontDetail
    let chinese: FontDetail
}

struct FontDetail: Codable {
    
    let name: String?
    let ttf: String?
    let size: CGFloat?
}
