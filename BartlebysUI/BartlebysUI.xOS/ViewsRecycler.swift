//
//  ViewsRecycler.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 14/03/2017.
//  Copyright © 2017 Lylo Media Group SA. All rights reserved.
//

import Foundation


open class ViewsRecycler {

    class ViewReferer {

        var view:BXView
        var groupName:String
        var available:Bool

        public init(view: BXView, groupName:String, available:Bool = false){
            self.view = view
            self.groupName = groupName
            self.available = available
        }
    }



    // We keep a reference on all views.
    var _viewsReferers=[ViewReferer]()

    // You can for performance tuning determine a min distance to determine what should be considerated as recyclable
    var minOffScreenDistance:CGFloat = 100


    public init() {}

    /// Purges all the views (e.g on view controller deinit)
    open func purgeViews(){
        while let vs = self._viewsReferers.popLast(){
            vs.view.removeFromSuperview()
        }
    }

    open func stats()->(total:Int,used:Int, available:Int){
        let total = self._viewsReferers.count
        var used = 0
        var available = 0
        for vs in self._viewsReferers{
            if vs.available {
                available += 1
            }else{
                used += 1
            }
        }
        return (total,used,available)
    }

    /// You must call this method regularly to recycle off screen views.
    open func recycleRecyclableViews(){
        for vs in self._viewsReferers{
            if let superview = vs.view.superview{
                if  vs.view.frame.origin.x + vs.view.frame.width + self.minOffScreenDistance < superview.frame.origin.x ||
                    vs.view.frame.origin.x > superview.frame.origin.x + superview.frame.width + self.minOffScreenDistance ||
                    vs.view.frame.origin.y + vs.view.frame.height + self.minOffScreenDistance < superview.frame.origin.y ||
                    vs.view.frame.origin.y > superview.frame.origin.y + superview.frame.height + self.minOffScreenDistance {
                    let _ = self.recycleView(view: vs.view)
                }
            }else if vs.available == false{
                // The clients may remove the view from the superview to force the recycling
                self.recycleView(view: vs.view)
            }
        }
    }


    /// Recycles explicitely a view
    ///
    /// - Parameters:
    ///   - view: the view to recycle
    open func recycleView(view:BXView)->Bool{
        // Update the view status
        if let vs = self._viewsReferers.first(where: { (viewStatus) -> Bool in
            return viewStatus.view == view
        }){
            view.removeFromSuperview()
            vs.available = true
            return true
        }
        return false
    }


    /// Returns a recyclable view.
    /// If necessary the view is created by the factory closure
    /// - Parameters:
    ///   - identifiedBy: and identifier shared between a group of views
    ///   - viewFactory:  the factory method to create a new view
    /// - Returns: a recyclable view
    open func getARecyclableView(groupName:String,viewFactory:()->(BXView))->BXView{
        if let referer = self._viewsReferers.first(where:{ (referer) -> Bool in
            return (referer.available && referer.groupName==groupName)
        }){
            referer.available = false
            return referer.view
        }
        let view = viewFactory()
        let vs = ViewReferer(view: view, groupName:groupName, available: false)
        self._viewsReferers.append(vs)
        return view
    }


    /// Return all the actives view grouped by the groupname
    ///
    /// - Parameter groupName: the classifier
    /// - Returns: the collection of actives views
    open func getAllActiveViews(groupedBy groupName:String)->[BXView]{
        return self._viewsReferers.flatMap({ (referer) -> BXView? in
            if  (referer.groupName == groupName && !referer.available){
                return referer.view
            }else{
                return nil
            }
        })
    }



}
