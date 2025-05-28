//
//  RunningSpotSection.swift
//  WeatherBoso
//
//  Created by 김재우 on 5/26/25.
//

import RxDataSources

struct RunningSpotSection {
    var items: [RunningSpot]
}

extension RunningSpotSection: SectionModelType {
    typealias Item = RunningSpot
    
    init(original: RunningSpotSection, items: [Item]) {
        self = original
        self.items = items
    }
}
