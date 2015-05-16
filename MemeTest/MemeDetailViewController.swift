//
//  MemeDetailViewController.swift
//  MemeTest
//
//  Created by Stefan Spaar on 5/7/15.
//  Copyright (c) 2015 Stefan Spaar. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var detailImage: UIImageView!
    
    let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var memeIndex: Int!

    override func viewWillAppear(animated: Bool) {
        detailImage.image = applicationDelegate.memes[memeIndex].meme
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem (
            title: "Delete",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "deleteMeme")
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem (
            title: "Edit",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "editMeme")
        let bar: UINavigationBar! = self.navigationController?.navigationBar
        bar.alpha = 0.8

    }
    
    func deleteMeme() {
        println("Delete Meme number \(memeIndex)")
    applicationDelegate.memes.removeAtIndex(memeIndex)
        self.navigationController!.popViewControllerAnimated(true)
    }

    func editMeme() {
        println("Edit Meme number \(memeIndex)")
        let editController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditorViewController
        editController.meme = applicationDelegate.memes[memeIndex]
        // Pop current ViewController first before launching Edit Controller otherwise it will be orphaned
        self.navigationController!.popViewControllerAnimated(true)
        self.navigationController!.presentViewController(editController, animated: true, completion: nil)        
    }

}
