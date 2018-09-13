//
//  NSDate+Helper.swift
//  machApp
//
//  Created by Nicolas Palmieri on 3/3/17.
//  Copyright © 2017 Sismo. All rights reserved.
//

import Foundation

extension Date {

    @nonobjc static let calendar: Calendar = Date.getUTCCalendar()

    private static func getUTCCalendar() -> Calendar {
        var calendar: Calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        return calendar
    }

    // MARK: - Date Formatters
    func getDateFormatter(format: String) -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Locale.current
        return dateFormatter
    }

    func getISODateFormatter() -> DateFormatter {
        return getDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
    }

    func getHourAndMinutesFormatter() -> DateFormatter {
        return getDateFormatter(format: "HH:mm")
    }

    func getMM_yyyyDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "MM/yyyy")
    }

    func getMM_dd_yyyyDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "MM/dd/yyyy")
    }

    func getdd_MM_yyDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "dd/MM/yy")
    }

    func getyyyy_MMDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "yyyy-MM")
    }

    func getMssqlDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")
    }

    func getMssqlTTDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.S'T'Z")
    }

    func getMMM_ddDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "MMM dd")
    }

    func getMMM_dd_yyyyDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "MMM dd, yyyy")
    }

    func getMMMMFormatter() -> DateFormatter {
         return getDateFormatter(format: "MMM")
    }

    func getDD_MMDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "dd/MM")
    }

    func getMM_ddDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "MM/dd")
    }
    
    func getMMMMDDateFormatter() -> DateFormatter {
        return getDateFormatter(format: "MMMM d")
    }

    func getShortRelativeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        return formatter
    }

    func getMediumRelativeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        return formatter
    }

    // MARK: - Date Modifiers

    func getDate(year: Int, month: Int, day: Int) -> Date? {
        var datecomps: DateComponents = DateComponents()
        datecomps.year = year
        datecomps.month = month
        datecomps.day = day
        datecomps.second = 1
        datecomps.timeZone = Calendar.current.timeZone
        return Date.calendar.date(from: datecomps)
    }

    func dateByAddingDays(days: Int) -> Date? {
        let calendar: Calendar = Calendar.current
        return calendar.date(byAdding: Calendar.Component.day, value: days, to: self, wrappingComponents: false)
    }

    // MARK: - Date strings

    func getDayMonthDate() -> String {
        let dateFormatter: DateFormatter = getDD_MMDateFormatter()
        return dateFormatter.string(from: self)
    }

    func getMonthDayDate() -> String {
        let dateFormatter: DateFormatter = getMM_ddDateFormatter()
        return dateFormatter.string(from: self)
    }

    func dateForString(dateString: String) -> Date? {
        let dateFormatter: DateFormatter = getMM_dd_yyyyDateFormatter()
        return dateFormatter.date(from: dateString)
    }

    func stringForDate() -> String {
        let dateFormatter: DateFormatter = getMM_dd_yyyyDateFormatter()
        return dateFormatter.string(from: self)
    }

    func redactedStringForDate() -> String {
        let dateFormatter: DateFormatter = getMMM_dd_yyyyDateFormatter()
        return dateFormatter.string(from: self)
    }

    func monthForDate() -> String {
        let dateFormatter = getMMMMFormatter()
        return dateFormatter.string(from: self)
    }

    func isoStringForDate() -> String {
        let dateFormatter: DateFormatter = getISODateFormatter()
        return dateFormatter.string(from: self)
    }

    func dateFromISOString(isoDateString: String) -> Date? {
        if #available(iOS 11.0, *) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            formatter.timeZone = Calendar.current.timeZone
            return formatter.date(from: isoDateString)
        } else {
            let dateFormatter: DateFormatter = getISODateFormatter()
            return dateFormatter.date(from: isoDateString)
        }
    }

    func getShortAndRelativeStringForDate() -> String {
        return getShortRelativeDateFormatter().string(from: self)
    }

    func getMediumAndRelativeStringForDate() -> String {
        return getMediumRelativeDateFormatter().string(from: self)
    }

    func getHourAndMinutes() -> String {
        let dateFormatter = getHourAndMinutesFormatter()
        return dateFormatter.string(from: self)
    }

    func dateWithoutTime() -> Date? {

        return getDate(year: self.year, month: self.month, day: self.day)
    }

    func getDaysMonthYear() -> String {
        let dateFormatter = getdd_MM_yyDateFormatter()
        return dateFormatter.string(from: self)
    }
    
    func getMonthDate() -> String {
        let dateFormatter = getMMMMDDateFormatter()
        return dateFormatter.string(from: self)
    }

    // MARK: - Validators

    func isCurrentMonth() -> Bool {
        let dateComponents: DateComponents = Date.calendar.dateComponents([.month], from: self)
        let nowComponents: DateComponents = Date.calendar.dateComponents([.month], from: Date())
        return dateComponents.month == nowComponents.month
    }

    func getRelativeDateAndTime() -> String {
        return self.getMediumAndRelativeStringForDate() + " " + self.getHourAndMinutes()
    }

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        //swiftlint:disable:next force_unwrapping
        return Calendar.current.date(from: components)!
    }

    func addMonths(number: Int) -> Date {
        //swiftlint:disable:next force_unwrapping
        return Calendar.current.date(byAdding: .month, value: number, to: self)!
    }
    
    func addMinutes(number: Int) -> Date {
        //swiftlint:disable:next force_unwrapping
        return Calendar.current.date(byAdding: .minute, value: number, to: self)!
    }
}

public func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs as Date) == .orderedSame
}

public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs as Date) == .orderedAscending
}

extension NSDate: Comparable { }
