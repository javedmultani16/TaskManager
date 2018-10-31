//
//  AddEventVC.swift
//  NotificationCategoryDemo
//
//  Created by Javed Multani on 02/07/18.
//  Copyright © 2018 Javed Multani. All rights reserved.
//

import UIKit

protocol AddEventsProtocol : NSObjectProtocol{
    func addeventObject(_ objEvent : ObjEvent)
}


class AddEventVC: UIViewController,UITextFieldDelegate {
    
    
    let datePicker = UIDatePicker()
    var selectedDate  = Date()
    @IBOutlet weak var txtDatePicker: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextField!
    @IBOutlet weak var btnDate: UIButton!
  
    var delegate:AddEventsProtocol?

    public var CurrentTimeStamp: String {
        return "\(Date().timeIntervalSince1970 * 1000)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtDatePicker.delegate = self
        showDatePicker()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ClickOnDate(_ sender: Any) {
    }
    
    @IBAction func clickOnAddEvent(_ sender: Any) {
        self.view.endEditing(true)
        let obj  = ObjEvent.init(title: txtTitle.text!, disc: txtDesc.text!, time: selectedDate.toMillis(), id: CurrentTimeStamp)//datePicker.date.toMillis()
        
        if var arr = ArchiveUtil.loadEvent() {
            arr.insert(obj, at: 0)
            ArchiveUtil.saveEvent(event: arr)
        }
        else{
            ArchiveUtil.saveEvent(event: [obj])
        }
        
        self.delegate?.addeventObject(obj)
        self.navigationController?.popViewController(animated: true)
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .dateAndTime
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        txtDatePicker.text = formatter.string(from: datePicker.date)
        selectedDate = formatter.date(from: formatter.string(from: datePicker.date))!
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {    //delegate method
        showDatePicker()
    }
}
extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970)
    }
}
