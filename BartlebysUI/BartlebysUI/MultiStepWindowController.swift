//
//  MultiStepWindowController.swift
//  YouDub
//
//  Created by Benoit Pereira da silva on 24/03/2018.
//  Copyright © 2018 Lylo Media Group SA. All rights reserved.
//

import Cocoa
import BartlebyKit

// A window view controller used to display sequential view controllers
// used by the IdentityWindowController
open class MultiStepWindowController: NSWindowController,DocumentProvider,StepNavigation {


    override open var windowNibName: NSNib.Name? { return NSNib.Name("MultiStepWindowController") }

    // MARK: - DocumentProvider

    /// Returns a BartlebyDocument
    /// Generally used in  with `DocumentDependent` protocol
    ///
    /// - Returns: the document
    public func getDocument() -> BartlebyDocument?{
        return self.document as? BartlebyDocument
    }

    // MARK: - Outlets

    @IBOutlet weak var tabView: NSTabView!

    @IBOutlet weak var leftButton: NSButton!

    @IBOutlet weak var rightButton: NSButton!

    @IBOutlet weak var progressIndicator: NSProgressIndicator!


    // MARK: - Life cycle

    override open func windowDidLoad() {
        super.windowDidLoad()
    }

    // MARK: - Actions

    @IBAction func leftAction(_ sender: Any) {
    }

    @IBAction func rightAction(_ sender: Any) {
        self.currentStep?.proceedToValidation()
    }


    // MARK: - StepNavigation


    public func didValidateStep(_ step: Int) {

    }


    public func disableActions(){
        self.enableProgressIndicator()
        self.leftButton.isEnabled=false
        self.rightButton.isEnabled=false
    }

    public func enableActions(){
        self.disableProgressIndicator()
        self.leftButton.isEnabled=true
        self.rightButton.isEnabled=true
    }

    public func enableProgressIndicator(){
        self.progressIndicator.isHidden=false
        self.progressIndicator.startAnimation(self)
    }

    public func disableProgressIndicator(){
        self.progressIndicator.isHidden=true
        self.progressIndicator.stopAnimation(self)
    }

    // MARK: -

    var currentStep:Step?{
        let vc =  self.tabView.selectedTabViewItem?.viewController
        return vc as? Step
    }

    var currentStepIndex:Int = -1 {
        didSet{
        }
    }
    
    func nextStep(){
        self.currentStepIndex += 1
    }


    /// Appends a view Controller to the stack
    ///
    /// - Parameters:
    ///   - viewController: an StepViewController children
    ///   - selectImmediately: display immediately the added view Controller
    public func append(viewController:StepViewController,selectImmediately:Bool){
        let viewControllerItem=NSTabViewItem(viewController:viewController)
        viewController.documentProvider=self
        viewController.stepDelegate=self
        viewController.stepIndex=self.tabView.tabViewItems.count
        self.tabView.addTabViewItem(viewControllerItem)
        if selectImmediately{
            self.currentStepIndex=viewController.stepIndex
        }
    }


    /// Removes the viewController
    ///
    /// - Parameter viewController: the view controller to remove
    public func remove(viewController:StepViewController){
        let nb=self.tabView.tabViewItems.count
        for i in 0..<nb{
            let item=self.tabView.tabViewItems[i]
            if item.viewController==viewController{
                self.tabView.removeTabViewItem(item)
                break
            }
        }
    }

   internal func removeAllSuccessors(){
        for item in self.tabView.tabViewItems.reversed(){
            if self.tabView.tabViewItems.count > self.currentStepIndex{
                self.tabView.removeTabViewItem(item)
            }else{
                break
            }
        }
    }

    internal func currentStepIs(_ viewController:StepViewController)->Bool{
        if self.tabView.tabViewItems.count > self.currentStepIndex{
            let item=self.tabView.tabViewItems[self.currentStepIndex]
            let matching=item.viewController?.className==viewController.className
            return matching
        }else{
            return false
        }
    }
}
