//
//  DiaryCalendarBuilder.swift
//  Evexia
//
//  Created by admin on 06.09.2021.
//

import Foundation
import Combine

final class DiaryCalendarBuilder {
    static func build(router: DiaryCalendarRouter, selectedDate: CurrentValueSubject<Date, Never>) -> DiaryCalendarVC {
        let vc = DiaryCalendarVC.board(name: .diaryCalendar)
        router.viewController = vc
        let repository = DiaryCalnedarRepository(diaryNetworkProvider: router.injector.resolve(DiaryNetworkProvider.self)!)
        let viewModel = DiaryCalendarVM(router: router, repository: repository, selectedDate: selectedDate)
        vc.viewModel = viewModel
        return vc
    }
}
