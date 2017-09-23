//
//  ViewsRecycler.swift
//  BartlebysUI
//
//  Created by Benoit Pereira da silva on 14/03/2017.
//  Copyright © 2017 https://pereira-da-silva.com/ All rights reserved.
//

import Foundation
import CoreGraphics
import BartlebyKit

/// The view recycler facilitate view reusage for high performance rendering
///
/// During a rendering loop The most efficient way to recycle views is to :
///
/// 1 - `liberateViews(viewsGroupedBy groupNames:[String])`
/// 2 - `getHashedRecyclableViews(groupName:String,associatedUIDs:[String],viewFactory:()->(XView))->[UID:XView]`
/// ... reconfigure the views
/// 3 - `removeAllAvailableViewsFromSuperView()`
/// You can call recycleView if necessary (but it is usually not the best Approach)
open class ViewsRecycler {

    class ViewReferer {

        var view:XView
        var groupName:String
        var available:Bool
        var associatedUID:String

        public init(view: XView, groupName:String, available:Bool = false,associatedUID:String = Default.NO_UID){
            self.view = view
            self.groupName = groupName
            self.available = available
            self.associatedUID = associatedUID
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


    /// Call this method if you consider there is possibly to much recyclable views
    open func purgeAvailableViews(){
        let r = self._viewsReferers.enumerated().reversed()
        for (i,referer) in  r{
            if referer.available {
                referer.view.removeFromSuperview()
                self._viewsReferers.remove(at: i)
            }
        }
    }


    /// Returns the current recycler stats
    ///
    /// - Returns: the stats
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

    /// The stats formatted in a String
    open var stringStats:String{
        let stats = self.stats()
        return "Total:\(stats.total) used:\(stats.used) available:\(stats.available)"
    }


    /// You must call this method regularly to recycle off screen views.
    open func liberateOffScreenViews(){
        for referer in self._viewsReferers{
            if let superview = referer.view.superview{
                if  referer.view.frame.origin.x + referer.view.frame.width + self.minOffScreenDistance < superview.frame.origin.x ||
                    referer.view.frame.origin.x > superview.frame.origin.x + superview.frame.width + self.minOffScreenDistance ||
                    referer.view.frame.origin.y + referer.view.frame.height + self.minOffScreenDistance < superview.frame.origin.y ||
                    referer.view.frame.origin.y > superview.frame.origin.y + superview.frame.height + self.minOffScreenDistance {
                    referer.available = true
                }
            }else if referer.available == false{
                // The clients may remove the view from the superview to force the recycling
                referer.available = true
            }
        }
    }


    /// Recycle = liberateView + removeFromSuperview
    ///
    /// - Parameter view: the view to recycle
    open func recycleView(view:XView){
        view.removeFromSuperview()
        self.liberate(view: view)
    }



    /// Mark explicitely a view as available
    ///
    /// - Parameters:
    ///   - view: the view to recycle
    open func liberate(viewsGroupedBy groupNames:[String]){
        let referers = self._viewsReferers.filter({ (referer) -> Bool in
        return groupNames.contains(referer.groupName)
        })
        for referer in referers{
            referer.available = true
        }
    }

    /// Mark explicitely a view as available
    ///
    /// - Parameters:
    ///   - view: the view to recycle
    open func liberate(view:XView){
        // Update the view status
        if let vs = self._viewsReferers.first(where: { (referer) -> Bool in
            return referer.view == view
        }){
            vs.available = true
        }
    }


    /// Removes all the unused view from their superview
    open func removeAllAvailableViewsFromSuperView(){
        // We liberate all the offscreen views
        self.liberateOffScreenViews()
        // And remove All the available views from their superview
        for referer in self._viewsReferers{
            if referer.available{
                referer.view.removeFromSuperview()
            }
        }
    }



    /// Returns a recyclable view.
    /// If necessary the view is created by the factory closure
    /// - Parameters:
    ///   - identifiedBy: and identifier shared between a group of views
    ///   - associatedUID: we try to propose the same referer for optimization purposes
    ///   - viewFactory:  the factory method to create a new view
    /// - Returns: a recyclable view
    open func getARecyclableView(groupName:String,associatedUID:String,viewFactory:()->(XView))->XView{
        var firstAvailableReferer:ViewReferer?
        if let associatedReferer = self._viewsReferers.first(where: { (referer) -> Bool in
            let matching = (referer.available && referer.groupName==groupName && referer.associatedUID == associatedUID)
            if firstAvailableReferer == nil && !matching && referer.available  && referer.groupName==groupName {
                firstAvailableReferer = referer
            }
            return matching
        }){
            associatedReferer.available = false
            return associatedReferer.view
        }else if let referer = firstAvailableReferer{
            referer.available = false
            referer.associatedUID = associatedUID
            return referer.view
        }
        let view = viewFactory()
        let vs = ViewReferer(view: view, groupName:groupName, available: false,associatedUID:associatedUID)
        vs.associatedUID = associatedUID
        self._viewsReferers.append(vs)
        return view
    }



    /// Returns all the view you need.
    /// If necessary the view is created by the factory closure
    /// Else we try reuse views (preserving previous associations)
    /// - Parameters:
    ///   - groupName: and identifier shared between a group of views
    ///   - associatedUIDs: we try to propose the same referer for optimization purposes
    ///   - viewFactory:  the factory method to create a new view
    /// - Returns: a collection of XView hashed by their associatedUIDs
    open func getHashedRecyclableViews(groupName:String,associatedUIDs:[String],viewFactory:()->(XView))->[UID:XView]{
        var result = [UID:XView]()
        var firstAvailableReferer:ViewReferer?
        for associatedUID in associatedUIDs{
            if let associatedReferer = self._viewsReferers.first(where: { (referer) -> Bool in
                let matching = (referer.available && referer.groupName==groupName && referer.associatedUID == associatedUID)
                if firstAvailableReferer == nil && !matching && referer.available  && referer.groupName == groupName && !associatedUIDs.contains(referer.associatedUID) {
                    firstAvailableReferer = referer
                }
                return matching
            }){
                // We have found the view previously associated with that UID.
                result[associatedUID] = associatedReferer.view
                associatedReferer.available = false
            }else if let referer = firstAvailableReferer{
                // There is a good candidate to reuse.
                result[associatedUID] = referer.view
                referer.available = false
                referer.associatedUID = associatedUID
                // we have used the firstAvailableReferer
                // We need to reset to nil
                firstAvailableReferer = nil
            }else{
                // We need to create a new view
                // let's call the factory
                let view = viewFactory()
                let vs = ViewReferer(view: view, groupName:groupName, available: false,associatedUID:associatedUID)
                vs.associatedUID = associatedUID
                result[associatedUID] = view
                // We add the newly created view to our pool.
                self._viewsReferers.append(vs)
            }
        }
        return result
    }



    /// Return all the actives view grouped by groupname
    ///
    /// - Parameter groupName: the array of group names
    /// - Returns: the collection of actives views
    open func getAllActiveViews(groupedBy groupNames:[String])->[XView]{
        return self._viewsReferers.flatMap({ (referer) -> XView? in
            if  ( groupNames.contains(referer.groupName) && !referer.available){
                return referer.view
            }else{
                return nil
            }
        })
    }



    /// Return all the views grouped by groupname (active or not)
    ///
    /// - Parameter groupName: the array of group names
    /// - Returns: the collection of actives views
    open func getAllViews(groupedBy groupNames:[String])->[XView]{
        return self._viewsReferers.flatMap({ (referer) -> XView? in
            if  groupNames.contains(referer.groupName){
                return referer.view
            }else{
                return nil
            }
        })
    }


    /// Returns all the recycler views
    ///
    /// - Returns: the collection of views
    open func getAllViews()->[XView]{
        return self._viewsReferers.flatMap({ (referer) -> XView? in
                return referer.view
        })
    }

}
