//
//  MultiStepWindowController.swift
//  YouDub
//
//  Created by Benoit Pereira da silva on 24/03/2018.
//  Copyright © 2018 Lylo Media Group SA. All rights reserved.
//

import BartlebyKit
import Cocoa

// A window view controller used to display sequential view controllers
// used by the IdentityWindowController
open class MultiStepWindowController: NSWindowController, DocumentProvider, StepNavigation {
    open override var windowNibName: NSNib.Name? { return NSNib.Name("MultiStepWindowController") }

    // MARK: - DocumentProvider

    /// Returns a BartlebyDocument
    /// Generally used in  with `DocumentDependent` protocol
    ///
    /// - Returns: the document
    public func getDocument() -> BartlebyDocument? {
        return document as? BartlebyDocument
    }

    public fileprivate(set) var steps: [StepViewController] = [StepViewController]()

    open var onCompletion: (_ reference: MultiStepWindowController) -> Void = { reference in
        reference.close()
    }

    // MARK: - Outlets

    @IBOutlet var tabView: NSTabView!

    @IBOutlet var leftButton: NSButton!

    @IBOutlet var rightButton: NSButton!

    @IBOutlet var progressIndicator: NSProgressIndicator!

    // MARK: - Life cycle

    open override func windowDidLoad() {
        super.windowDidLoad()
    }

    // MARK: - Actions

    @IBAction func leftAction(_: Any) {
    }

    @IBAction func rightAction(_: Any) {
        currentStep?.proceedToValidation()
    }

    // MARK: - StepNavigation

    public func didValidateStep(_: Int) {
        nextStep()
        enableActions()
    }

    public func disableActions() {
        enableProgressIndicator()
        leftButton.isEnabled = false
        rightButton.isEnabled = false
    }

    public func enableActions() {
        disableProgressIndicator()
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }

    public func enableProgressIndicator() {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)
    }

    public func disableProgressIndicator() {
        progressIndicator.isHidden = true
        progressIndicator.stopAnimation(self)
    }

    // MARK: -

    var currentStep: Step? {
        let vc = tabView.selectedTabViewItem?.viewController
        return vc as? Step
    }

    internal var _currentStepIndex: Int = -1

    var currentStepIndex: Int {
        return _currentStepIndex
    }

    func setCurrentStepIndex(_ index: Int) {
        _currentStepIndex = index
        if tabView.tabViewItems.count > index && index >= 0 {
            tabView.selectTabViewItem(at: index)
        } else {
            onCompletion(self)
        }
    }

    func nextStep() {
        setCurrentStepIndex(currentStepIndex + 1)
    }

    /// Appends a view Controller to the stack
    ///
    /// - Parameters:
    ///   - viewController: an StepViewController children
    ///   - selectImmediately: display immediately the added view Controller
    public func append(viewController: StepViewController, selectImmediately: Bool) {
        let viewControllerItem = NSTabViewItem(viewController: viewController)
        viewController.documentProvider = self
        viewController.stepDelegate = self
        viewController.stepIndex = tabView.tabViewItems.count

        steps.append(viewController)

        tabView.addTabViewItem(viewControllerItem)
        if selectImmediately {
            setCurrentStepIndex(viewController.stepIndex)
        }
    }

    /// Removes the viewController
    ///
    /// - Parameter viewController: the view controller to remove
    public func remove(viewController: StepViewController) {
        let nb = tabView.tabViewItems.count
        if let idx = self.steps.index(of: viewController) {
            steps.remove(at: idx)
        }
        for i in 0 ..< nb {
            let item = tabView.tabViewItems[i]
            if item.viewController == viewController {
                tabView.removeTabViewItem(item)
                break
            }
        }
    }

    internal func removeAllSuccessors() {
        for item in tabView.tabViewItems.reversed() {
            if tabView.tabViewItems.count > currentStepIndex {
                tabView.removeTabViewItem(item)
            } else {
                break
            }
        }

        for idx in currentStepIndex ..< steps.count {
            let vc = steps[idx]
            remove(viewController: vc)
        }
    }

    internal func currentStepIs(_ viewController: StepViewController) -> Bool {
        if tabView.tabViewItems.count > currentStepIndex {
            let item = tabView.tabViewItems[self.currentStepIndex]
            let matching = item.viewController?.className == viewController.className
            return matching
        } else {
            return false
        }
    }
}
