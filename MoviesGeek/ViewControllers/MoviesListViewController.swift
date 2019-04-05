//
//  MoviesListViewController.swift
//  MoviesGeek
//
//  Created by Pierre Janineh on 04/04/2019.
//  Copyright © 2019 Pierre Janineh. All rights reserved.
//

import UIKit
import AVFoundation

class MoviesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Internal Properties
    private let SCREEN_TITLE = "Movies"
    private var movieAPI:MovieAPI!
    private var qrCodeReplicator:QRCodeReplicator!
    private var movies:[Movie]!
    private var moviesTable:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register for notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateMoviesTableData), name: .updateMoviesTableData, object: nil)
        
        movieAPI = MovieAPI.sharedInstance
        qrCodeReplicator = QRCodeReplicator.sharedInstance
        movies = movieAPI.getAllMovies(true, sortAscending: false)
        
        prepareView()
        
    }
    
    @objc func updateMoviesTableData(){
        movies.removeAll(keepingCapacity: false)
        movies = movieAPI.getAllMovies(true, sortAscending: false)
        moviesTable.reloadData()
    }
    
    func prepareView(){
        
        view.backgroundColor = UIColor.white
        
        navigationItem.hidesBackButton = true
        navigationItem.title = SCREEN_TITLE
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonClick(_:)))

        
        moviesTable = UITableView()
        view.addSubview(moviesTable)
        moviesTable.translatesAutoresizingMaskIntoConstraints = false
        moviesTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        moviesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        moviesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        moviesTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        moviesTable.delegate = self
        moviesTable.dataSource = self
        moviesTable.register(UITableViewCell.self, forCellReuseIdentifier: "movie_cell")
        
    }
    
    @objc func handleAddButtonClick(_ sender: UIButton){
        let optionsSheet = UIAlertController(title: "Choose source:",
                                             message: "Choose source to scan QRCodes",
                                             preferredStyle: .actionSheet)
        optionsSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertController:UIAlertAction) in
            self.cameraChosen()
        }))
        optionsSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { (alertController:UIAlertAction) in
            self.libraryChosen()
        }))
        optionsSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(optionsSheet, animated: true, completion: nil)
    }
    
    //--------------------------------
    // LIBRARY
    //--------------------------------
    func libraryChosen(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imagePicked(image)
        }else{
            print("Something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePicked(_ image: UIImage){
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let ciImage:CIImage = CIImage(image:image)!
        var qrCodeContent = ""
        
        let features = detector.features(in: ciImage)
        for feature in features as! [CIQRCodeFeature] {
            qrCodeContent += feature.messageString!
        }
        
        if qrCodeContent == "" {
            print("nothing")
        }else{
            qrCodeReplicator.processData(qrCodeContent)
        }
    }
    
    //--------------------------------
    // CAMERA
    //--------------------------------
    func cameraChosen(){
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission { presentCamera() }
        case .authorized: presentCamera()
        case .restricted, .denied: alertCameraAccessNeeded()
        }
    }
    
    func presentCamera() {
        present(QRScannerViewController(), animated: true, completion: nil)
    }
    
    func requestCameraPermission(_ completion: () -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
        })
        completion()
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Camera Access is required",
            message: "Camera access is required to scan Movies QRCodes.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //--------------------------------
    // TABLE VIEW
    //--------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movie_cell")!
        cell.textLabel!.text = "\(movies[indexPath.row].title) (\(movies[indexPath.row].releaseYear))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsView = MovieDetailsViewController()
        detailsView.movie = movies[indexPath.row]
        navigationController?.pushViewController(detailsView, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension Notification.Name {
    static let updateMoviesTableData = Notification.Name(rawValue: "updateMoviesTableData")
    static let setStateLoading = Notification.Name(rawValue: "setStateLoading")
}
