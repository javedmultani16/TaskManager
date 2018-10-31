//
//  ViewController.swift
//  NotificationCategoryDemo
//
//  Created by Javed Multani on 12/2/16.
//  Copyright © 2016 Javed Multani. All rights reserved.
//

import UIKit
import UserNotifications


class ViewController: UIViewController,UNUserNotificationCenterDelegate, UITableViewDelegate, UITableViewDataSource, AddEventsProtocol {
    
    //MARK: Properties and outlets
    let time:TimeInterval = 10.0
    var isGrantedAccess = false
    var arr = [ObjEvent]()

    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var tblRecord: UITableView!
    
    //MARK: - Functions
    //this method set the category
    func setCategories(){
        let snoozeAction = UNNotificationAction(
            identifier: "snooze",
            title: "Snooze 5 Sec",
            options: [])
        let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Custom Snooze", options: [], textInputButtonTitle: "Add", textInputPlaceholder: "Add Snooze seconds")

        
        let alarmCategory = UNNotificationCategory(
            identifier: "alarm.category",
            actions: [snoozeAction,commentAction],
            intentIdentifiers: [],
            options: [])
        

        
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
    
    func addNotification(content:UNNotificationContent,trigger:UNNotificationTrigger?, indentifier:String){
        let request = UNNotificationRequest(identifier: indentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {
            (errorObject) in
            if let error = errorObject{
                print("Error \(error.localizedDescription) in notification \(indentifier)")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddEventVC
        vc.delegate = self
    }
    
    func addeventObject(_ objEvent : ObjEvent){
        if isGrantedAccess{
            let content = UNMutableNotificationContent()
            content.title = objEvent.title!
            content.subtitle = objEvent.disc!
            content.body = objEvent.title!
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm.category"
            
            
            
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.system
            
            let date = NSDate(timeIntervalSince1970: TimeInterval(objEvent.time!))
            
            let formatter = DateFormatter()

            formatter.timeZone = NSTimeZone.system
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let strDate: String = formatter.string(from: date as Date)
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
      
            let tdate = formatter.date(from: strDate)!

            let now = tdate
            
            let hour = calendar.component(.hour, from: now)
            let minutes = calendar.component(.minute, from: now)
            let day = calendar.component(.day, from: now)
            let month = calendar.component(.month, from: now)
            let yr = calendar.component(.year, from: now)
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minutes
            dateComponents.month = month
            dateComponents.year = yr
            dateComponents.day = day
            
            
            let dateSelected = NSDate() as Date
            print(dateSelected)
            
            var nowComponents = DateComponents()
//            nowComponents.timeZone = TimeZone(abbreviation: "UTC")!
            //let calendar = Calendar.current
            nowComponents.year = Calendar.current.component(.year, from: dateSelected)
            nowComponents.month = Calendar.current.component(.month, from: dateSelected)
            nowComponents.day = Calendar.current.component(.day, from: dateSelected)
            nowComponents.hour = Calendar.current.component(.hour, from: dateSelected)
            nowComponents.minute = Calendar.current.component(.minute, from: dateSelected)
            nowComponents.second = Calendar.current.component(.second, from: dateSelected)
            let startDate = calendar.date(from: nowComponents)!
            let interval = tdate.timeIntervalSince(startDate)

            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            addNotification(content: content, trigger: trigger , indentifier: objEvent.id!)
        }
    }
    
    //MARK: - Actions
    @IBAction func startButton(_ sender: UIButton) {
        if isGrantedAccess{
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.subtitle = "First Alarm"
            content.body = "First Alarm"
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "alarm.category"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            addNotification(content: content, trigger: trigger , indentifier: "Alarm")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //tblRecord.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedAccess = granted
                if granted{
                    self.setCategories()
                } else {
                    let alert = UIAlertController(title: "Notification Access", message: "In order to use this application, turn on notification permissions.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert , animated: true, completion: nil)
                }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let arrNew = ArchiveUtil.loadEvent() {
            arr.removeAll()
            arr = arrNew
        }
        tblRecord.reloadData()
    }
    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [arr[indexPath.row].id!])
            self.arr.remove(at: indexPath.row)
            ArchiveUtil.saveEvent(event: arr)
            tblRecord.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }

        cell?.textLabel?.text = arr[indexPath.row].title
   
        let date = NSDate(timeIntervalSince1970: TimeInterval(Double(arr[indexPath.row].time!)))
        let sharedDateFormat : DateFormatter = DateFormatter()
        sharedDateFormat.timeZone = NSTimeZone.system
        sharedDateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString = sharedDateFormat.string(from: date as Date)
        cell?.detailTextLabel?.text =  dateString
        cell?.selectionStyle = .none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    
    // MARK: - Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    //Add this method to handle snooz after once appear
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        let identifier = response.actionIdentifier
        let request = response.notification.request
        var snooze:TimeInterval = 5.0
        
        if identifier == "snooze"{
            
        }
        else if identifier == "comment"{
            let textResponse = response as! UNTextInputNotificationResponse
            let num = Double(textResponse.userText)
            if num != nil {
                snooze = TimeInterval(num!)
            }
            else {
                snooze = 5
            }
        }
        let newContent = request.content.mutableCopy() as! UNMutableNotificationContent
        let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snooze, repeats: false)
        addNotification(content: newContent, trigger: newTrigger, indentifier: request.identifier)


    }
}
