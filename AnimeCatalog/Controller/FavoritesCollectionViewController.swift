//
//  CollectionVIewController.swift
//  Target 1
//
//  Created by Laércio Andrade Guimarães on 13/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import UIKit

class FavoritesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
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
        hideMessage()
        self.animeList = FavoritesManager.favoriteAnimes()
        if self.animeList.isEmpty {
            showMessage(message: "There's nothing here.\n\n(っ- ‸ – ς)", progress: false)
        }
        self.collectionView?.reloadData()
    }
    
    func showMessage(message: String, progress: Bool) {
        self.messageLabel.isHidden = false
        self.messageLabel.text = message
        self.progressIndicator.startAnimating()
        self.progressIndicator.isHidden = !progress
    }
    
    func hideMessage() {
        self.messageLabel.isHidden = true
        self.progressIndicator.stopAnimating()
        self.progressIndicator.isHidden = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimeCell", for: indexPath) as! AnimeCollectionItem
        let i = indexPath.item
        cell.animeTitle.text = animeList[i].titleRomaji
        cell.image.image = nil
        self.loadImage(imageUrl: animeList[i].imageUrlLge, imageView: cell.image, progressIndicator: cell.progressIndicator)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

    func loadImage(imageUrl: URL, imageView: UIImageView, progressIndicator: UIActivityIndicatorView) {
        progressIndicator.hidesWhenStopped = true
        progressIndicator.startAnimating()
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if let data = data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    progressIndicator.stopAnimating()
                    imageView.image = image
                }
            } else {
                progressIndicator.stopAnimating()
                print("Something went wrong while loading the image")
            }
            }.resume()
    }
}

