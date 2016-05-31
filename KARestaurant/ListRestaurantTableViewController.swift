//
//  ListRestaurantTableViewController.swift
//  KARestaurant
//
//  Created by Kokpheng on 5/31/16.
//  Copyright © 2016 KARestaurant. All rights reserved.
//

import UIKit
import Photos
import Material
import Alamofire
import ObjectMapper
import AlamofireImage


class ListRestaurantTableViewController: UITableViewController {

    // MARK: Properties
    var isNewRestaurantDataLoading: Bool = false
    var isRefreshControlLoading: Bool = false
    
    let restuarantRefreshControl: UIRefreshControl = UIRefreshControl() // Top RefreshControl
    
    var responseRestaurant = [Restaurants]()
    var responsePagination = Pagination()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restuarantRefreshControl.addTarget(self, action: #selector(RestaurantTableViewController.uiRefreshControlAction), forControlEvents: .ValueChanged)
        self.tableView.addSubview(restuarantRefreshControl)
        
        getRestuarant(1, limit: 20)
        
        prepareView()
    }
    
    func uiRefreshControlAction() {
        print((self.responsePagination?.limit)!)
        
        if !isRefreshControlLoading {
            self.isRefreshControlLoading =  true
            getRestuarant(1, limit: (self.responsePagination?.limit)!)
        }
        
        
    }
    
    func getRestuarant(page: Int, limit: Int){
        // get restuarant
        let url = Constant.GlobalConstants.URL_BASE + "/v1/api/admin/restaurants/?page=\(page)&limit=\(limit)"
        
        Alamofire.request(.GET, url, headers: Constant.GlobalConstants.headers).responseJSON { response in
            let responseData = Mapper<ResponseRestaurant>().map(response.result.value)
            self.responsePagination = responseData!.pagination!
            
            
            // remove data when pull to refresh
            if self.isRefreshControlLoading {
                self.responseRestaurant.removeAll()
            }
            
            self.responseRestaurant += responseData!.data!
            
            print("limit: \(self.responsePagination!.limit!) item count:\(self.responseRestaurant.count)/\(self.responsePagination!.totalCount!) current page: \(self.responsePagination!.page!) page: \(self.responsePagination!.totalPages!)")
            
            self.isNewRestaurantDataLoading = false
            self.isRefreshControlLoading = false
            self.restuarantRefreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //Bottom Refresh
        
        if scrollView == self.tableView{
            
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                if !isNewRestaurantDataLoading{
                    isNewRestaurantDataLoading = true
                    if self.responsePagination?.page < self.responsePagination?.totalPages {
                        getRestuarant((self.responsePagination?.page)! + 1, limit: (self.responsePagination?.limit)!)
                    }
                    
                    //                    if helperInstance.isConnectedToNetwork(){
                    //
                    
                    //                        isNewDataLoading = true
                    //                        getNewData()
                    //                    }
                }
            }
        }
    }
    
    

    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let mealDetailViewController = segue.destinationViewController as! AddViewController
            
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? RestaurantTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedMeal = self.responseRestaurant[indexPath.row]
                mealDetailViewController.restaurant = selectedMeal
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new meal.")
        }
    }
    
    //
    
    
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? AddViewController, meal = sourceViewController.restaurant {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                self.responseRestaurant[selectedIndexPath.row] = meal
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            } else {
                // Add a new meal.
                let newIndexPath = NSIndexPath(forRow: self.responseRestaurant.count, inSection: 0)
                self.responseRestaurant.append(meal)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
        }
    }



    /// Prepares the view.
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
    }
    
    /// Prepares the topCardView.
    func prepareTopCardView(topCardView: ImageCardView, title: String, image : UIImage) {
        topCardView.divider = false
        topCardView.maxImageHeight = 200
        topCardView.image = image
        
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = MaterialColor.white
        titleLabel.font = RobotoFont.regularWithSize(24)
        topCardView.titleLabel = titleLabel
        topCardView.titleLabelInset.top = 140
        
        // Star button.
        let img1: UIImage? = MaterialIcon.cm.star
        let btn1: IconButton = IconButton()
        btn1.pulseColor = MaterialColor.blueGrey.lighten1
        btn1.tintColor = MaterialColor.blueGrey.lighten1
        btn1.setImage(img1, forState: .Normal)
        btn1.setImage(img1, forState: .Highlighted)
        
        // Bell button.
        let img2: UIImage? = MaterialIcon.cm.bell
        let btn2: IconButton = IconButton()
        btn2.pulseColor = MaterialColor.blueGrey.lighten1
        btn2.tintColor = MaterialColor.blueGrey.lighten1
        btn2.setImage(img2, forState: .Normal)
        btn2.setImage(img2, forState: .Highlighted)
        
        // Share button.
        let img3: UIImage? = MaterialIcon.cm.share
        let btn3: IconButton = IconButton()
        btn3.pulseColor = MaterialColor.blueGrey.lighten1
        btn3.tintColor = MaterialColor.blueGrey.lighten1
        btn3.setImage(img3, forState: .Normal)
        btn3.setImage(img3, forState: .Highlighted)
        
        // Add buttons to right side.
        topCardView.rightButtons = [btn1, btn2, btn3]
    }

    
}

/// TableViewDataSource methods.
extension ListRestaurantTableViewController {
    /// Determines the number of rows in the tableView.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.responseRestaurant.count)
    }
    
    
    // MARK: - Table view data source
    /// Returns the number of sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// Prepares the cells within the tableView.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell: MaterialTableViewCell = MaterialTableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
//        
//        let item: Item = items[indexPath.row]
//        cell.selectionStyle = .None
//        cell.textLabel!.text = item.text
//        cell.textLabel!.font = RobotoFont.regular
//        cell.detailTextLabel!.text = item.detail
//        cell.detailTextLabel!.font = RobotoFont.regular
//        cell.detailTextLabel!.textColor = MaterialColor.grey.darken1
//        cell.imageView!.image = item.image?.resize(toWidth: 40)
//        cell.imageView!.layer.cornerRadius = 20
        
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RestaurantTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ListRestaurantTableViewCell
        
        let restuarant = self.responseRestaurant[indexPath.row] as Restaurants
        
        // Fetches the appropriate restuarant for the data source layout.
        
        //        cell.nameLabel.text = restuarant.name
        //        cell.descriptionLabel.text = restuarant.restDescription
        //        cell.deliveryLabel.text = restuarant.isDeliver == "1" ? "Delivery" : "No Delivery"
        
        
        
        Alamofire.request(.GET, (restuarant.thumbnail == nil ? "http://localhost:8080/RESTAURANT_API/resources/images/1444d819-cef0-4baf-a9e6-09109c08a2f7.jpg" : restuarant.thumbnail!))
            .responseImage { response in
                //debugPrint(response)
                
                // print(response.request)
                // print(response.response)
                // debugPrint(response.result)
                
                if let image = response.result.value {
                    self.prepareTopCardView(cell.topCardView, title: restuarant.name! ,image: image)
                    // print("image downloaded: \(image)")
                }
        }
        
        return cell
    }
    
    /* Delete */
    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return false
//    }
    //
    //
    //    // Override to support editing the table view.
    //    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //        if editingStyle == .Delete {
    //            // Delete the row from the data source
    //            self.responseRestaurant.removeAtIndex(indexPath.row)
    //            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    //        } else if editingStyle == .Insert {
    //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //        }
    //    }

}

/// UITableViewDelegate methods.
extension ListRestaurantTableViewController {
    /// Sets the tableView cell height.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
}
