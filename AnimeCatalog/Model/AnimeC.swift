//
//  AnimeC.swift
//  AnimeCatalog
//
//  Created by Laércio Andrade Guimarães on 19/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import Foundation

struct AnimeC: Codable {
    let id: Int
    let titleRomaji: String
    let titleEnglish: String
    let titleJapanese: String
    let averageScore: Int
    let youtubeId: String?
    let description: String
    let imageUrlLge: URL
    
    enum CodingKeys : String, CodingKey {
        case id
        case titleRomaji = "title_romaji"
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case averageScore =  "average_score"
        case description
        case youtubeId = "youtube_id"
        case imageUrlLge = "image_url_lge"
    }
    
    func sanitizedDescription() -> String {
        return description.replacingOccurrences(of: "<br>", with: "").replacingOccurrences(of: "</br>", with: "")
    }
}
