//
//  BartlebyDocument+Metrics.swift
//  BartlebyKit
//
//  Created by Benoit Pereira da silva on 24/10/2016.
//
//

import Foundation

extension BartlebyDocument{

    open func report(_ metrics:Metrics){
        metrics.counter=self.metrics.count+1
        metrics.elapsed=Bartleby.elapsedTime
        self.metrics.append(metrics)
    }

}
