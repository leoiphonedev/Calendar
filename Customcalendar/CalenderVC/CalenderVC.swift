//
//  CalenderVC.swift
//  Mbeet
//
//  Created by clickapps on 4/14/17.
//  Copyright © 2017 Clickapps. All rights reserved.
//

import UIKit

protocol CalendarDateSelected:class {
    
    func didSelectedDate(date:String, strReturnDate:String)
}

class CalenderVC: UIViewController,UITableViewDataSource, UIGestureRecognizerDelegate, UITableViewDelegate, MonthCellDelegate {
    
    var carRentTimeSelected: ((_ pickUpDate:String, _  dropOffDate:String, _  pickUpTime:String,  _ dropOffTime:String)->Void)?
    
    
    @IBOutlet weak var tblCalendar: UITableView!
    private var month = 1
    private var year = 2017
    private var yearStarted = 2017
    private var startDate: String!
    private var endDate: String!
    
    @IBOutlet weak var selectedDateBtn: UIButton!
    @IBOutlet weak var btnApply:UIButton!
    
    @IBOutlet weak var timeSlotContainerView:UIView!
    
    
    
    @IBOutlet weak var multipleDateContainerVw:UIView!
    @IBOutlet weak var lblMultiDateDeparture: UILabel!
    @IBOutlet weak var lblMultiDateDepartureDate: UILabel!
    @IBOutlet weak var lblMultiDateReturn: UILabel!
    @IBOutlet weak var lblMultiDateReturnDate: UILabel!
    
    @IBOutlet weak var imgvMultiDateReturn: UIImageView!
    @IBOutlet weak var imgvMultiDateDeparture: UIImageView!
    
    var checkInDate:String! = nil
    public var isMultiSelectionDate = false
    
    var yearCount = Int()
    var oldReturnDelegate : UIGestureRecognizerDelegate!
    var arrayTakenDates:NSMutableArray!
    var numberOfDaysWithCheckInDay:Int = 0
    
    var isUpdate = false
    var previousDepartureDate = ""
    var previousReturnDate = ""
    var pickupTime = ""
    var dropOffTime = ""
    
    // Get current date
    var dateCheckIn = Date()
    
    // Get a later date (after a couple of milliseconds)
    var dateCheckOut = Date()
    
    var selectedRow = 0
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        let date = Date()
        let calendar = Calendar.current
        
        var previousDate:Date?
        var previousRetDate:Date?
        
        if self.isUpdate {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            
            formatter.dateFormat = "MMM dd, yyyy"
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            let dateArray = previousDepartureDate.components(separatedBy: "-")
            let returnDateArray = previousReturnDate.components(separatedBy: "-")
            
            previousDate = formatter.date(from: dateArray[1]) ?? Date()
            if isMultiSelectionDate {
                if returnDateArray.count == 2{
                    previousRetDate = formatter.date(from: returnDateArray[1]) ?? Date()
                }
            }
        }
        
        month = calendar.component(.month, from: date)
        year = calendar.component(.year, from: date)
        yearStarted = calendar.component(.year, from: date)
        
        yearCount = 12-month
        
        //let day = calendar.component(.day, from: date)
        
        startDate = ""
        endDate = ""
        
        arrayTakenDates = NSMutableArray.init()
        
        
        var currentDate = Date()
        /*if isHotelCalendar {
         var component = DateComponents()
         component.day = 1
         currentDate = Calendar.current.date(byAdding: component, to: Date(), wrappingComponents: true)!
         }*/
        
        let formatter = DateFormatter() //2017-02-18 15:13:31
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        
        self.lblMultiDateDepartureDate.text = formatter.string(from: currentDate)
        if self.isUpdate {
            if let depDate = previousDate {
                self.lblMultiDateDepartureDate.text = formatter.string(from: depDate)
            }
            if let retDate = previousRetDate {
                self.lblMultiDateReturnDate.text = formatter.string(from: retDate)
            }
        }
        
        formatter.dateFormat = "dd/MMM/yyyy"
        startDate = formatter.string(from: currentDate)
        if self.isUpdate {
            self.endDate = ""
            self.startDate = ""
            if let depDate = previousDate {
                self.startDate =  formatter.string(from: depDate)
                //self.lblDepartureDate.text = formatter.string(from: depDate)
                //we are checking for first date month so that calendar can auto scroll
                let tempSelectedMonth = calendar.component(.month, from: depDate)
                if tempSelectedMonth > month {
                    selectedRow = tempSelectedMonth - month
                    
                } else if tempSelectedMonth < month {
                    selectedRow = 12 -  (month  - tempSelectedMonth)
                }
                
            }
            
            if let retDate = previousRetDate {
                self.endDate =  formatter.string(from: retDate)
                // self.lblMultiDateReturnDate.text = formatter.string(from: retDate)
            }
        }
        
        
        self.removeNoRecordLable()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.tblCalendar.register(UINib(nibName: "MonthCell", bundle: nil), forCellReuseIdentifier: "calendar_identifier")
        self.tblCalendar.dataSource = self
        self.tblCalendar.delegate = self
        self.tblCalendar.estimatedRowHeight = 300
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.tblCalendar.scrollToRow(at: IndexPath(row: self.selectedRow, section: 0), at: .middle, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        oldReturnDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = oldReturnDelegate
    }
    
    @objc fileprivate func btnBackclicked() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - showNoRecordLabel+
    func showNoRecordLabel(message: String)  {
        removeNoRecordLable()
        let norRecordLabel = UILabel.init()
        norRecordLabel.frame = CGRect(x: 0.0, y: 10.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64.0 - 55.0 )
        norRecordLabel.numberOfLines = 0
        norRecordLabel.textColor = UIColor.lightGray//Colors.kTintColor
        norRecordLabel.font = UIFont.systemFont(ofSize: 14.0)
        norRecordLabel.textAlignment = .center
        norRecordLabel.tag = 2742017
        norRecordLabel.text = message
        self.view.addSubview(norRecordLabel)
        self.view.bringSubviewToFront(norRecordLabel)
    }
    
    //MARK: - removeNoRecordLable
    func removeNoRecordLable () {
        self.view.viewWithTag(2742017)?.removeFromSuperview()
    }
    
    //MARK:- carRentTimeCompletionHandler
    func carRentTimeCompletionHandler(callBack:@escaping (_ pickUpDate:String, _  dropOffDate:String, _  pickUpTime:String,  _ dropOffTime:String)->Void ) {
        self.carRentTimeSelected = callBack
    }
    
    // MARK: - IBAction
    //MARK:- btnApplyClicked
    @IBAction func btnApplyClicked(sender:UIButton) {
        
    }
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12//yearCount+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendar_identifier") as! MonthCell
        cell.delegate = self
        var cellFrame = cell.contentView.frame
        cellFrame.size.width = self.view.frame.size.width
        cell.contentView.frame = cellFrame
        cell.isMultiDateSelection = self.isMultiSelectionDate
        cell.firstDateSelected = ""
        cell.secondDateSelected = ""
        
        if startDate.count != 0 {
            cell.firstDateSelected = startDate
        }
        if endDate.count != 0 {
            cell.secondDateSelected = endDate
        }
        
        let tempmonthTobeShown = month + indexPath.row
        var monthTobeShown = tempmonthTobeShown
        if monthTobeShown > 12 {
            var tempMonth = monthTobeShown%12
            if tempMonth == 0 {
                tempMonth = 12
            }
            monthTobeShown = tempMonth
        }
        
        year = yearStarted
        let numberOfYears = tempmonthTobeShown/12 // to get year with january
        if numberOfYears > 0 {
            for _ in 0...numberOfYears-1 {
                year = year + 1
            }
        }
        
        if monthTobeShown == 12 {
            cell.createCalendar(withMonth: monthTobeShown, andYear: year-1)
            
        } else {
            cell.createCalendar(withMonth: monthTobeShown, andYear: year)
        }
        
        
        
        cell.selectionStyle  = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension//350.0//UITableViewAutomaticDimension
    }
    
    
    func showAlertAsUnAvailableDatesraeinBetweenSelectedDate() {
        
        selectedDateBtn.isEnabled = false
    }
    
    func selectedDate(withDay day:Int, month:Int, andYear year:Int , returnDate: String) {
        
        let date = returnDateFormatter().date(from:String(format: "%d/%d/%d",day,month, year))
        let dateStr = returnMonthFormatter().string(from: date!)
        let arrayComp = dateStr.components(separatedBy: "/")
        
        if startDate.count != 0  && endDate.count != 0 {
            // need to set start date as user is trying to change date
            checkInDate = String(format: "%@ %@, %@", arrayComp[1],arrayComp[0],arrayComp[2])
            dateCheckIn = date!
            startDate = dateStr
            self.lblMultiDateDepartureDate.text = checkInDate
            self.lblMultiDateReturnDate.text = ""
            endDate = ""
            self.pickupTime = "10:00 AM"
            self.dropOffTime = ""
        } else if startDate.count != 0 && endDate.count == 0 {
            // user has elected start dtae already no we need to selecte end date
            let localstartDate = returnDateFormatter().date(from:self.startDate)
            let localendDate = returnDateFormatter().date(from:dateStr)
            
            if localendDate?.compare(localstartDate!) == .orderedAscending {
                // we need to reverse both dates as checkout cannot be smaller then check in
                dateCheckOut = dateCheckIn
                let df = DateFormatter()
                df.dateFormat = "dd/MMM/yyyy"
                endDate = df.string(from: localstartDate!)
                let arrayComp1 = endDate.components(separatedBy: "/")
                
                self.lblMultiDateReturnDate.text = String(format: "%@ %@, %@", arrayComp1[1],arrayComp1[0],arrayComp1[2])
                
                
                checkInDate = String(format: "%@ %@, %@", arrayComp[1],arrayComp[0],arrayComp[2])
                dateCheckIn = date!
                startDate = dateStr
                self.lblMultiDateDepartureDate.text = checkInDate
                self.pickupTime = "10:00 AM"
                
                self.dropOffTime = "10:00 AM"
                
            } else if localendDate?.compare(localstartDate!) == .orderedSame {
                // raise error as both dates cannot be same
             
                        return
                
            } else {
                // we are all good with checkout date
                let checkOutDate = String(format: "%@ %@, %@", arrayComp[1],arrayComp[0],arrayComp[2])
                dateCheckOut = date!
                endDate = dateStr
                self.lblMultiDateReturnDate.text = checkOutDate
                self.dropOffTime = "10:00 AM"
            }
        }
        
        tblCalendar.reloadData()
        
        
        
        /*  let dateStr = returnMonthFormatter().string(from: date!)
         let arrayComp = dateStr.components(separatedBy: "/")
         let checkInOutYear = String(format: "%@", arrayComp[2])*/
        
        /* let date = returnDateFormatter().date(from:String(format: "%d/%d/%d",day,month, year))
         let dateStr = returnMonthFormatter().string(from: date!)
         let arrayComp = dateStr.components(separatedBy: "/")
         let checkInOutYear = String(format: "%@", arrayComp[2])
         
         if !self.isMultiSelectionDate {
         
         startDate = ""
         }
         else {
         
         if returnDate == "" {
         
         startDate = ""
         
         if endDate.count > 0 {
         
         endDate = ""
         }
         }
         }
         
         if startDate.count == 0 {
         
         checkInDate = String(format: "%@ %@, %@", arrayComp[1],arrayComp[0],arrayComp[2])
         
         dateCheckIn = date!
         startDate = dateStr
         // let checkInDateForApi = returnAPIDateFormatter().string(from: date!)
         
         self.lblMultiDateDepartureDate.text = checkInDate
         
         self.lblMultiDateReturnDate.text = ""
         }
         else {
         
         if startDate.count != 0  &&  endDate.count != 0 {
         startDate = dateStr
         endDate = ""
         
         dateCheckIn = date!
         
         checkInDate = String(format: "%@ %@", arrayComp[0],arrayComp[1])
         
         startDate = dateStr
         
         }
         else {
         var checkOutDate = String(format: "%@ %@", arrayComp[0],arrayComp[1])
         
         let localstartDate = returnDateFormatter().date(from:self.startDate)
         let localendDate = returnDateFormatter().date(from:dateStr)
         if localendDate?.compare(localstartDate!) == .orderedAscending {
         startDate = dateStr
         
         var arrayComp1 = dateStr.components(separatedBy: "/")
         self.lblMultiDateDepartureDate.text = String(format: "%@ %@, %@", arrayComp1[1],arrayComp1[0],arrayComp1[2])
         
         arrayComp1.removeAll()
         
         let df = DateFormatter()
         df.dateFormat = "dd/MMM/yyyy"
         endDate = df.string(from: localstartDate!)
         arrayComp1 = endDate.components(separatedBy: "/")
         self.lblMultiDateReturnDate.text = String(format: "%@ %@, %@", arrayComp1[1],arrayComp1[0],arrayComp1[2])
         
         //Final start and end date at here
         
         } else {
         
         if localendDate?.compare(localstartDate!) == .orderedSame {
         Utility.showNotificationOverlay(message: Utility.getLocalizeText(key: "checkin_checkout_same_error"), controller: self, type: .Error)
         return
         /*if self.isHotelCalendar {
         Utility.showNotificationOverlay(message: Utility.getLocalizeText(key: "checkin_checkout_same_error"), controller: self, type: .Error)
         return
         }*/
         }
         endDate = dateStr
         let arrayComp1 = dateStr.components(separatedBy: "/")
         self.lblMultiDateReturnDate.text = String(format: "%@ %@, %@", arrayComp1[1],arrayComp1[0],arrayComp1[2])
         
         }
         
         tblCalendar.reloadData()
         return
         
         
         dateCheckOut = date!
         
         switch dateCheckOut.compare(dateCheckIn) {
         
         case .orderedAscending     :
         //  print("Date A is earlier than date B")
         
         let dateCheckInStr = returnMonthFormatter().string(from: dateCheckOut)
         let dateCheckOutStr = returnMonthFormatter().string(from: dateCheckIn)
         
         startDate = dateCheckInStr
         endDate = dateCheckOutStr
         
         let checkInDateForApi = returnAPIDateFormatter().string(from: dateCheckOut)
         
         let checkOutDateForApi = returnAPIDateFormatter().string(from: dateCheckIn)
         
         let arrayCheckInComp = dateCheckInStr.components(separatedBy: "/")
         let arrayCheckOutComp = dateCheckOutStr.components(separatedBy: "/")
         
         checkInDate = String(format: "%@ %@", arrayCheckInComp[0],arrayCheckInComp[1])
         checkOutDate = String(format: "%@ %@", arrayCheckOutComp[0],arrayCheckOutComp[1])
         
         case .orderedDescending    :
         print("Date A is later than date B")
         case .orderedSame          :
         print("The two dates are the same")
         }
         }
         }
         
         //self.dropOffTime = "10:00 AM"
         self.getDropOffTimeSlots()
         self.getPickUpTimeSlots()
         tblCalendar.reloadData()*/
        
    }
    
    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {

        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return components.day!
    }
    func getNumberOfDays() {
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "dd/MMM/yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        
        let start = formatter.date(from: startDate)!
        let end = formatter.date(from: endDate)!
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
    }
    
    func dateSelected(date: String) {
        
        print("date ==", date)
        
        /*
         if endDate.characters.count != 0 {
         startDate = ""
         endDate = ""
         tblCalendar.reloadData()
         
         }
         
         if startDate.characters.count == 0 {
         startDate = date
         // String(format: "SAR %@ x %@ nights", price,numberOfDays)
         
         let dateStr = returnMonthFormatter().date(from:self.startDate)
         //   let arrayComp = dateStr.components(separatedBy: "/")
         //if arrayComp.count == 3 {
         //lblMonthName.text = String(format: "%@ %@", arrayComp[1].uppercased(),arrayComp[2])
         //}
         self.selectedDateBtn.setTitle(String(format: "%@", startDate), for: UIControl.State.normal)
         
         } else {
         let localstartDate = returnDateFormatter().date(from:self.startDate)
         let localendDate = returnDateFormatter().date(from:date)
         if localendDate?.compare(localstartDate!) == .orderedAscending {
         startDate = date
         endDate =  returnDateFormatter().string(from: localstartDate!)
         } else {
         endDate = date
         }
         
         self.selectedDateBtn.setTitle(String(format: "%@ - %@", startDate,endDate), for: UIControlState.normal)
         
         }
         tblCalendar.reloadData()
         */
    }
    
    
    func returnDateFormatter() -> DateFormatter {
        //2017-02-15 11:46:03
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        
        return formatter
        
        
        
    }
    
    func returnAPIDateFormatter() -> DateFormatter {
        //2017-02-15 11:46:03
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        
        return formatter
        
        
        
    }
    
    func returnMonthFormatter() -> DateFormatter {
        
        let formatter = DateFormatter.init()
        formatter.dateFormat = "dd/MMM/yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        
        // formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }
    // MARK: - UIGestureRecognizerDelegate methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
  
}
