//
//  CNLSearchController.swift
//  CNLUIKitTools
//
//  Created by Igor Smirnov on 01/12/2016.
//  Copyright © 2016 Complex Numbers. All rights reserved.
//

import UIKit

public protocol CNLSearchControllerDelegate: class {
    func searchControllerNeedRefresh(_ controller: CNLSearchController)
    func searchControllerCancelled(_ controller: CNLSearchController)
}

open class CNLSearchController: NSObject, UISearchBarDelegate {
    
    weak var delegate: CNLSearchControllerDelegate?
    
    open var searchQueryText: String?
    
    open var searchBar = UISearchBar()
    open var searchBarButtonItem: UIBarButtonItem!
    open var searchButton: UIButton!
    open var navigationItem: UINavigationItem!
    
    open func setupWithDelegate(_ delegate: CNLSearchControllerDelegate, navigationItem: UINavigationItem, buttonImage: UIImage?, searchQueryText: String? = nil) {
        self.delegate = delegate
        searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        searchButton.setImage(buttonImage, for: UIControlState())
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        searchButton.addTarget(self, action: #selector(searchButtonAction(_:)), for: .touchUpInside)
        searchBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        self.navigationItem = navigationItem
        
        self.searchQueryText = searchQueryText
        searchBar.text = searchQueryText ?? ""
        searchBar.delegate = self
        searchBar.setShowsCancelButton(true, animated: false)
        activate()
    }
    
    open func activate() {
        navigationItem.rightBarButtonItem = searchBarButtonItem
    }
    
    open func deactivate(_ animated: Bool) {
        searchBar.resignFirstResponder()
        if let _ = navigationItem.titleView {
            hideSearchBar(animated)
        }
    }
    
    open func hideSearchBar(_ animated: Bool) {
        searchBar.text = nil
        if (searchQueryText ?? "") != "" {
            searchBarSearchButtonClicked(searchBar)
        }
        searchBar.resignFirstResponder()
        //searchBar.setShowsCancelButton(false, animated: true)
        delegate?.searchControllerCancelled(self)
        UIView.setAnimationsEnabled(animated)
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.searchBar.alpha = 0.0
        },
            completion: { completed in
                self.navigationItem.titleView = nil
                self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
                self.searchButton.alpha = 0.0  // set this *after* adding it back
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        self.searchButton.alpha = 1.0
                        UIView.setAnimationsEnabled(true)
                }
                )
        }
        )
    }
    
    open func searchButtonAction(_ sender: AnyObject) {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.searchButton.alpha = 0.0
        },
            completion: { finished in
                // remove the search button
                self.navigationItem.rightBarButtonItem = nil
                // add the search bar (which will start out hidden).
                self.navigationItem.titleView = self.searchBar
                self.searchBar.alpha = 0.0
                
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        self.searchBar.alpha = 1.0
                },
                    completion: { completed in
                        self.searchBar.becomeFirstResponder()
                }
                )
        }
        )
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchQueryText = searchBar.text
        delegate?.searchControllerNeedRefresh(self)
        //searchBar.setShowsCancelButton(false, animated: true)
    }
    
    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.setShowsCancelButton(true, animated: true)
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar(true)
    }
    
}

