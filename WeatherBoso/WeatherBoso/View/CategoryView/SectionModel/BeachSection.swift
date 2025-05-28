//
//  BeachSection.swift
//  WeatherBoso
//
//  Created by 김기태 on 5/23/25.
//

import RxDataSources

struct BeachSection {
    var items: [Beach]
}

extension BeachSection: SectionModelType {
    typealias Item = Beach
    
    init(original: BeachSection, items: [Item]) {
        self = original
        self.items = items
    }
}
