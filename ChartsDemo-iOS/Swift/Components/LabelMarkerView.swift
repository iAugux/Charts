//
//  LabelMarkerView.swift
//  ChartsDemo-iOS-Swift
//
//  Created by WangLei on 2018/10/23.
//  Copyright © 2018 dcg. All rights reserved.
//

import Foundation
import Charts

public class LabelMarkerView: BalloonMarker {
    public var xAxisValueFormatter: IAxisValueFormatter
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: IAxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let string = xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())
        setLabel(string)
    }
}
