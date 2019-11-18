//
//  AACalendar.swift
//  AACalendarSwift
//
//  Created by Aman Aggarwal on 11/8/16.
//  Copyright © 2016 ClickApps. All rights reserved.
//

import Foundation
import UIKit

protocol AACalendarDelegate: class {
    func dateSelected(_ date: Date)
    func cancled()
    func disableDates(_ startDate:String, _ endDate:String)
}

class AACalendar: UIView {
    
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var previousButton:UIButton!
    @IBOutlet weak var btnDoneWithSelection:UIButton!

    @IBOutlet weak var monthNameLable:UILabel!
    
    @IBOutlet weak var daysHeaderView:UIView!
    @IBOutlet weak var daysView:UIView!

    var newDate = Date()
    var firstDateSelected: String!
    var secondDateSelected: String!
    
    var isSelectedDate = false
    var selectedDate = ""
    var canSelectMultipleDates = false

    var month = 0
    var year = 0

    weak var delegate:AACalendarDelegate?
    
    var disableDates:[String] = Array()
    var particularMonthDisableDates:[String] = Array()
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        initCalendar()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        initCalendar()
    }
    
    @IBAction func dismissCalenderView(_ sender: Any) {
        
        self.delegate?.cancled()
    }
    // initialize AACalendar
    func initCalendar() {
        
        let view:UIView = Bundle.main.loadNibNamed("AACalandarView", owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        
        btnDoneWithSelection.setTitle("Done", for: .normal)
        btnDoneWithSelection.addTarget(self, action: #selector(continueToDisableUnit), for: .touchUpInside)
        btnDoneWithSelection.isHidden = true

        self.nextButton.addTarget(self, action:#selector(self.showNextMonth), for: UIControl.Event.touchUpInside)
        self.previousButton.addTarget(self, action:#selector(showPreviousMonth), for: UIControl.Event.touchUpInside)
        
        /*if Utility.getUserDeviceLanguage() == "ar" {
            self.previousButton.transform = CGAffineTransform.init(scaleX: -1, y: 1)
            self.nextButton.transform = CGAffineTransform.init(scaleX: -1, y: 1)
        }
        */
        
        self.monthNameLable?.textColor = UIColor.init(red: 24.0/255.0, green: 19.0/255.0, blue: 34.0/255.0, alpha: 0.6)
        self.monthNameLable?.font = UIFont(name: "helvetica", size: 20.0)

        var xPos = 0.0
        let width: CGFloat = (daysHeaderView.frame.size.width/7)
        
        for dayname in 1...7 {
            let dayLable = UILabel()
            dayLable.font = UIFont(name: "helvetica", size: 14.0)
            dayLable.textAlignment = NSTextAlignment.center
            switch dayname {
            case 1:
                //sunday
                dayLable.text = "S"
                break
                
            case 2:
                dayLable.text = "M"
                break
                
            case 3:
                dayLable.text = "T"
                break
                
            case 4:
                dayLable.text = "W"
                break
                
            case 5:
                dayLable.text = "T"
                break
                
            case 6:
                dayLable.text = "F"
                break
                
            case 7:
                dayLable.text = "S"
                break
                
            default:
                break
            }
            
            dayLable.frame = CGRect(x: CGFloat(xPos),y: 10, width: CGFloat(width), height: 21.0)
            dayLable.textColor = UIColor.darkGray
            dayLable.backgroundColor =  UIColor.clear
            xPos = xPos + Double(width)
            self.daysHeaderView.addSubview(dayLable)
            
            if UserDefaults.standard.value(forKey: "SelectedDate")  != nil {
                showSelectedDayMonth(nil);
            }
            else {
                showToday(nil);
            }
        }
        
    }

    // set date formatter to be used by AACalendar
    func retunDateFormatter() -> DateFormatter {
        let  formatter = DateFormatter();
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_us")
        return formatter
    }
    
    // set month formatter to be used by AACalendar
    func retunMonthFormatter() -> DateFormatter {
        let  formatter = DateFormatter();
        formatter.locale = Locale(identifier: "en_us")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }


    // return number of days for the month number passed in the parameters
    func getNumberOfDayinMonth(_ month: Int, date:Date) -> Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = month
        let range = (calendar as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date)
        return range.length
    }

    // get weekDay of starting month
    func weekDayForDate(_ date: Date) -> Int {
        
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(NSCalendar.Unit.weekday, from: date)
        return components.weekday!
    }
    
    //show next month
    @objc func showNextMonth(_ sender: UIButton!) {
        
        month = month + 1;
        if month == 13 {
            month = 1
            year = year + 1
        }
        getDisAbleDatesForTheMonth()
        refreshCalendarWithNewMonth()
    }
    
    // show Today
    func showToday(_ sender: UIButton!) {
        
        let currentDate = Date(timeIntervalSinceNow: 0)
        let dateString = retunDateFormatter().string(from: currentDate)
        let dateSepratedArray = dateString.components(separatedBy: "/")
        month = Int(dateSepratedArray[1])!;
        year = Int(dateSepratedArray[2])!;
        getDisAbleDatesForTheMonth()
        refreshCalendarWithNewMonth()
    }
    
    func getDisAbleDatesForTheMonth() {
        particularMonthDisableDates.removeAll()
        for str in self.disableDates {
            let componentsArray = str.components(separatedBy: "/")
            var monthStr = String(describing:month)
            if monthStr.count == 1 {
                monthStr = "0\(monthStr)"
            }
            if (monthStr == componentsArray[1]) && (String(describing:year) == componentsArray[2]) {
                particularMonthDisableDates.append(str)
            }
        }
    }
    
    /*
    // show Today
    func showSelected(_ sender: UIButton!) {
        
        let currentDate = Date(timeIntervalSinceNow: 0)
        let dateString = retunDateFormatter().string(from: currentDate)
        let dateSepratedArray = dateString.components(separatedBy: "/")
        month = Int(dateSepratedArray[1])!;
        year = Int(dateSepratedArray[2])!;
        refreshCalendarWithNewMonth()
        
    }
*/

    @objc func doneWithDateSelection(sender: UIButton) {
        
        let buttonTapped = sender
        
        self.newDate = retunDateFormatter().date(from: String(format: "%d/%d/%d",buttonTapped.tag,month,year))! as Date
        
       // self.delegate?.dateSelected(retunDateFormatter().date(from: String(format: "%d/%d/%d",buttonTapped.tag,month,year))!)
        
        if firstDateSelected != nil && secondDateSelected != nil {
            firstDateSelected = nil
            secondDateSelected = nil
            self.btnDoneWithSelection.isHidden = true
        }
        
        if firstDateSelected == nil {
            firstDateSelected = String(format: "%d/%d/%d",buttonTapped.tag,month,year)
        } else {
            secondDateSelected = String(format: "%d/%d/%d",buttonTapped.tag,month,year)
            
            if retunDateFormatter().date(from:secondDateSelected)?.compare(retunDateFormatter().date(from:firstDateSelected)!) == .orderedAscending {
                      let tempSecondDate = secondDateSelected
                        let tempFirstDate  = firstDateSelected
                    firstDateSelected = tempSecondDate
                    secondDateSelected = tempFirstDate
                }
            self.btnDoneWithSelection.isHidden = false
        }
        refreshCalendarWithNewMonth()
    }
    
    
    //show Previous month
    @objc func showPreviousMonth(_ sender: UIButton!) {
        month = month - 1;
        if month == 0 {
            month = 12
            year = year - 1
        }
        getDisAbleDatesForTheMonth()
        refreshCalendarWithNewMonth()
    }

    func refreshCalendarWithNewMonth()  {
        
        let dateWithFirstDayOfMonth = retunDateFormatter().date(from: String(format: "1/%d/%d",month,year))
        let numberofDays = getNumberOfDayinMonth(month, date:dateWithFirstDayOfMonth!)
        let startWeekday = weekDayForDate(dateWithFirstDayOfMonth!)
        let  formatter = DateFormatter();
        formatter.dateFormat = "MM yyyy"
        formatter.locale = Locale(identifier: "en_us")
        let dateWithMonthYear = formatter.date(from: String(format: "%d %d",month,year))
        monthNameLable?.text = retunMonthFormatter().string(from: dateWithMonthYear!)
        createCalendar(numberofDays, startIndex: startWeekday)
    }

    func createCalendar(_ numberofDays: Int, startIndex:Int) {
        var localStartIndex  = startIndex
        
        for v in self.daysView.subviews {
            v.removeFromSuperview()
        }
        
        var xpos = 0.0
        var ypos = 0.0
        var height = 0.0
        
        for xCount in 1...7 {
            
            if xCount == startIndex {
                break
            }
            
            xpos = xpos + Double(self.daysView.frame.size.width/7)
        }
    
        for day in 1...numberofDays {
            
            let dateLable = UILabel()
            let dateBackImageView = UIImageView()
            let dateButton = UIButton()
            
            dateBackImageView.backgroundColor = UIColor.clear
            dateLable.frame = CGRect(x: CGFloat(xpos),y: CGFloat(ypos-5.0+1.0),  width: self.daysView.frame.size.width/7-2.0, height: 33.0 - 2.0)
            dateButton.frame=dateLable.frame;
            dateButton.addTarget(self, action: #selector(doneWithDateSelection), for: .touchUpInside)
            
            
            dateLable.font = UIFont.boldSystemFont(ofSize: 14.0)
            dateLable.textColor = UIColor.init(red: 24.0/255.0, green: 19.0/255.0, blue: 34.0/255.0, alpha: 0.69);
            dateLable.tag = 123
            dateButton.tag = day;
            dateLable.textAlignment = NSTextAlignment.center
            dateLable.text = String(format:"%d",day)
            dateLable.backgroundColor = UIColor.clear
            let dateitertaing = String(format:"%d/%d/%d",day,month,year)
            let date = retunDateFormatter().date(from: dateitertaing)
            let todayString = retunDateFormatter().string(from: Date(timeIntervalSinceNow: 0))
            let todayDate = retunDateFormatter().date(from: todayString)
            let comparisonResult = date?.compare(todayDate!)
            if comparisonResult == ComparisonResult.orderedSame {
                dateLable.textColor = UIColor.white
                dateBackImageView.backgroundColor = UIColor.init(red: 255.0/255.0, green: 205.0/255.0, blue: 2.0/255.0, alpha: 1.0)
                dateBackImageView.tag = day
                dateBackImageView.frame = CGRect(x: CGFloat(xpos),y: CGFloat(ypos-5.0),  width: 33.0, height: 33.0)
                dateBackImageView.center = dateLable.center
                dateBackImageView.layer.cornerRadius = dateBackImageView.frame.size.width / 2;
                dateBackImageView.clipsToBounds = true;
            }
            /*else {
                
                dateBackImageView.removeFromSuperview()
            }*/
            
             if comparisonResult == ComparisonResult.orderedAscending {
             dateButton.isUserInteractionEnabled = false
             dateLable.textColor = UIColor.lightGray
             }
             else {
             dateButton.isUserInteractionEnabled = true
             }
            
            if self.firstDateSelected != nil {
                if let startDate = retunDateFormatter().date(from:self.firstDateSelected) {
                    if date?.compare(startDate) == .orderedSame{
                        dateLable.textColor = UIColor.white
                        dateBackImageView.backgroundColor = UIColor.red
                        dateBackImageView.tag = day
                        dateBackImageView.frame = CGRect(x: CGFloat(xpos),y: CGFloat(ypos-5.0),  width: 33.0, height: 33.0)
                        dateBackImageView.center = dateLable.center
                        dateBackImageView.layer.cornerRadius = dateBackImageView.frame.size.width / 2;
                        dateBackImageView.clipsToBounds = true;
                    }
                }
            }
            
            
            if self.secondDateSelected != nil {
                if let startDate = retunDateFormatter().date(from:self.firstDateSelected) {
                    
                    if let endDate = retunDateFormatter().date(from:self.secondDateSelected) {
                        if date?.compare(endDate) == .orderedSame{
                            dateLable.textColor = UIColor.white
                            dateBackImageView.backgroundColor = UIColor.green
                            dateBackImageView.tag = day
                            dateBackImageView.frame = CGRect(x: CGFloat(xpos),y: CGFloat(ypos-5.0),  width: 33.0, height: 33.0)
                            dateBackImageView.center = dateLable.center
                            dateBackImageView.layer.cornerRadius = dateBackImageView.frame.size.width / 2;
                            dateBackImageView.clipsToBounds = true;

                        }
                        
                        if date?.compare(endDate) == .orderedAscending &&  date?.compare(startDate) == .orderedDescending{
                            dateLable.textColor = UIColor.gray
                            dateBackImageView.layoutIfNeeded()
                            dateBackImageView.clipsToBounds = true
                            dateBackImageView.layer.cornerRadius = dateBackImageView.frame.size.width / 2;
                        }
                    }
                }
            }
            
            //Already disabled dates
            
            for str in particularMonthDisableDates {
                let dateDisabled = retunDateFormatter().date(from: str)
                
                if date?.compare(dateDisabled!) == .orderedSame {
                     dateLable.textColor = UIColor.red
                    dateButton.isUserInteractionEnabled = false
                }

            }
          
            
            self.daysView.addSubview(dateBackImageView)
            self.daysView.addSubview(dateLable)
            self.daysView.addSubview(dateButton)
    
            xpos = xpos +  Double(self.daysView.frame.size.width/7)
            localStartIndex = localStartIndex + 1
            
            if localStartIndex == 8 {
                xpos = 0
                ypos = ypos + 33.0
                localStartIndex = 1
                height = height+33.0
            }
        }
       // calendarBackgroundView.frame =  CGRect(x: 0.0,y:100.0,  width:UIScreen.main.bounds.size.width, height: CGFloat(height+33.0))

    }
    
    // show Today
    func showSelectedDayMonth(_ sender: UIButton!) {
        
        let selectedDate = UserDefaults.standard.value(forKey: "SelectedDate") as! Date
       // let currentDate = Date(timeIntervalSinceNow: 0)
        let dateString = retunDateFormatter().string(from: selectedDate)
        let dateSepratedArray = dateString.components(separatedBy: "/")
        month = Int(dateSepratedArray[1])!;
        year = Int(dateSepratedArray[2])!;
        refreshCalendarWithNewMonth()
        
    }
    
    //MARK:- continueToDisableUnit
    @objc func continueToDisableUnit() {
        
        let firstDateArray = firstDateSelected.components(separatedBy: "/")
        let firstDisableDate = "\(firstDateArray[2])-\(firstDateArray[1])-\(firstDateArray[0]) 12:00:00"
        
        let secondDateArray = secondDateSelected.components(separatedBy: "/")
        let secondDisableDate = "\(secondDateArray[2])-\(secondDateArray[1])-\(secondDateArray[0]) 12:00:00"
        self.delegate?.disableDates(firstDisableDate, secondDisableDate)
    }
}


