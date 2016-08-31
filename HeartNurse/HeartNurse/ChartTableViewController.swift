//
//  ChartTableViewController.swift
//  HeartNurse
//
//  Created by Juan Valladolid on 27/07/16.
//  Copyright © 2016 DTU. All rights reserved.
//

import UIKit
import ResearchKit

class ChartTableViewController: UITableViewController {
    
    let dataService = FirebaseService()

    
    let weightGraphDataSource = WeightGraphDataSource()
    let bloodPressureGraphDataSource = BloodPressureGraphDataSource()
    let heartRateGraphDataSource = HeartRateGraphDataSource()
    
    var userSelected = User()
    var weights = [Weight]()
    var bloodPressureSamples = [BloodPressure]()
    var heartRateSamples = [HeartRate]()
    
    var patientSelected = SummaryPatient()
    
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightDetailsLabel: UILabel!
    @IBOutlet weak var weightDateLabel: UILabel!
    
    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var bloodPressureDateLabel: UILabel!
    @IBOutlet weak var bloodPressureDetailsLabel: UILabel!
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var heartRateDetailsLabel: UILabel!
    @IBOutlet weak var heartRateDateLabel: UILabel!
    
    
    @IBOutlet weak var weightIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bloodPressureIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var heartRateIndicator: UIActivityIndicatorView!
    
    var detailPatient: SummaryPatient? {
        didSet {
            
        }
    }
    
    var detailItem: User? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
    

    
    @IBOutlet weak var weightGraph: ORKLineGraphChartView!
    
    @IBOutlet weak var bloodPressureGraph: ORKDiscreteGraphChartView!
    
    @IBOutlet var heartRateGraph: ORKDiscreteGraphChartView!
    
    
    
    
    
    var allCharts: [UIView] {
        return [weightGraph, bloodPressureGraph, heartRateGraph]
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let user = self.detailItem {
            self.navigationItem.title = user.userName
            self.userSelected = user
            print("from configure view, the user: ", user.userName)
            
            dataService.fetchWeightSamples(user.userName, callback: populateWeightData)

            dataService.fetchHeartRateSamples(user.userName, callback: populateHeartRateData)

            dataService.fetchBloodPressureSamples(user.userName, callback: populateBloodPressureData)
        } else 
        
        if let patient = self.detailPatient {
            self.navigationItem.title = patient.userName
            self.patientSelected = patient
            print("from configure view, the user: ", patient.userName)
            
            dataService.fetchWeightSamples(patient.userName, callback: populateWeightData)
            
            dataService.fetchHeartRateSamples(patient.userName, callback: populateHeartRateData)
            
            dataService.fetchBloodPressureSamples(patient.userName, callback: populateBloodPressureData)
        }

    }
    
    
    func populateHeartRateData(heartRate: [HeartRate]) -> Void {
        
        self.heartRateIndicator.startAnimating()

        self.heartRateSamples = heartRate

        var calculateMax = [Float]()
        
        var heartRateMeasuresOutter = [[ORKRangedPoint]]()
        var heartRateMeasuresInner = [ORKRangedPoint]()
        var dateXAxis = [NSDate]()
        var indexHeartRate = [Int]()
        
        
        var newAverageSum: Float = 0
        var newAverageHR: Float = 0
        
        
        
        // DATES ARRAY
        let cal = NSCalendar.currentCalendar()
        var date = NSDate()
        
        for _ in 1 ... 14 {
            dateXAxis.append(date)
            
            date = cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
            
        }
        
        for i in 0 ..< dateXAxis.count {
            
            let styler = NSDateFormatter()
            styler.dateFormat = "dd-MM-yyyy"
            let dateAxisString = styler.stringFromDate(dateXAxis[i])
            
            for j in 0 ..< self.heartRateSamples.count {
                
                let dateWeightShorter = self.heartRateSamples[j].date.substringWithRange(self.heartRateSamples[j].date.startIndex.advancedBy(0) ..< self.heartRateSamples[j].date.startIndex.advancedBy(10))
                
                //print("this is Axis: ", AxisString, "- this is from health: ", dateShorter)
                if dateAxisString == dateWeightShorter  {
                    //print("- Found equals", j, i,  heartRateSamples[j].measurement, dateWeightShorter)
                    indexHeartRate.append(i)
                    
                }
            }
            
            let visualPoint = ORKRangedPoint()
            
            
            heartRateMeasuresInner.append(visualPoint)
            //print("- If part 1", weightMeasuresInner, indexWeights)
        }
        
        
        for i in 0 ..< indexHeartRate.count {
            
            let measurement = CGFloat(heartRateSamples[i].measurement)
            let visualPoint = ORKRangedPoint(value: measurement)
            heartRateMeasuresInner[indexHeartRate[i]] = visualPoint
            
            calculateMax.append(self.heartRateSamples[i].measurement)
            
            newAverageSum += self.heartRateSamples[i].measurement
            newAverageHR = newAverageSum / Float(self.heartRateSamples.count)
            
           
            //print("Belong: ", bloodPressureSamples[i].date, i, bloodPressureSamples[i].systolic, bloodPressureSamples[i].diastolic)
            
        }
        //print("- Array of Heart RAtes max: ",calculateMax)
        heartRateMeasuresOutter.append(heartRateMeasuresInner.reverse())
        
        var maxValue : Float = 0.0
        var minValue : Float = 0.0
        
        if(calculateMax.count > 0)
        {
            maxValue = calculateMax.maxElement()!
            minValue = calculateMax.minElement()!
        }
        
        //print("MAx value heart rate_ ", maxValue, minValue)
        dispatch_async(dispatch_get_main_queue()) {

            if self.heartRateSamples.count > 0 {
                
                self.heartRateLabel.text = "Heart Rate   " + String(self.heartRateSamples[0].measurement) + " bpm"
                self.heartRateDetailsLabel.text = "Average: " + String(format: "%.2f", newAverageHR) + "   Max: " + String(maxValue) + "   Min: " + String(minValue)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM dd" // month and day superset of OP's format
                
                self.heartRateDateLabel.text = HelperFunctions.shortString(self.weights[0].date)

            }
            
            // plot settings
            self.heartRateGraphDataSource.plotPoints = heartRateMeasuresOutter
            self.heartRateGraphDataSource.heartRateChartXaxis = dateXAxis.reverse()
            self.heartRateGraphDataSource.maxValue = CGFloat(maxValue)
            //self.heartRateGraphDataSource.minValue = CGFloat(minValue)
            //print(dateXAxis.count, dateXAxis[0], dateXAxis[6])
            
            
            // Sends above settings to data source class
            self.heartRateGraph.dataSource = self.heartRateGraphDataSource
            self.tableView.reloadData()
            
            self.heartRateIndicator.stopAnimating()


        }
    }
    
    
    func populateBloodPressureData(bloodPressure: [BloodPressure]) -> Void {
        
        self.bloodPressureIndicator.startAnimating()

        self.bloodPressureSamples = bloodPressure
        
        var calculateMin = [Float]()
        var calculateMax = [Float]()

        var bpMeasuresOutter = [[ORKRangedPoint]]()
        var bpMeasuresInner = [ORKRangedPoint]()
        var dateXAxis = [NSDate]()
        var indexBP = [Int]()
        
        
        // DATES ARRAY
        let cal = NSCalendar.currentCalendar()
        var date = NSDate()
        //        print("first date: ", date)
        
        for _ in 1 ... 14 {
            dateXAxis.append(date)
            
//            let styler = NSDateFormatter()
//            styler.dateFormat = "dd-MM-yyyy"
//            let newDateString = styler.stringFromDate(date)
            
            //print(i,  "NSDATE:", date, "String: ", newDateString)
            
            
            date = cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
            
        }
        
        for i in 0 ..< dateXAxis.count {
            
            let styler = NSDateFormatter()
            styler.dateFormat = "dd-MM-yyyy"
            let dateAxisString = styler.stringFromDate(dateXAxis[i])
            
            for j in 0 ..< self.bloodPressureSamples.count {
                
                let dateWeightShorter = self.bloodPressureSamples[j].date.substringWithRange(self.bloodPressureSamples[j].date.startIndex.advancedBy(0) ..< self.bloodPressureSamples[j].date.startIndex.advancedBy(10))
                
                //print("this is Axis: ", AxisString, "- this is from health: ", dateShorter)
                if dateAxisString == dateWeightShorter  {
                    //print("- Found equals", j, i,  bloodPressureSamples[j].systolic, "/", bloodPressureSamples[j].diastolic)
                    indexBP.append(i)
                    
                }
            }
            
            let visualPoint = ORKRangedPoint()
            
            
            bpMeasuresInner.append(visualPoint)
            //print("- If part 1", weightMeasuresInner, indexWeights)
        }
        
        
        for i in 0 ..< indexBP.count {
            
            let systolic = CGFloat(bloodPressureSamples[i].systolic)
            let diastolic = CGFloat(bloodPressureSamples[i].diastolic)
            let visualPoint = ORKRangedPoint(minimumValue: diastolic, maximumValue: systolic)
            bpMeasuresInner[indexBP[i]] = visualPoint
            
            calculateMax.append(self.bloodPressureSamples[i].systolic)
            calculateMin.append(self.bloodPressureSamples[i].diastolic)
            


            //print("Belong: ", bloodPressureSamples[i].date, i, bloodPressureSamples[i].systolic, bloodPressureSamples[i].diastolic)
            
        }
        
        bpMeasuresOutter.append(bpMeasuresInner.reverse())
        
        var maxValue : Float = 0.0
        var minValue : Float = 0.0
        
        if(calculateMin.count > 0)
        {
            maxValue = calculateMax.maxElement()!
            minValue = calculateMin.minElement()!
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if self.bloodPressureSamples.count > 0 {
                
                self.bloodPressureLabel.text = "Blood Pressure   S: " + String(self.bloodPressureSamples[0].systolic) + " / D: " + String(self.bloodPressureSamples[0].diastolic) + " mmHg"
                self.bloodPressureDetailsLabel.text = "Max SBP: " + String(maxValue) + "   Min SBP: " + String(minValue)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM dd" // month and day superset of OP's format
                
                self.bloodPressureDateLabel.text = HelperFunctions.shortString(self.bloodPressureSamples[0].date)

            }
            
        
            // plot settings
            self.bloodPressureGraphDataSource.plotPoints = bpMeasuresOutter
            self.bloodPressureGraphDataSource.bloodPressureChartXaxis = dateXAxis.reverse()
            self.bloodPressureGraphDataSource.maxValue = CGFloat(maxValue)
            self.bloodPressureGraphDataSource.minValue = CGFloat(minValue)
            //print(dateXAxis.count, dateXAxis[0], dateXAxis[6])
            
            
            // Sends above settings to data source class
            self.bloodPressureGraph.dataSource = self.bloodPressureGraphDataSource
            self.tableView.reloadData()
            
            self.bloodPressureIndicator.stopAnimating()

        }

        
        
    }
    
    func populateWeightData(weight: [Weight]) -> Void {
        
        self.weightIndicator.startAnimating()

        self.weights = weight
        //print("- Number of weights: ", weights.count)
        var calculateMinMax = [Float]()
        var calculateMinValue = [Float]()
        
        var weightMeasuresOutter = [[ORKRangedPoint]]()
        var weightMeasuresInner = [ORKRangedPoint]()
        var dateXAxis = [NSDate]()
        var indexWeights = [Int]()
        
        var newAverageSum: Float = 0
        var newAverageWeight: Float = 0
        
        
        
        // DATES ARRAY
        let cal = NSCalendar.currentCalendar()
        var date = NSDate()
        //        print("first date: ", date)
        
        for _ in 1 ... 14 {
            dateXAxis.append(date)
            
            let styler = NSDateFormatter()
            styler.dateFormat = "dd-MM-yyyy"
            //let newDateString = styler.stringFromDate(date)
            
            //print(i,  "NSDATE:", date, "String: ", newDateString)
            
            
            date = cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
            
        }
        
        // one week
//        for _ in 1 ... 7 {
//            dateXAxis.append(date)
//            
//            let styler = NSDateFormatter()
//            styler.dateFormat = "dd-MM-yyyy"
//            //let newDateString = styler.stringFromDate(date)
//            
//            //print(i,  "NSDATE:", date, "String: ", newDateString)
//            
//            
//            date = cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
//            
//        }
        // ENDS DATES ARRAY
        
        
        for i in 0 ..< dateXAxis.count {
            
            let styler = NSDateFormatter()
            styler.dateFormat = "dd-MM-yyyy"
            let dateAxisString = styler.stringFromDate(dateXAxis[i])
            
            for j in 0 ..< self.weights.count {
                
                let dateWeightShorter = self.weights[j].date.substringWithRange(self.weights[j].date.startIndex.advancedBy(0) ..< self.weights[j].date.startIndex.advancedBy(10))
                
                if dateAxisString == dateWeightShorter  {
                    print("- Found equals", j, i,  weights[j].measurement, dateAxisString, dateWeightShorter)
                    indexWeights.append(i)
//                    calculateMinMax.append(weights[j].measurement)

                    
                }
            }
            
            let visualPoint = ORKRangedPoint()
            
            // creates empty arrays to add weights not equal
            weightMeasuresInner.append(visualPoint)
            calculateMinMax.append(0.0)

        }
        //print("- Indexes weight", indexWeights,  calculateMinMax )
        
        
        for i in 0 ..< indexWeights.count {
            
            let pointFloat = CGFloat(weights[i].measurement)
            let visualPoint = ORKRangedPoint(value: pointFloat)
            weightMeasuresInner[indexWeights[i]] = visualPoint
            
            //calculateMinMax.append(self.weights[i].measurement)
            calculateMinMax[indexWeights[i]] = self.weights[i].measurement
            
            //print("Belong: \(weights[i].date)", i, indexWeights[i], weights[i].measurement)
            
        }

        for i in 0 ..< calculateMinMax.count {
            
            if calculateMinMax[i] != 0.0 {
                calculateMinValue.append(calculateMinMax[i])
            }
            
            print(calculateMinMax[i])

        }
        
        for i in 0 ..< calculateMinValue.count {
            
            newAverageSum += calculateMinValue[i]
            newAverageWeight = newAverageSum / Float(calculateMinValue.count)
            
        }
        
        
        weightMeasuresOutter.append(weightMeasuresInner.reverse())
        
        var maxValue : Float = 0.0
        var minValue : Float = 0.0
        
        if calculateMinMax.count > 0 && calculateMinValue.count > 0
        {
            maxValue = calculateMinMax.maxElement()!
            minValue = calculateMinValue.minElement()!
        }
        
        print("WEIGHT: ", maxValue, minValue, newAverageWeight)
        dispatch_async(dispatch_get_main_queue()) {

            if self.weights.count > 0 {
                
                self.weightLabel.text = "Weight   " + String(calculateMinMax[0]) + " kg"
                self.weightDetailsLabel.text = "Average: " + String(format: "%.2f", newAverageWeight) + "   Max: " + String(maxValue) + "   Min: " + String(minValue)
                
                self.weightDateLabel.text = HelperFunctions.shortString(self.weights[0].date)
                
                
                if calculateMinMax[0] == 0 {
                    self.weightDateLabel.text = "No weight update today yet "
                } else
                
                if calculateMinMax[3] != 0 {
                    
                    let weightDifference = calculateMinMax[0] - calculateMinMax[3]
                    self.weightDateLabel.text = "Difference Past 3 days: " +  String(format: "%.2f", weightDifference) + " kg   " + HelperFunctions.shortString(self.weights[0].date)
                    
                } else if calculateMinMax[3] != 0 {
                    let weightDifference = calculateMinMax[0] - calculateMinMax[3]
                    self.weightDateLabel.text = "Difference Past 2 days: " + String(format: "%.2f", weightDifference) + " kg   " + HelperFunctions.shortString(self.weights[0].date)
                }
                

            }
            
            
            // plot settings
            self.weightGraphDataSource.plotPoints = weightMeasuresOutter
            self.weightGraphDataSource.lineChartXaxis = dateXAxis.reverse()
            self.weightGraphDataSource.maxValue = CGFloat(maxValue)
            self.weightGraphDataSource.minValue = CGFloat(minValue)
            //print(dateXAxis.count, dateXAxis[0], dateXAxis[6])
            
            
            // Sends above settings to data source class
            self.weightGraph.dataSource = self.weightGraphDataSource
            

            self.tableView.reloadData()
            
            self.weightIndicator.stopAnimating()

        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        
        // Set the table view to automatically calculate the height of cells.
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        weightGraph.showsHorizontalReferenceLines = true
        //lineGraphNew.showsVerticalReferenceLines = true

        //lineGraphNew.axisColor = nil
        
        // Vertical Axis color
        //lineGraphNew.verticalAxisTitleColor = UIColor.redColor()
        
        
        // Line Ccrubber color
        weightGraph.scrubberLineColor = UIColor.blackColor()
        weightGraph.scrubberThumbColor = UIColor.whiteColor()
        
        // Graph color
        weightGraph.tintColor = UIColor.blueColor()
        heartRateGraph.tintColor = UIColor.redColor()
       
        
               // let controller2 = controller1.viewControllers?.first as! UINavigationController
        
        //let controller = controller2.topViewController as! ChartTableViewController
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEW WILL APPEAR")

        
        // Animate any visible charts
        let visibleCells = tableView.visibleCells
        let visibleAnimatableCharts = visibleCells.flatMap { animatableChartInCell($0) }
        
        for chart in visibleAnimatableCharts {
            chart.animateWithDuration(0.5)
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Animate charts as they're scrolled into view.
        if let animatableChart = animatableChartInCell(cell) {
            animatableChart.animateWithDuration(1)
        }
    }
    
    // MARK: Convenience
    
    func animatableChartInCell(cell: UITableViewCell) -> AnimatableChart? {
        for chart in allCharts {
            guard let animatableChart = chart as? AnimatableChart where chart.isDescendantOfView(cell) else { continue }
            return animatableChart
        }
        
        return nil
    }
    
    
    
}
