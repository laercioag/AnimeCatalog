//
//  FavoritesManager.swift
//  Target 1
//
//  Created by Laércio Andrade Guimarães on 19/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import Foundation

class FavoritesManager {
    
    static let favoritesKey = "favoriteAnimes"
    
    static func saveAnimeToFavorites(anime: Anime) {
        var favoriteAnimes = self.favoriteAnimes()
        favoriteAnimes.append(anime)
        
        let encoder = JSONEncoder()
        if let encodedAnime = try? encoder.encode(favoriteAnimes) {
            UserDefaults.standard.set(encodedAnime, forKey: favoritesKey)
        }
    }
    
    static func removeAnimeFromFavorites(anime: Anime) {
        let favoriteAnimes = self.favoriteAnimes()
        
        var favoriteAnimesSet = Set(favoriteAnimes)
        favoriteAnimesSet.remove(anime)

        let encoder = JSONEncoder()
        if let encodedAnime = try? encoder.encode(favoriteAnimesSet) {
            UserDefaults.standard.set(encodedAnime, forKey: favoritesKey)
        }
    }
    
    static func contains(anime: Anime) ->Bool {
        let favoriteAnimes = self.favoriteAnimes()
        
        let favoriteAnimesSet = Set(favoriteAnimes)
        return favoriteAnimesSet.contains(anime)
    }
    
    static func favoriteAnimes() -> [Anime] {
        let decoder = JSONDecoder()
        
        if let econdedAnimes = UserDefaults.standard.data(forKey: favoritesKey),
            let animes = try? decoder.decode([Anime].self, from: econdedAnimes) {
            return animes
        } else {
            return []
        }
    }
}
