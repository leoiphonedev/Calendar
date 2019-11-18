//
//  MonthCell.swift
//  AACalendar
//
//  Created by Aman Aggarwal on 3/24/17.
//  Copyright © 2017 ClickApps. All rights reserved.
//

import UIKit
protocol MonthCellDelegate {
    func dateSelected(date: String)
    func selectedDate(withDay day:Int, month:Int, andYear year:Int, returnDate:String)
    func showAlertAsUnAvailableDatesraeinBetweenSelectedDate()
}
class MonthCell: UITableViewCell {
    
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var lblMonthName: UILabel!
    
    var weekDayNamesArray:[String] = Array()
    var currentMonth : Int!
    var currentYear : Int!
    var firstDateSelected: String!
    var secondDateSelected: String!
    var isHotelSelectionCalendar = false
    
    var takenDateArray = NSMutableArray()
    
    var formatter:DateFormatter!
    
    @IBOutlet var hgtConstraint: NSLayoutConstraint!
    
    var delegate : MonthCellDelegate!
    public var isMultiDateSelection = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if formatter == nil {
            formatter = DateFormatter.init()
        }
        weekDayNamesArray = returnWeekDayArray()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createCalendar(withMonth month:Int, andYear year: Int)  {
        
       // let dateCurrent = Date()
       // let calendar = Calendar.current
        currentYear = year //calendar.component(.year, from: dateCurrent)
        
        currentMonth = month
        
        let date = returnDateFormatter().date(from:String(format: "1/%d/%d",currentMonth, currentYear))//"1/\\\(month)/\\\(year)"
        let numberOfDays = getNumberOfDays(inMonth: month, withDate: date!)
        let  weekDay = getFirstWeekDay(forDate: date!)
        createMonthWith(numberofDays: numberOfDays, andStartingWeekDay: weekDay)
        
        let dateStr = returnMonthFormatter().string(from: date!)
        let arrayComp = dateStr.components(separatedBy: "/")
        if arrayComp.count == 3 {
            lblMonthName.text = String(format: "%@ %@", arrayComp[1].uppercased(),arrayComp[2])
            /*lblMonthName.font = Fonts.heavyFontWithSize(size: 17.0)
            Utility.addLetterSpacing(toLabel: lblMonthName, withLetterSpace: 0.32)*/
        }
    }
    
    func returnDateFormatter() -> DateFormatter {
        
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        
        // formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }
    
    func returnDateWithYearFirstFormatter() -> DateFormatter {
        
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        
        // formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }
    
    
    func returnMonthFormatter() -> DateFormatter {
        
        formatter.dateFormat = "dd/MMM/yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        
        // formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }
    
    func returnWeekDayArray() -> Array<String> {
        
        return formatter.veryShortWeekdaySymbols
    }
    
    func getNumberOfDays(inMonth month:Int, withDate date:Date) -> Int {
        
        let cal = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.month = month
        let range = cal.range(of: .day, in: .month, for: date)
        return (range?.count)!
    }
    
    func getFirstWeekDay(forDate date:Date) -> Int {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.weekday], from: date)
        return dateComponents.weekday!
    }
    
    func createMonthWith(numberofDays days:Int, andStartingWeekDay weekday:Int )  {

        for vw in scrollContentView.subviews {
            if vw.tag != 300 {
                vw.removeFromSuperview()
            }
        }
        
        var xPos = 10.0
        var yPos = 50.0
        var startIndex = weekday
        
        let width = (self.contentView.frame.size.width - 20.0) / 7
        let height = width
        
        for weekDaynames in self.weekDayNamesArray {
            
            let weekDayLable = UILabel.init(frame: CGRect(x: xPos, y: yPos, width: Double(width), height: Double(height)))
            weekDayLable.text = weekDaynames.uppercased()
            weekDayLable.textAlignment = .center
            weekDayLable.textColor = UIColor.black
            weekDayLable.backgroundColor = UIColor.clear
            weekDayLable.font = UIFont.boldSystemFont(ofSize: 14.0)
            self.scrollContentView.addSubview(weekDayLable)
            xPos=xPos+Double(width);
        }
        
        xPos = 10.0
        yPos = yPos+Double(height);
        
        //showing  last monthdays
        var lastmonth = self.currentMonth - 1
        var tempYear = self.currentYear
        if lastmonth == 0 {
            lastmonth = 12
            tempYear = tempYear! - 1
        }
        let date = self.returnDateFormatter().date(from:String(format: "1/%d/%d",lastmonth, tempYear!))//"1/\\\(month)/\\\(year)"
        
        var numberofLatMonthDays = self.getNumberOfDays(inMonth: lastmonth, withDate: date!)
        
        if startIndex != 1 {
            let numberOfPreviousDays = startIndex - 1
            var previousStartDate = numberofLatMonthDays - numberOfPreviousDays
            
            for i in 1...numberOfPreviousDays {
                
                let dateLable = UILabel.init(frame: CGRect(x: xPos, y: yPos, width: Double(width), height: Double(height)))
                previousStartDate =  previousStartDate + 1
                dateLable.text = String(describing: previousStartDate)
                dateLable.textAlignment = .center
                dateLable.textColor = UIColor.lightGray
                dateLable.font = UIFont.systemFont(ofSize: 17.0)
                dateLable.tag = i
                self.scrollContentView.addSubview(dateLable)
                numberofLatMonthDays = numberofLatMonthDays - 1
                xPos = xPos + Double(width)
            }
            
        }
        // last month ends here
        
        xPos = 10.0
        
        for i in 1...7 {
            
            if i == weekday {
                break
            }
            
            
            xPos = xPos + Double(width)
        }
        
        
        var isSelctedDatesContainsAvailableDate = false
        
        for date in 1...days {
            
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector( self.dateSelected(_ :)), for: .touchUpInside)
            button.tag = date
            
            let dateLable = UILabel.init(frame: CGRect(x: xPos, y: yPos, width: Double(width), height: Double(height)))
            dateLable.text = String(describing: date)
            dateLable.textAlignment = .center
            // dateLable.textColor = UIColor.lightGray
            dateLable.font = UIFont.systemFont(ofSize: 17.0)

            dateLable.tag = date
            let date = self.returnDateFormatter().date(from:String(format: "%d/%d/%d",date, self.currentMonth, self.currentYear))
            var currentDate = self.returnDateFormatter().date(from: self.returnDateFormatter().string(from: Date()))
            
            /*if self.isHotelSelectionCalendar {
                var component = DateComponents()
                component.day = 1
                currentDate = Calendar.current.date(byAdding: component, to: Date(), wrappingComponents: true)!
            }*/

            button.isEnabled = true
            
            if date?.compare(currentDate!) == .orderedAscending {
                
                button.isEnabled = false
                dateLable.textColor = UIColor.lightGray
                
            }
           /* let calendar = Calendar.current
            
            let nextThirdMonthDate = calendar.date(byAdding:.month, value: 3, to: NSDate() as Date)!
            
            
            if date?.compare(nextThirdMonthDate) == .orderedDescending {
                
                button.isEnabled = false
                dateLable.textColor = UIColor.red
                
            }*/
            
            button.frame = dateLable.frame
            button.center = dateLable.center
            if date?.compare(currentDate!) == .orderedSame {
                //current date
                dateLable.backgroundColor = UIColor.red
                dateLable.textColor = UIColor.white
                dateLable.layoutIfNeeded()
                dateLable.clipsToBounds = true
                dateLable.layer.cornerRadius = 4.0;
                
                if self.firstDateSelected != "" {
                
                    dateLable.textColor = UIColor.lightGray
                    dateLable.backgroundColor = UIColor.clear
                    dateLable.layer.cornerRadius = 0.0
                }
            }
            
            if self.firstDateSelected != nil {
                if let startDate = self.returnDateFormatter().date(from:self.firstDateSelected) {
                    if date?.compare(startDate) == .orderedSame{
                        dateLable.backgroundColor = UIColor.red
                        dateLable.textColor = UIColor.white
                        dateLable.font = UIFont.systemFont(ofSize: 17.0)
                        dateLable.layoutIfNeeded()
                        dateLable.clipsToBounds = true
                        dateLable.layer.cornerRadius = 4.0;
                    }
                }
            }
            
            
            if self.secondDateSelected != nil {
                if let startDate = self.returnDateFormatter().date(from:self.firstDateSelected) {
                    
                    if let endDate = self.returnDateFormatter().date(from:self.secondDateSelected) {
                        if date?.compare(endDate) == .orderedSame{
                           // dateLable.backgroundColor = UIColor.init(red: 249.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
                            dateLable.backgroundColor = UIColor.red
                            dateLable.textColor = UIColor.white
                            dateLable.font = UIFont.systemFont(ofSize: 17.0)
                            dateLable.layoutIfNeeded()
                            dateLable.clipsToBounds = true
                            dateLable.layoutIfNeeded()
                            dateLable.clipsToBounds = true
                            dateLable.layer.cornerRadius = 4.0;
                        }
                        
                        if date?.compare(endDate) == .orderedAscending &&  date?.compare(startDate) == .orderedDescending{
                            dateLable.textColor = UIColor.black
                             dateLable.backgroundColor = UIColor.init(red: 249.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
                            dateLable.layoutIfNeeded()
                           // dateLable.clipsToBounds = true
                            //dateLable.layer.cornerRadius = dateLable.frame.size.width / 2;
                        }
                    }
                }
            }
            self.scrollContentView.addSubview(button)
            self.scrollContentView.addSubview(dateLable)
            startIndex = startIndex + 1
            xPos=xPos+Double(width);
            
            if startIndex == 8 {
                xPos = 10.0
                yPos = yPos+Double(height);
                startIndex = 1;
            }
        }
        
        //draw next month days
        if startIndex != 1 {
            var startDay = 1;
            for startIndex in 1...8 {
                
                let dateLable = UILabel.init(frame: CGRect(x: xPos, y: yPos, width: Double(width), height: Double(height)))
                dateLable.text = String(describing: startDay)
                dateLable.textAlignment = .center
                dateLable.textColor = UIColor.lightGray
                dateLable.font = UIFont.systemFont(ofSize: 17.0)

                dateLable.tag = startIndex
                self.scrollContentView.addSubview(dateLable)
                numberofLatMonthDays = numberofLatMonthDays - 1
                xPos = xPos + Double(width)
                startDay = startDay + 1
                
            }
        } else {
            yPos = yPos - Double(height);
        }
        
        
        if self.secondDateSelected != nil {
            if let startDate = self.returnDateFormatter().date(from:self.firstDateSelected) {
                let calendar = Calendar.current
                if let endDate = self.returnDateFormatter().date(from:self.secondDateSelected) {
                    
                    var betweenDate =  startDate
                    while betweenDate < endDate {
                        betweenDate = calendar.date(byAdding: .day, value: 1, to: betweenDate)!

                        for strDate in self.takenDateArray {
                            let temDate = strDate as! String
                            let arrayComp = temDate.components(separatedBy: "-")
                            var month = arrayComp[1]
                            if month != "10" {
                                month = month.replacingOccurrences(of: "0", with: "")
                            }
                            
                            if Int(month) == currentMonth {//String(describing:self.currentMonth) {
                                
                                if let nonAvailableDate = self.returnDateWithYearFirstFormatter().date(from:strDate as! String) {
                                    
                                    if betweenDate.compare(nonAvailableDate) == .orderedSame {
                                        //we have selected date in between so get out from here
                                        isSelctedDatesContainsAvailableDate = true
                                        break
                                    }
                                }
                            } else {
                                continue
                            }
                        }
                        
                        if isSelctedDatesContainsAvailableDate == true {
                            break
                        }
                        
                    }
                }
            }
        }
        if isSelctedDatesContainsAvailableDate == true {
            if delegate != nil {
               /* let componentsArray  = self.secondDateSelected.components(separatedBy: "/")
                delegate.selectedDate(withDay: Int(componentsArray[0])!, month: currentMonth, andYear: Int(componentsArray[2])!)*/
                delegate.showAlertAsUnAvailableDatesraeinBetweenSelectedDate()
            }
        }
        
        // }
        self.hgtConstraint.constant = CGFloat(yPos + 80.0)
    }
    
    // func selectedDate(withDay day:Int, month:Int, andYear year:Int) {
    
    // }
    
    
    @objc func dateSelected(_ sender:AnyObject) {
        if delegate != nil {
            
            if self.isMultiDateSelection == true {
                
                if self.firstDateSelected.count > 0 && self.secondDateSelected.count > 0 {
                    
                    self.firstDateSelected =  String(format:"%d/%d/%d",sender.tag,currentMonth,currentYear)
                    self.secondDateSelected = ""
                    
                    delegate.selectedDate(withDay: sender.tag, month: currentMonth, andYear: currentYear, returnDate: self.secondDateSelected)
                    return
                }
                else {
                    delegate.selectedDate(withDay: sender.tag, month: currentMonth, andYear: currentYear, returnDate: String(format:"%d/%d/%d",sender.tag,currentMonth,currentYear))
                    return
                }
            }
            delegate.selectedDate(withDay: sender.tag, month: currentMonth, andYear: currentYear, returnDate: "")
        }
    }
    
}
