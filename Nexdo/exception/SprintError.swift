import Foundation

enum SprintError : Error {
    case overlappingDates(start: Date, end: Date)
}
