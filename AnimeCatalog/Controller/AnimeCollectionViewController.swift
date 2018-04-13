//
//  CollectionVIewController.swift
//  Target 1
//
//  Created by Laércio Andrade Guimarães on 13/11/17.
//  Copyright © 2017 Laércio Andrade Guimarães. All rights reserved.
//

import UIKit

class AnimeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    let numberOfCellsPerRow: CGFloat = 2.0
    let cellMargin: CGFloat = 8.0
    let cellAspectRatio: CGFloat = 1.55
    var animeList = [Anime]()
    
    lazy var searchBar = UISearchBar()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        self.collectionView.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.loadAnimes), for: .valueChanged)
        self.showSearchButton()
        self.showMessage(message: "Loading...\n\n(ﾉ^ヮ^)ﾉ*:・ﾟ✧", progress: true)
        self.loadAnimes()
    }
    
    @objc func loadAnimes() {
        self.loadAnime(completion: { (animes) -> Void in
            DispatchQueue.main.async {
                if animes.isEmpty {
                    self.showMessage(message: "We couldn't find anything...\n\n(⌯˃̶᷄ ﹏ ˂̶᷄⌯)", progress: false)
                }
                self.hideMessage()
                self.animeList = animes
                self.refreshControl.endRefreshing()
                self.collectionView?.reloadData()
            }
        })
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
    
    func showSearchButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(AnimeCollectionViewController.setupSearchBar))
    }
    
    func hideSearchButton() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @objc func setupSearchBar() {
        self.hideSearchButton()
        self.searchBar.sizeToFit()
        self.searchBar.placeholder = "Search..."
        self.searchBar.showsCancelButton = true
        self.navigationItem.titleView = searchBar
        self.searchBar.delegate = self
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.navigationItem.titleView = nil
        if let query = searchBar.text {
            animeList = []
            self.collectionView?.reloadData()
            self.showMessage(message: "Hang on, we're looking for it...!\n\no(^∀^*)o", progress: true)
            self.searchAnime(query: query) { (animes) in
                self.animeList = animes
                DispatchQueue.main.async {
                    if animes.isEmpty {
                        self.showMessage(message: "We couldn't find anything...\n\n(⌯˃̶᷄ ﹏ ˂̶᷄⌯)", progress: false)
                    }
                    self.collectionView?.reloadData()
                    self.hideMessage()
                }
            }
        }
        self.searchBar.text = nil
        self.showSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = nil
        self.searchBar.endEditing(true)
        self.navigationItem.titleView = nil
        self.showSearchButton()
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
                        print("Couldn't decode data to JSON")
                    }
                } else {
                    completion([])
                    print("Something went wrong while requesting the data")
                    self.showMessage(message: "Something went wrong...\n\n( ⚆ _ ⚆ )", progress: false)
                }
            }.resume()
        } else {
            completion([])
            print("Malformed URL")
        }
    }
    
    func searchAnime(query: String, completion: @escaping ([Anime]) -> ()) {
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let browseURL = "https://anilist.herokuapp.com/pesquisa/\(escapedQuery!)"
        if let url = URL(string: browseURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let responseData = data {
                    let decoder = JSONDecoder()
                    do {
                        let animes = try decoder.decode([Anime].self, from: responseData)
                        completion(animes)
                    } catch {
                        completion([])
                        print("Couldn't decode data to JSON")
                    }
                } else {
                    completion([])
                    print("Something went wrong while requesting the data")
                    self.showMessage(message: "Something went wrong...\n\n( ⚆ _ ⚆ )", progress: false)
                }
                }.resume()
        } else {
            completion([])
            print("Malformed URL")
            self.showMessage(message: "Something went wrong...\n\n( ⚆ _ ⚆ )", progress: false)
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
