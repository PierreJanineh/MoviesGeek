//
//  MovieDetailsViewController.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    private var imageHeader:UIImageView!
    private var SCREEN_TITLE:String!
    
    var movie:Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SCREEN_TITLE = movie.title
        
        navigationItem.hidesBackButton = false
        navigationItem.title = SCREEN_TITLE
        
        view.backgroundColor = UIColor.white
        
        let scroll = UIScrollView()
        scroll.scrollsToTop = true
        scroll.alwaysBounceVertical = true
        scroll.bounces = true
        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        
        imageHeader = UIImageView()
        imageHeader.load(link: movie.image)
        scroll.addSubview(imageHeader)
        imageHeader.translatesAutoresizingMaskIntoConstraints = false
        imageHeader.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        imageHeader.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        imageHeader.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4).isActive = true

        let lblFont = UIFont.boldSystemFont(ofSize: 22)
        let valFont = UIFont.systemFont(ofSize: 18)
        let margin = view.layoutMarginsGuide
        
        let titleLbl = UILabel()
        titleLbl.text = "\(movie.title) (\(movie.releaseYear))"
        titleLbl.font = lblFont
        titleLbl.numberOfLines = 4
        titleLbl.lineBreakMode = .byWordWrapping
        scroll.addSubview(titleLbl)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.topAnchor.constraint(equalTo: imageHeader.bottomAnchor).isActive = true
        titleLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        let ratingLbl = UILabel()
        ratingLbl.text = "Rating:"
        ratingLbl.font = lblFont
        ratingLbl.textColor = UIColor.gray
        scroll.addSubview(ratingLbl)
        ratingLbl.translatesAutoresizingMaskIntoConstraints = false
        ratingLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor).isActive = true
        ratingLbl.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        ratingLbl.widthAnchor.constraint(equalTo: scroll.widthAnchor, multiplier: 1/3).isActive = true
        
        let ratingVal = UILabel()
        ratingVal.text = "\(movie.rating)"
        ratingVal.font = valFont
        ratingVal.textAlignment = .center
        scroll.addSubview(ratingVal)
        ratingVal.translatesAutoresizingMaskIntoConstraints = false
        ratingVal.topAnchor.constraint(equalTo: ratingLbl.topAnchor).isActive = true
        ratingVal.bottomAnchor.constraint(equalTo: ratingLbl.bottomAnchor).isActive = true
        ratingVal.leadingAnchor.constraint(equalTo: ratingLbl.trailingAnchor).isActive = true
        ratingVal.widthAnchor.constraint(equalTo: scroll.widthAnchor, multiplier: 2/3).isActive = true
        
        let genreLbl = UILabel()
        genreLbl.text = "Genre:"
        genreLbl.font = lblFont
        genreLbl.textColor = UIColor.gray
        scroll.addSubview(genreLbl)
        genreLbl.translatesAutoresizingMaskIntoConstraints = false
        genreLbl.topAnchor.constraint(equalTo: ratingLbl.bottomAnchor).isActive = true
        genreLbl.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        genreLbl.widthAnchor.constraint(equalTo: scroll.widthAnchor, multiplier: 1/3).isActive = true
        
        var genres = ""
        for i in 0..<movie.genre.count{
            if i == 0{
                genres.append("\(movie.genre[i])")
            }else{
                genres.append(", \(movie.genre[i])")
            }
            
        }
        let genreVal = UILabel()
        genreVal.text = genres
        genreVal.font = valFont
        genreVal.numberOfLines = 4
        genreVal.lineBreakMode = .byWordWrapping
        genreVal.textAlignment = .center
        scroll.addSubview(genreVal)
        genreVal.translatesAutoresizingMaskIntoConstraints = false
        genreVal.topAnchor.constraint(equalTo: genreLbl.topAnchor).isActive = true
        genreVal.bottomAnchor.constraint(equalTo: genreLbl.bottomAnchor).isActive = true
        genreVal.leadingAnchor.constraint(equalTo: genreLbl.trailingAnchor).isActive = true
        genreVal.widthAnchor.constraint(equalTo: scroll.widthAnchor, multiplier: 2/3).isActive = true
        
    }
}
extension UIImageView {
    func load(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func load(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        load(url: url, contentMode: mode)
    }
}
