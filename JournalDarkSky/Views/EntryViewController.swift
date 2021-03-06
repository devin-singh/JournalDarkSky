//
//  EntryViewController.swift
//  JournalDarkSky
//
//  Created by Jared Warren on 1/20/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit
import CoreLocation

/// Controlls all Entries the user sees
class EntryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var entryTableView: UITableView!
    
    // MARK: - Properties
    
    let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTableView.delegate = self
        entryTableView.dataSource = self
        fetchQuote()
        fetchWeather()
    }
    
    // MARK: - Private Methods
    
    /// Fetches the weather and displays it at the top of the tableview.
    private func fetchWeather() {
        // Request permission to get the users location
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            guard let coordinate = locationManager.location?.coordinate else { return }
            
            WeatherService.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    // Display Weather to user
                    case .success(let weather):
                        self.summaryLabel.text = weather.summary
                        self.temperatureLabel.text = String(weather.temperature)
                    // Display error to user
                    case .failure(let error):
                        self.presentErrorToUser(localizedError: error)
                    }
                }
            }
        }
    }
    /// Fetches a quote from the QuoteAPI via QuoteService
    private func fetchQuote() {
        // Asks QuoteService to fetch a quote
        QuoteService.fetchQuote { (result) in
            // Switches application to the main thread
            DispatchQueue.main.async {
                // Switching on result to check for success or failure.
                switch result {
                case .success(let quote):
                    // If success the quoteLabel will be updated wih the quoteText and quoteAuthor property
                    self.quoteLabel.text = quote.quoteText + "\n-" + quote.quoteAuthor
                case .failure(let error):
                    // Displays error to the user
                    self.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
    
    /// Presents an alert to user to create a new entry
    private func presentNewEntryAlert() {
        let alert = UIAlertController(title: "Entry", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let cancelAction = UIAlertAction(title: "Nvm", style: .cancel)
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let textField = alert.textFields?.first,
                let entryText = textField.text,
                !entryText.isEmpty,
                let quote = self.quoteLabel.text,
                let weatherSummary = self.summaryLabel.text,
                let temperature = self.temperatureLabel.text else { return }
            EntryController.shared.createEntry(title: entryText, quote: quote, weatherSummary: weatherSummary, temperature: temperature)
            self.entryTableView.reloadData()
        }
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func createEntryButtonTapped(_ sender: Any) {
        presentNewEntryAlert()
    }
}

// MARK: - UITableView Delegate & Data Source

extension EntryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        cell.textLabel?.text = EntryController.shared.entries[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EntryController.shared.entries.count
    }
}
