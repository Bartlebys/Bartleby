//
//  ViewsRecycler.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 14/03/2017.
//  Copyright © 2017 Lylo Media Group SA. All rights reserved.
//

import Foundation

open class ViewsRecycler {

    struct ViewStatus {
        var view:BXView
        var classifier:String
        var available:Bool
    }
    // Classifyed recyclable views
    fileprivate var _recyclableViews=[String:[BXView]]()

    // We keep a reference on all views.
    fileprivate var _viewsStatus=[ViewStatus]()

    // You can for performance tuning determine a min distance to determine what should be considerated as recyclable
    var minOffScreenDistance:CGFloat = 100

    public init() {}

    /// Purges all the views (e.g on view controller deinit)
    open func purgeViews(){
        while let vs = self._viewsStatus.popLast(){
            vs.view.removeFromSuperview()
        }
        self._recyclableViews.removeAll()
    }

    /// You must call this method regularly to recycle off screen views.
    open func recycleRecyclableViews(){
        for vs in self._viewsStatus{
            if let superview = vs.view.superview{
                if  vs.view.frame.origin.x + vs.view.frame.width + self.minOffScreenDistance < superview.frame.origin.x ||
                    vs.view.frame.origin.x > superview.frame.origin.x + superview.frame.width + self.minOffScreenDistance ||
                    vs.view.frame.origin.y + vs.view.frame.height + self.minOffScreenDistance < superview.frame.origin.y ||
                    vs.view.frame.origin.y > superview.frame.origin.y + superview.frame.height + self.minOffScreenDistance {
                    self._recycleView(view: vs.view, classifiedBy:vs.classifier)
                }
            }
        }
    }


    /// Returns a recyclable view.
    /// If necessary the view is created by the factory closure
    /// - Parameters:
    ///   - identifiedBy: and identifier shared between a group of views
    ///   - viewFactory:  the factory method to create a new view
    /// - Returns: a recyclable view
    open func getARecyclableView(identifiedBy:String,viewFactory:()->(BXView))->BXView{
        if let view = self._recyclableViews[identifiedBy]?.popLast(){
            return view
        }
        let view = viewFactory()
        let vs = ViewStatus(view: view, classifier:identifiedBy, available: false)
        self._viewsStatus.append(vs)
        return view
    }

    // MARK: - Private implementation

    /// Recycles a view
    ///
    /// - Parameters:
    ///   - view: the view to recycle
    ///   - groupedBy: its group
    fileprivate func _recycleView(view:BXView,classifiedBy:String){
        var group:[BXView]!
        if let existingGroup=_recyclableViews[classifiedBy] {
            group = existingGroup
        }else{
            group = [BXView]()
        }
        group.append(view)
        view.removeFromSuperview()
        self._recyclableViews[classifiedBy]=group
        // Update the view status
        if var vs = self._viewsStatus.first(where: { (viewStatus) -> Bool in
            return viewStatus.view == view
        }){
            vs.available = true
        }
    }

}
