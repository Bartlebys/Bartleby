//
//  ViewsRecycler.swift
//  YouDubRobot
//
//  Created by Benoit Pereira da silva on 14/03/2017.
//  Copyright © 2017 Lylo Media Group SA. All rights reserved.
//

import Foundation
import BartlebyKit
import BartlebysUI

class ViewsRecycler {

    struct ViewStatus {
        var view:BXView
        var available:Bool
    }
    // Classifyed recyclable views
    fileprivate var _recyclableViews=[String:[BXView]]()

    // We keep a reference on all views.
    fileprivate var _viewsStatus=[ViewStatus]()

    // You can for performance tuning determine a min distance to determine what should be considerated as recyclable
    var minOffScreenDistance:CGFloat = 100

    /// Purges all the views (e.g on view controller deinit)
    func purgeViews(){
        while let vs = self._viewsStatus.popLast(){
            vs.view.removeFromSuperview()
        }
        self._recyclableViews.removeAll()
    }

    /// You must call this method regularly to recycle off screen views.
    func recycleRecyclableViews(){
        for vs in self._viewsStatus{
            if let superview = vs.view.superview{
                if  vs.view.frame.x + vs.view.frame.width + self.minOffScreenDistance < superview.frame.x ||
                    vs.view.frame.x > superview.frame.x + superview.frame.width + self.minOffScreenDistance ||
                    vs.view.frame.y + vs.view.frame.height + self.minOffScreenDistance < superview.frame.y ||
                    vs.view.frame.y > superview.frame.y + superview.frame.height + self.minOffScreenDistance {
                    self._recycleView(view: vs.view)
                }
            }
        }
    }

    /// Returns a Recyclable view
    ///
    /// - Parameter viewFactory: the factory method to create a new view
    /// - Returns: the view
    func getARecyclableView<T:BXView>(viewFactory:()->(T))->T{
        if let view = self._recyclableViews[T.className()]?.popLast() as? T{
            return view
        }
        let view = viewFactory()
        let vs = ViewStatus(view: view, available: false)
        self._viewsStatus.append(vs)
        return view
    }

    // MARK: - Private implementation



    /// Recycles a view
    ///
    /// - Parameters:
    ///   - view: the view to recycle
    ///   - groupedBy: its group
    fileprivate func _recycleView(view:BXView){
        var group:[BXView]!
        if let existingGroup=_recyclableViews[view.className] {
            group = existingGroup
        }else{
            group = [BXView]()
        }
        group.append(view)
        view.removeFromSuperview()
        self._recyclableViews[view.className]=group

        // Update the view status
        if var vs = self._viewsStatus.first(where: { (viewStatus) -> Bool in
            return viewStatus.view == view
        }){
            vs.available = true
        }
    }
    
    
    
    
    
}
