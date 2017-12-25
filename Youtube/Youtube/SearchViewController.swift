//
//  SearchViewController.swift
//  Youtube
//
//  Created by MAC on 10/7/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var resultSearch = [Video]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cellSelected = sender as? SearchCollectionViewCell else {
            fatalError()
        }
        guard let indexPath = collectionView.indexPath(for: cellSelected) else {
            fatalError()
        }
        if let detailVideoViewController = segue.destination as? DetailPlaylistViewController  {
            detailVideoViewController.typeSource = .search
            detailVideoViewController.videoPlaying = resultSearch[indexPath.row]
            detailVideoViewController.titleSearch = searchBar.text!
        }
    }

}

extension SearchViewController {
    func initView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultSearch.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSearchResult", for: indexPath) as! SearchCollectionViewCell
        cell.loadData(video: resultSearch[indexPath.row])
        return cell
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let titleSearch = searchBar.text {
            APIClient.shared.searhcForTitleVideo(title: titleSearch) {[weak self] (allVideo) in
                self?.resultSearch = allVideo
                self?.collectionView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}
