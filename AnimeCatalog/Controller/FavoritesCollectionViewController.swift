//
//  CollectionVIewController.swift
//  Target 1
//
//  Created by Laércio Andrade Guimarães on 13/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import UIKit

class FavoritesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let numberOfCellsPerRow: CGFloat = 2.0
    let cellMargin: CGFloat = 8.0
    let cellAspectRatio: CGFloat = 1.55
    var animeList = [Anime]()
    
    lazy var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    func loadFavorites() {
        self.animeList = FavoritesManager.favoriteAnimes()
        self.collectionView?.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimeCell", for: indexPath) as! AnimeCollectionItem
        let i = indexPath.item
        cell.animeTitle.text = animeList[i].titleRomaji
        cell.image.image = nil
        self.loadImage(imageUrl: animeList[i].imageUrlLge, imageView: cell.image, progressIndicator: cell.progressIndicator)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (numberOfCellsPerRow + 1) * cellMargin)/numberOfCellsPerRow
        let height = width * (cellAspectRatio)
        
        return CGSize(width: width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! AnimeCollectionItem
        if let i = self.collectionView?.indexPath(for: cell)?.item{
            if let animeDetailViewController = segue.destination as? AnimeDetailViewController {
                animeDetailViewController.anime = animeList[i]
            }
        }
    }
    
    func loadAnime(completion: @escaping ([Anime]) -> ()) {
        let browseURL = "https://anilist.herokuapp.com/animes/"
        if let url = URL(string: browseURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let responseData = data {
                    let decoder = JSONDecoder()
                    do {
                        let animes = try decoder.decode([Anime].self, from: responseData)
                        completion(animes)
                    } catch {
                        print("Houve um erro ao decodificar o JSON")
                    }
                } else {
                    print("Houve um problema ao carregar os dados")
                }
                }.resume()
        } else {
            print("URL mal formada")
        }
    }
    
    func loadImage(imageUrl: URL, imageView: UIImageView, progressIndicator: UIActivityIndicatorView) {
        progressIndicator.startAnimating()
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    progressIndicator.stopAnimating()
                    imageView.image = image
                }
            } else {
                print("Houve um problema ao carregar a imagem")
            }
            }.resume()
    }
}

