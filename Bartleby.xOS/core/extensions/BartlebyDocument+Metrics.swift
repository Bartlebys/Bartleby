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
        metrics.document=self
        if metrics.streamOrientation == .upStream{
            self.metadata.totalNumberOfUpMetrics += 1
            self.metadata.cumulatedUpMetricsDuration += metrics.totalDuration
            // Simple computation of the average total duration.
            self.metadata.qosIndice = self.metadata.cumulatedUpMetricsDuration/Double(self.metadata.totalNumberOfUpMetrics)
        }
        self.metrics.append(metrics)
    }

}
