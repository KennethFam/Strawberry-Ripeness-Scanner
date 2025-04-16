//
//  SideMenuRowType.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/16/25.
//

enum SideMenuRowType: Int, CaseIterable {
    case tutorial
    case ripenessGuide
    case support
    
    var title: String {
        switch self {
        case .tutorial:
            return "Tutorial"
        case .ripenessGuide:
            return "Ripeness Guide"
        case .support:
            return "Contact Support"
        }
    }
    
    var iconName: String {
        switch self {
            case .tutorial:
            return "questionmark.circle"
        case .ripenessGuide:
            return "book"
        case .support:
            return "envelope"
        }
    }
    
    var pathCase: ScanPath {
        switch self {
        case .tutorial:
            return .tutorial
        case .ripenessGuide:
            return .ripenessGuide
        case .support:
            return .support
        }
    }
}
