//
//  ViewController.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    var loadingIndicator: UIActivityIndicatorView!
    
    private var movieAPI:MovieAPI!
    private var remoteReplicator:RemoteReplicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register for notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(finishedLoading), name: .setStateLoading, object: nil)
        
        prepareView()
        
        movieAPI = MovieAPI.sharedInstance
        remoteReplicator = RemoteReplicator.sharedInstance
        movieAPI.deleteAllMovies()
        
        remoteReplicator.fetchData()
    }
    
    func prepareView(){
        
        view.backgroundColor = UIColor.white
        
        let logoImage = UIImageView(image: UIImage(named: "logo"))
        logoImage.contentMode = .scaleAspectFit
        view.addSubview(logoImage)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        logoImage.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2).isActive = true
        
        loadingIndicator = UIActivityIndicatorView(style: .gray)
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.topAnchor.constraint(equalTo: logoImage.bottomAnchor).isActive = true
    }
    
    @objc func finishedLoading(){
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.navigationController?.pushViewController(MoviesListViewController(), animated: true)
        }
    }
}
