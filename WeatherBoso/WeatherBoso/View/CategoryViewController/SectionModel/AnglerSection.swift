//
//  AnglerSection.swift
//  WeatherBoso
//
//  Created by 강성훈 on 5/27/25.
//
import RxDataSources

struct AnglerSection {
    var header: String
    var items: [Angler]
}

extension AnglerSection: SectionModelType {
    typealias Item = Angler

    init(original: AnglerSection, items: [Angler]) {
        self = original
        self.items = items
    }
}

