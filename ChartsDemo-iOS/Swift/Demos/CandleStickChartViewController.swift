//
//  CandleStickChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

private let BAR_WIDTH: CGFloat = 0.65
private let MIN_K_W: CGFloat = 1
private let MAX_K_H: CGFloat = 12
private let INCREASING_FILLED = false

class CandleStickChartViewController: DemoBaseViewController {

    @IBOutlet var chartView: CandleStickChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        chartView.backgroundColor = .clear
        chartView.noDataText = ""
        chartView.chartDescription = nil
        chartView.minOffset = 0
        chartView.legend.enabled = false
        chartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        
        chartView.delegate = self
        chartView.dragEnabled = true
        chartView.scaleYEnabled = false
        chartView.autoScaleMinMaxEnabled = true
        chartView.dragDecelerationEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.dragDecelerationFrictionCoef = 0.2
        chartView.highlightPerTapEnabled = true
        
        let rightAxis = chartView.rightAxis
        rightAxis.labelPosition = .insideChart
        rightAxis.labelTextColor = #colorLiteral(red: 0.3607843137, green: 0.3647058824, blue: 0.4, alpha: 1)
        rightAxis.gridLineWidth = 1
        rightAxis.gridColor = UIColor(white: 0, alpha: 0.04)
        rightAxis.drawAxisLineEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.gridLineWidth = 1
        xAxis.gridColor = UIColor(white: 0, alpha: 0.04)
        xAxis.drawAxisLineEnabled = false
        xAxis.setLabelCount(5, force: true)
        
        rightAxis.yOffset = -6
        rightAxis.setLabelCount(5, force: true)
        
        xAxis.drawLabelsEnabled = false
        
        slidersValueChanged(nil)
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(sliderX.value), range: UInt32(sliderY.value))
        
        makeChartsReadeable(with: Int(sliderX.value))
    }
    
    private func makeChartsReadeable(with count: Int) {
        guard count > 0 else { return }
        
        let width = CGFloat(view.bounds.width)
        let count = CGFloat(count)
        let per = width / count
        let min = MIN_K_W / per
        let max = MAX_K_H / per
        
        func set(_ chartView: CandleStickChartView) {
            let viewPortHandler = chartView.viewPortHandler
            viewPortHandler?.setMinimumScaleX(min)
            viewPortHandler?.setMaximumScaleX(max)
        }
        
        set(chartView)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let yVals1 = (0..<count).map { (i) -> CandleChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(40) + mult)
            let high = Double(arc4random_uniform(9) + 8)
            let low = Double(arc4random_uniform(9) + 8)
            let open = Double(arc4random_uniform(6) + 1)
            let close = Double(arc4random_uniform(6) + 1)
            let even = i % 2 == 0
            
            return CandleChartDataEntry(x: Double(i), shadowH: val + high, shadowL: val - low, open: even ? val + open : val - open, close: even ? val - close : val + close, icon: UIImage(named: "icon")!)
        }
        
        let set1 = CandleChartDataSet(values: yVals1, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = .red
        set1.decreasingFilled = true
        set1.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set1.increasingFilled = true
        set1.neutralColor = .blue
        set1.verticalHighlightColor = #colorLiteral(red: 0.4392156863, green: 0.5254901961, blue: 0.9019607843, alpha: 0.2)
        set1.highlightColor = #colorLiteral(red: 0.1568627451, green: 0.1607843137, blue: 0.1803921569, alpha: 1)
        
        let marker = LabelMarkerView(color: .black,
                                     font: UIFont(name: "Avenir-Book", size: 10)!,
                                     textColor: .white,
                                     insets: UIEdgeInsets(top: 1, left: 3, bottom: 0, right: 4),
                                     xAxisValueFormatter: chartView.rightAxis.valueFormatter!)
        
        marker.fixedX = chartView.viewPortHandler.chartWidth
        marker.arrowSize = .zero
        marker.offsetPoint = CGPoint(x: 0, y: 14 / 2)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 46, height: 14)
        chartView.marker = marker
        
        let viewPortHandler = chartView.viewPortHandler
        viewPortHandler?.setMaximumScaleX(300 * 5 / 127)
        let transform = CGAffineTransform(scaleX: CGFloat.greatestFiniteMagnitude, y: 1)
        viewPortHandler?.refresh(newMatrix: transform, chart: chartView, invalidate: false)
        
        let data = CandleChartData(dataSet: set1)
        chartView.data = data
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleShadowColorSameAsCandle:
            for set in chartView.data!.dataSets as! [CandleChartDataSet] {
                set.shadowColorSameAsCandle = !set.shadowColorSameAsCandle
            }
            chartView.notifyDataSetChanged()
        case .toggleShowCandleBar:
            for set in chartView.data!.dataSets as! [CandleChartDataSet] {
                set.showCandleBar = !set.showCandleBar
            }
            chartView.notifyDataSetChanged()
        default:
            super.handleOption(option, forChartView: chartView)
        }
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        self.updateChartData()
    }}
