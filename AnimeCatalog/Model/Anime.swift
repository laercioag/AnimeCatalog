//
//  Anime.swift
//  AnimeCatalog
//
//  Created by Laércio Andrade Guimarães on 19/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import Foundation

struct Anime: Codable, Hashable {
    let id: Int
    let titleRomaji: String
    let titleEnglish: String
    let titleJapanese: String
    let imageUrlLge: URL
    var isFavorite: Bool = false
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func ==(lhs: Anime, rhs: Anime) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case titleRomaji = "title_romaji"
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case imageUrlLge = "image_url_lge"
    }
}
