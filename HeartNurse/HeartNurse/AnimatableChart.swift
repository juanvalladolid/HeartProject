//
//  AnimatableChart.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 27/07/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import ResearchKit

protocol AnimatableChart {
    func animateWithDuration(animationDuration: NSTimeInterval)
}

//extension ORKPieChartView: AnimatableChart {}
extension ORKDiscreteGraphChartView: AnimatableChart {}
extension ORKLineGraphChartView: AnimatableChart {}