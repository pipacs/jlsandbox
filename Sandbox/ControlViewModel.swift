//
//  ControlViewModel.swift
//  Sandbox
//
//  Created by EzioChan on 2025/4/21.
//

import UIKit
import JL_BLEKit

class ControlViewModel: NSObject {
    let share = ControlViewModel()
    
    static func getEQ(_ result:@escaping (JL_SystemEQ?)->Void) {
        JieliManager.shared.jlManager.cmdGetSystemInfo(.COMMON) { state, _,_  in
            let eqInfo = JieliManager.shared.jlManager.mSystemEQ
            if state == .success {
                result(eqInfo)
            } else {
                result(nil)
            }
        }
    }

}
