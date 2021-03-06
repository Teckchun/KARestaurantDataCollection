//
//  ListRestaurantTableViewCell.swift
//  KARestaurant
//
//  Created by Kokpheng on 5/31/16.
//  Copyright © 2016 KARestaurant. All rights reserved.
//

import UIKit
import Material
import Kingfisher



class ListRestaurantTableViewCell: MaterialTableViewCell {
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var restaurantDetailLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var restaurant: Restaurant!
 
    func configure(restaurant: Restaurant) {
        self.restaurant = restaurant
        populateCell()
        downloadImage()
    }
    
    private func reset() {
        restaurantImageView.image = nil
        titleLabel.hidden = true
        deliveryLabel.hidden = true
        restaurantDetailLabel.hidden = true
        editButton.hidden = true
    }
    
    private func downloadImage(){
        if let  urlString = restaurant.thumbnail {
            
            self.restaurantImageView.kf_setImageWithURL(NSURL(string: urlString)!, placeholderImage: UIImage(named: "loadingImage"), optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
                //populateCell()
            }
        }else{
            self.restaurantImageView.image = UIImage(named: "null")
        }
    }
    
 
    private func populateCell() {
        titleLabel.text = restaurant.name
        restaurantDetailLabel.text = restaurant.restDescription
        deliveryLabel.text = NSString.init(string: restaurant.isDeliver!).boolValue ? "Delivery" : "No Delivery"
        editButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        //showField()
    }
    
    private func showField() {
        titleLabel.hidden = false
        deliveryLabel.hidden = false
        restaurantDetailLabel.hidden = false
        editButton.hidden = false
    }
    

    
}


