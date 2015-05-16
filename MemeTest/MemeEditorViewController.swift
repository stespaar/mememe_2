//
//  MemeEditorViewController.swift
//  MemeTest
//
//  Created by Stefan Spaar on 4/27/15.
//  Copyright (c) 2015 Stefan Spaar. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // Constant and variable declarations
    let imagePicker = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(), NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0 //Note: Negative to fill the letter!
    ]
    
    let topOrigText = "TOP"
    let bottomOrigText = "BOTTOM"
    
    let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var meme = Meme()
    
    // Outlet connections
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButon: UIBarButtonItem!
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imagePicker.delegate = self
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.Center
        bottomText.textAlignment = NSTextAlignment.Center
        
        // check if no text in meme for startup
        if meme.topText == nil {
            topText.text = topOrigText
        } else {
            topText.text = meme.topText
        }
        if meme.bottomText == nil {
            bottomText.text = bottomOrigText
        } else {
            bottomText.text = meme.bottomText
        }
        
        // check if image present otherwise disable share button
        if meme.origImage == nil {
            shareButton.enabled = false
        } else {
        imagePickerView.image = meme.origImage
        }
        
        self.topText.delegate = self
        self.bottomText.delegate = self
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
            if let image =  info[UIImagePickerControllerOriginalImage]as? UIImage {
                println("image selected")
                self.imagePickerView.image = image
                shareButton.enabled = true
            }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("cancelled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func pickAnImage(sender: UIBarButtonItem) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func takePhoto(sender: UIBarButtonItem) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    // Clear the textfields when editing starts first time
    func textFieldDidBeginEditing(textField: UITextField) {
        if ((textField === topText) && (textField.text == topOrigText)) {
            textField.text = ""
        }
        if ((textField === bottomText) && (textField.text == bottomOrigText)) {
            textField.text = ""
        }
    }
    
    // Remove keyboard when hitting 'return'
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // To be able to move the screen for textfield input
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        // move frame up by height of keyboard to keep text field visible
        if bottomText.isFirstResponder() {
            println("BottomText is 1st responder")
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        // move view down if it was shifted 
        if bottomText.isFirstResponder() {
            println("Shift down again")
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    func generateMemedImage() -> UIImage {
        // Hide toolbars
        toolBar.hidden = true
        navBar.hidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // bring back toolbars
        toolBar.hidden = false
        navBar.hidden = false
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        meme.topText = topText.text
        meme.bottomText = bottomText.text
        meme.origImage = imagePickerView.image
        meme.meme = memedImage
        // add to meme array in the App Delegate
        applicationDelegate.memes.append(meme)
    }

    @IBAction func sharePressed(sender: UIBarButtonItem) {
        var memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            UIActivityTypeAssignToContact] // just to try
        // save Meme when successfully shared
        activityVC.completionWithItemsHandler = {
            (   activity: String!,
                success: Bool,
                items: [AnyObject]!,
                error: NSError!) -> Void in
            println("completed \(activity) \(success) \(items) \(error)")
            if success {
                self.save(memedImage)
                println("Meme saved!")
            }
            // Dismiss activity view
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        println("Sharing!")
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelPressed(sender: AnyObject) {
        if applicationDelegate.memes.count == 0 {
            // Displays error message if no sent memes yet
            let alertController = UIAlertController(title: "Oops!", message: "No sent Memes yet.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Create Meme", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}