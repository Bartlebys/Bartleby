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

        self.metadata.totalNumberOfMetrics += 1
        self.metadata.cumulatedMetricsDuration += metrics.totalDuration
        // Simple computation of the average total duration.
        self.metadata.qosIndice = self.metadata.cumulatedMetricsDuration/Double(self.metadata.totalNumberOfMetrics)
        self.metrics.append(metrics)
    }

}
