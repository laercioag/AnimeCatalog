//
//  ViewController.swift
//  AnimeCatalgog
//
//  Created by Laércio Andrade Guimarães on 11/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import UIKit
import WebKit

class AnimeDetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var englishTitle: UILabel!
    @IBOutlet weak var romajiTitle: UILabel!
    @IBOutlet weak var japaneseTitle: UILabel!
    @IBOutlet weak var longDescription: UITextView!
    @IBOutlet weak var averageScore: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var youtubePlayer: UIWebView!
    
    
    var anime: Anime?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if var anime = anime {
            anime.isFavorite = FavoritesManager.contains(anime: anime)
            showFavoriteButton(isFavorite: anime.isFavorite)
            self.progressIndicator.startAnimating()
            
            loadAnime(animeId: String(anime.id), completion: {(anime) -> Void in
                DispatchQueue.main.async {
                    self.averageScore.text = String(anime.averageScore)
                    self.longDescription.text = anime.sanitizedDescription()
                    self.progressIndicator.stopAnimating()
                    self.loadImage(imageUrl: anime.imageUrlLge, imageView: self.cover)
                    if let youtubeId = anime.youtubeId {
                        self.loadVideo(webview: self.youtubePlayer, youtubeId: youtubeId)
                    } else {
                        self.youtubePlayer.removeFromSuperview()
                    }
                }
            })
            self.englishTitle.text = anime.titleEnglish
            self.romajiTitle.text = anime.titleRomaji
            self.japaneseTitle.text = anime.titleJapanese
        }
        progressIndicator.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showFavoriteButton(isFavorite: Bool) {
        if !isFavorite {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.addToFavorites))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(self.removeFromFavorites))
        }
    }
    
    @objc func addToFavorites() {
        if var anime = anime {
            anime.isFavorite = true
            FavoritesManager.saveAnimeToFavorites(anime: anime)
            showFavoriteButton(isFavorite: anime.isFavorite)
        }
    }
 
    @objc func removeFromFavorites() {
        if var anime = anime {
            anime.isFavorite = false
            FavoritesManager.removeAnimeFromFavorites(anime: anime)
            showFavoriteButton(isFavorite: anime.isFavorite)
        }
    }
    
    
    func loadAnime(animeId: String, completion: @escaping (AnimeC) -> ()) {
        let animeUrl = "https://anilist.herokuapp.com/anime/\(animeId)"
        guard let url = URL(string: animeUrl) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let responseData = data {
                let decoder = JSONDecoder()
                do {
                    let anime = try decoder.decode(AnimeC.self, from: responseData)
                    completion(anime)
                } catch let jsonError {
                    print(jsonError)
                    print("Houve um erro ao decodificar o JSON")
                }
            } else {
                print("Houve um problema ao carregar os dados")
            }
        }.resume()
    }
    
    func loadImage(imageUrl: URL, imageView: UIImageView) {
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                print("Houve um problema ao carregar a imagem")
            }
            }.resume()
    }
    
    func loadVideo(webview: UIWebView, youtubeId: String) {
        webview.scrollView.isScrollEnabled = false
        webview.loadHTMLString("<iframe width=\"\(webview.frame.width)\" height=\"\(webview.frame.height)\" src=\"https://www.youtube.com/embed/\(youtubeId)?rel=0\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.body.style.margin='0';document.body.style.padding = '0'")
    }
}

