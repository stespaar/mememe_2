//
//  MemeTableViewController.swift
//  MemeTest
//
//  Created by Stefan Spaar on 5/1/15.
//  Copyright (c) 2015 Stefan Spaar. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidAppear(animated: Bool) {
        // check if saved memes are available - start editor if not
        if applicationDelegate.memes.count == 0 {
            println("No saved Memes - launching Editor")
            launchEditView()
        }
        self.table.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("# of memes: \(applicationDelegate.memes.count)")
        return applicationDelegate.memes.count
    }
    
    // Load table with avaiable Memes
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Reuse") as! UITableViewCell
        let memeObj = applicationDelegate.memes[indexPath.row]
        // Set the name and image
        cell.textLabel?.text = memeObj.topText
        cell.imageView?.image = memeObj.meme
        cell.detailTextLabel?.text = memeObj.bottomText
        return cell
    }
    
    // Launch Detail View when Meme gets selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        launchDetailView(indexPath.row)
    }
    
    // Delete Meme with left-swipe
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            println("Delete Meme number \(indexPath.row)")
            applicationDelegate.memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            // check if any memes left - start editor if not
            if applicationDelegate.memes.count == 0 {
                println("No saved Memes - launching Editor")
                launchEditView()
            }
        }
    }

    @IBAction func AddMeme(sender: UIBarButtonItem) {
        launchEditView()
    }
    
    func launchEditView() {
        let editController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        self.navigationController!.presentViewController(editController, animated: true, completion: nil)
    }
    
    func launchDetailView(index: Int) {
        let detailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailView") as! MemeDetailViewController
        detailViewController.memeIndex = index
        detailViewController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailViewController, animated: true)
    }
    
}

