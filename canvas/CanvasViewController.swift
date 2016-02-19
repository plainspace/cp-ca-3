//
//  CanvasViewController.swift
//  canvas
//
//  Created by Jared on 2/17/16.
//  Copyright © 2016 plainspace. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // This function is necessary to have mutliple gesture recognizers work simultaneously.
    func gestureRecognizer(_: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    
    // Define var to hold the initial point position of the new faces.
    var initialCenter: CGPoint!
    
    var trayInitialFrame: CGPoint!
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    // variables to hold the transform values for scale and rotation.
    var scale = CGFloat(1.0)
    var rotation = CGFloat(0)
    
    // var for to hold the value for friction drag.
    var frictionDrag: CGFloat!
    
    @IBAction func didPanTray(sender: AnyObject) {
    }
    
    @IBOutlet weak var trayImageView: UIView!
    
    @IBOutlet weak var trayArrow: UIView!
    
    
    func onTrayPan(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(view)
        let velocity = sender.velocityInView(view)
        let translation = sender.translationInView(view)
        
        // Get the translation value from the PanGestureRecognizer
        var trayTranslation = (sender.translationInView(view))
        
        // Get the velocity
        let trayVelocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            print("Gesture began at: \(point)")
            
            trayOriginalCenter = trayImageView.center
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            print("Gesture changed at: \(point)")
            
            trayImageView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            
            // if the tray view is above the tray up position, setup friction drag (remember, going up on the screen is decreasing the y value).
            if trayImageView.frame.origin.y < trayUp.y {
                
                // set the initial frame to where the tray is currently.
                trayOriginalCenter = trayImageView.frame.origin
                
                // reset the PanGesture translation value to zero.
                sender.setTranslation(CGPointZero, inView: view)
                
                // Divide the translation by the friction drag value and store it.
                trayTranslation.y /= frictionDrag
                
            }
            
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("Gesture ended at: \(point)")
            
            // If the user was panning up when the gesture ended...Move the tray to it's up position.
            if velocity.y < 0 {
                
                // Animate the tray View to it's up position and spin the arrow imageView 0 degrees
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    
                    // Move tray to up position
                    self.trayImageView.frame.origin = self.trayUp
                    
                    // Rotate the arrow back to it's original position.
                    self.trayArrow.transform = CGAffineTransformMakeRotation(0)
                    
                    }, completion: nil)
                
                // otherwise, animate the tray position to the down position and spin the arrow 180 degrees
            } else {
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    
                    // Move tray to down position
                    self.trayImageView.frame.origin = self.trayDown
                    
                    // rotate the arrow 180 degrees
                    self.trayArrow.transform = CGAffineTransformMakeRotation(CGFloat(180 * M_PI / 180))
                    
                    }, completion: nil)
            }
        }
    }


    @IBAction func didPanFace(sender: AnyObject) {
        
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            let imageView = sender.view as! UIImageView
            
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            view.addSubview(newlyCreatedFace)
            
            newlyCreatedFace.center = imageView.center
            
            newlyCreatedFace.center.y += trayImageView.frame.origin.y
            
            // set the initial center point
            initialCenter = newlyCreatedFace.center
            
            // Enable userInteraction so the gesture recognizers can function
            newlyCreatedFace.userInteractionEnabled = true
            
            // Create a new pan gesture recognizer that calls the function "didPanFaceCanvas"
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanFaceCanvas:")
            
            // Add the pan gesture regognizer you created to the newly created face
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            // set pan gesture delegate to self
            panGestureRecognizer.delegate = self;
            
            // Create a new pinch gesture recognizer that calls the function "didPinchFaceCanvas"
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "didPinchFaceCanvas:")
            
            // Add the Pinch Gesture recognizer to newlyCreated Face
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            // set pinch gesture delegate to self
            pinchGestureRecognizer.delegate = self;
            
            // Create a rotation gesture recognizer that calls the function, "didRotateFaceCanvas"
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "didRotateFaceCanvas:")
            
            // Add the rotation gesture recognizer to newly created face
            newlyCreatedFace.addGestureRecognizer(rotationGestureRecognizer)
            
            // Create a double tap gesture recognizer that calls the function, "didDoubleTapFaceCanvas"
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTapFaceCanvas:")
            
            // Set the double tap recognizer to look for 2 taps
            doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            
            // Add the double tap recognizer to newlyCreatedFace
            newlyCreatedFace.addGestureRecognizer(doubleTapGestureRecognizer)
            
            // animate the newlycreated face to scale up 2.4x
            UIImageView.animateWithDuration(0.2, animations: { () -> Void in
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(2.4, 2.4)
            })
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            newlyCreatedFace.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            if newlyCreatedFace.center.y >= trayImageView.frame.origin.y {
                
                // Animate the newlyCreatedFace back to it's original position.
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.newlyCreatedFace.center = self.initialCenter
                    self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: { (Bool) -> Void in
                        
                        // When the animation finishes, remove the newly created face
                        self.newlyCreatedFace.removeFromSuperview()
                })
                
            } else {
                
                // otherwise, the newly created face has been moved above the tray. Animate it to scale slightly down to 2x
                UIImageView.animateWithDuration(0.2, animations: { () -> Void in
                    self.newlyCreatedFace.transform = CGAffineTransformMakeScale(2, 2)
                })
            }
        }
    }
    
    // function that is called from the pan gesture recognizer
    func didPanFaceCanvas(panGestureRecognizer: UIPanGestureRecognizer) {
        
        // Get the translation from the pan gesture recognizer
        let translation = panGestureRecognizer.translationInView(view)
        
        // The moment the gesture starts...
        if panGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            // reference the ImageView that recieved the gesture (the face you panned) and store it in newlyCreatedFace
            newlyCreatedFace = panGestureRecognizer.view as! UIImageView
            
            // set the initial center point
            initialCenter = newlyCreatedFace.center
            
            // bring the NewlyCreatedFace imageView to the front
            newlyCreatedFace.superview?.bringSubviewToFront(view)
            
            // while the user is in the process of panning. (called continuously as user pans)
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
            
            // move the face with the pan
            newlyCreatedFace.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            
            // When the user has stopped panning
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            print("panning face ended")
        }
    }
    
    // function that is called from the pinch gesture recognizer
    func didPinchFaceCanvas(pinchGestureRecognizer:UIPinchGestureRecognizer) {
        scale = pinchGestureRecognizer.scale
        newlyCreatedFace = pinchGestureRecognizer.view as! UIImageView
        newlyCreatedFace.transform = CGAffineTransformScale(newlyCreatedFace.transform, scale, scale)
        pinchGestureRecognizer.scale = 1
    }
    
    // function/action that is called from rotate gesture recognizer
    func didRotateFaceCanvas(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        
        // get the rotation value from the rotate geture recognizer
        rotation = rotationGestureRecognizer.rotation
        
        // reference the ImageView that recieved the gesture (the face you rotated) and store it in newlyCreatedFace
        newlyCreatedFace = rotationGestureRecognizer.view as! UIImageView
        
        // add the rotate transform to whatever previous transform newlyCreatedFace had
        newlyCreatedFace.transform = CGAffineTransformRotate(newlyCreatedFace.transform, rotation)
        
        // Set the scale back to 0. Necessary because we are adding to the existing transform each time around.
        rotationGestureRecognizer.rotation = 0
    }
    
    // function/action that is called from double tap gesture recognizer
    func didDoubleTapFaceCanvas(doubleTapGestureRecognizer: UITapGestureRecognizer) {
        
        // reference the ImageView that recieved the gesture (the face you rotated) and store it in newlyCreatedFace
        newlyCreatedFace = doubleTapGestureRecognizer.view as! UIImageView
        
        // remove that particular face from the view
        newlyCreatedFace.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanFace:")
        
        // trayDownOffset = 160
        // trayUp = trayImageView.center
        // trayDown = CGPoint(x: trayImageView.center.x ,y: trayImageView.center.y + trayDownOffset)
        
        // Assign values to the tray up and tray down variables we defined above.
        trayUp = CGPoint(x: 0, y: 360)
        trayDown = CGPoint(x: 0, y: 530)
        
        // Set the tray view to start in the down position.
        trayImageView.frame.origin = trayDown
        
        // set the tray arrow to be facing up (original image faces down)
        trayArrow.transform = CGAffineTransformMakeRotation(CGFloat(180 * M_PI / 180))
        
        // set the friction drag value. We will divide the translation value by this to implement a friction drag.
        frictionDrag = 10
        
        
        
        // The onCustomPan: method will be defined in Step 3 below.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onTrayPan:")
        
        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        
        trayImageView.userInteractionEnabled = true
        trayImageView.addGestureRecognizer(panGestureRecognizer)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
