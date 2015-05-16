//
//  MemeCollectionViewController.swift
//  MemeTest
//
//  Created by Stefan Spaar on 5/1/15.
//  Copyright (c) 2015 Stefan Spaar. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collection: UICollectionView!
    
    let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collection.userInteractionEnabled=true;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {     
        // check if saved memes are available - start editor if not
        if applicationDelegate.memes.count == 0 {
            println("No saved Memes")
            let editController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
            self.navigationController!.presentViewController(editController, animated: true, completion: nil)
        }
        
        self.collection.reloadData()
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("# of memes: \(applicationDelegate.memes.count)")
        return applicationDelegate.memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let memeObj = applicationDelegate.memes[indexPath.row]
        // Set the name and image
//        cell.textLabel?.text = memeObj.topText
        cell.cellImage?.image = memeObj.meme
//        cell.detailTextLabel?.text = memeObj.bottomText
        return cell
    }
    
    override func collectionView(tableView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailView") as! MemeDetailViewController
        detailViewController.memeIndex = indexPath.row
        detailViewController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailViewController, animated: true)
        
    }


    @IBAction func addMeme(sender: UIBarButtonItem) {
        let editController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        self.navigationController!.presentViewController(editController, animated: true, completion: nil)
    }
    
}

