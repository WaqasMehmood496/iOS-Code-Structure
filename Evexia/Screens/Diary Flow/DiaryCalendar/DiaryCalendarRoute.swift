//
//  DiaryCalendarRoute.swift
//  Evexia
//
//  Created by admin on 13.09.2021.
//

import Foundation
import Combine

protocol DiaryCalendarRoute {

    var diaryCalendarTransition: Transition { get }
    
    func showDiaryCalendar(selectedDate: CurrentValueSubject<Date, Never>)
}

extension DiaryCalendarRoute where Self: RouterProtocol {
    func showDiaryCalendar(selectedDate: CurrentValueSubject<Date, Never>) {
        let vc = DiaryCalendarBuilder.build(router: DiaryCalendarRouter(injector: injector), selectedDate: selectedDate)
        open(vc, transition: diaryCalendarTransition)
    }
}
