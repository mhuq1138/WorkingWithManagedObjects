//
//  DataManager.swift
//  WorkingWithManagedObjects
//
//  Created by Mazharul Huq on 1/15/18.
//  Copyright © 2018 Mazharul Huq. All rights reserved.
//

import UIKit
import CoreData

class DataManager{
    var coreDataStack:CoreDataStack
    var managedObjectContext:NSManagedObjectContext
    
    init(dataModel:String){
        self.coreDataStack = CoreDataStack(modelName: dataModel)
        self.managedObjectContext = self.coreDataStack.managedObjectContext
    }
    
   //Creating records
    func createEmployee(firstName: String, lastName: String, dobString:String, sdString:String){
        //1 Create an entity and insert into context
        let entityDesciption = NSEntityDescription.entity(forEntityName: "Employee",in: self.managedObjectContext)
        let employee = NSManagedObject(entity:entityDesciption!,insertInto: self.managedObjectContext)
        
        //2 Set attribute values
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        employee.setValue(firstName, forKey: "firstName")
        employee.setValue(lastName, forKey: "lastName")
        employee.setValue(formatter.date(from: sdString), forKey: "startDate")
        employee.setValue(formatter.date(from: dobString), forKey: "dateOfBirth")
        
        //3 Save context
        if !self.coreDataStack.saveContext(){
            print("Unable to create employee")
        }
    }
        
    func createDepartment(name: String){
        let department =
               NSEntityDescription.insertNewObject(forEntityName:
                  "Department", into: self.managedObjectContext)
        //Set attribute values
        department.setValue(name, forKey: "name")
        
        //Save context
        if !self.coreDataStack.saveContext(){
            print("Unable to create employee")
        }
    }
    
    func createRecords(){
        createEmployee(firstName: "John", lastName: "Holden", dobString: "02-23-1945", sdString: "01-01-2001")
        createEmployee(firstName: "Jane", lastName: "Miller", dobString: "12-23-1940", sdString: "03-25-2010")
        createEmployee(firstName: "Richard", lastName: "Smith", dobString: "03-23-1955", sdString: "04-01-2011")
        createEmployee(firstName: "Joseph", lastName: "Handle", dobString: "10-13-1965", sdString: "01-01-2006")
        createEmployee(firstName: "Mary", lastName: "Alderman", dobString: "06-21-1943", sdString: "01-01-1995")
        createEmployee(firstName: "Henry", lastName: "Rockbottom", dobString: "05-03-1970", sdString: "06-15-2012")
        createEmployee(firstName: "Bob", lastName: "Rocker", dobString: "03-23-1975", sdString: "04-01-2015")
        createEmployee(firstName: "Bill", lastName: "Riley", dobString: "10-13-1945", sdString: "01-01-2002")
        createEmployee(firstName: "Mary", lastName: "Bobbins", dobString: "06-21-1949", sdString: "01-01-1998")
        createEmployee(firstName: "Andrew", lastName: "Jobs", dobString: "05-03-1975", sdString: "06-15-2014")
        
        createDepartment(name:"Accounting")
        createDepartment(name:"Human Resource")
        createDepartment(name:"Production")
        createDepartment(name:"Research")
    }
    
    
    //Fetching records from store
    func fetchEmployees()->[String]{
        var stringArray:[String] = []
        var employees:[NSManagedObject] = []
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Employee", in: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        do{
             employees = try self.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        }
        catch let error as NSError{
            print("Could not save \(error),(error.userInfo)")
            return stringArray
        }
        
        if employees.count < 1 {
            return stringArray
        }
    
        for i in 0...employees.count - 1 {
            var empString:String = ""
            let employee = employees[i]
            let firstName = employee.value(forKey: "firstName")as! String
            let lastName = employee.value(forKey: "lastName")as! String
            let dobString = formatter.string(from: employee.value(forKey: "dateOfBirth") as! Date)
            let sdString = formatter.string(from: employee.value(forKey: "startDate") as! Date)
            empString = firstName + " " + lastName + " Date of birth:" + dobString + " Start date:" + sdString
                
            if let department = employee.value(forKey: "belongsTo") as? NSManagedObject {
                let name  = department.value(forKey: "name") as! String
                    empString = empString + "\nBelongs to department:" + name
            }
            if let manager = employee.value(forKey: "department") as? NSManagedObject {
                let name  = manager.value(forKey: "name") as! String
                empString = empString + "\nManager:" + name
            }
            stringArray.append(empString)
        }
        return stringArray
    }
    
    func fetchDepartments()->[String]{
        var stringArray:[String] = []
        var departments:[NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Department")
        //Executes fetchRequest on managedObjectContext
        do{
            departments = try self.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        }
        catch let error as NSError{
            print("Could not save \(error),(error.userInfo)")
            return stringArray
        }
        
        if departments.count < 1 {
            return stringArray
        }
        
        for i in 0...departments.count - 1 {
            var deptString = ""
            let department = departments[i]
            let name = department.value(forKey: "name") as! String
            deptString = "Department: " + name
                
            if let manager = department.value(forKey: "manager") as? NSManagedObject{
                deptString = deptString + "\nManager:"
                let firstName = manager.value(forKey: "firstName") as!String
                let lastName = manager.value(forKey: "lastName") as!String
                    deptString = deptString + firstName + " " + lastName
             }
                
            if let employees = department.value(forKey: "employees") as? NSSet{
                if employees.count > 0 {
                    deptString = deptString + "\nEmployees:\n"
                }
                for employee in employees{
                    let firstName = (employee as AnyObject).value(forKey: "firstName") as!String
                    let lastName = (employee as AnyObject).value(forKey: "lastName") as!String
                    deptString = deptString + firstName + " " + lastName + "\n"
                }
            }
                stringArray.append(deptString)
            }
    
        return stringArray
    }
    
    //Fetching single records
    
    func getEmployee(_ firstName: String, lastName:String)->NSManagedObject?{
        var employee:NSManagedObject?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Employee", in: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        let firstPredicate = NSPredicate(format: "firstName = %@", firstName)
        let secondPredicate = NSPredicate(format: "lastName = %@", lastName)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [firstPredicate,secondPredicate])
        fetchRequest.predicate = compoundPredicate
        
        do{
            let results = try self.managedObjectContext.fetch(fetchRequest)
            if results.count > 0{
               employee = results[0] as? NSManagedObject
            }
        }
        catch{
            let nserror = error as NSError
            print("Could not save \(nserror),(nserror.userInfo)")
        }
        return employee
    }
    
    func getDepartment(_ name: String)->NSManagedObject?{
        var department:NSManagedObject?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Department", in: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        let predicate = NSPredicate(format: "name = %@", name)
        fetchRequest.predicate = predicate
        
        do{
            let results = try self.managedObjectContext.fetch(fetchRequest)
            if results.count > 0{
                department = results[0] as? NSManagedObject//results contains only one record
            }
        }
        catch{
            let nserror = error as NSError
            print("Could not save \(nserror),(nserror.userInfo)")
        }
        return department
    }
    
    //Creating relationships
    func createToOneRelationship(){
        let employee1 = getEmployee("Jane", lastName: "Miller")
        let employee2 = getEmployee("Bill", lastName: "Riley")
        let employee3 = getEmployee("Bob", lastName: "Rocker")
        let department1 = getDepartment("Accounting")
        let department2 = getDepartment("Human Resource")
        let department3 = getDepartment("Production")
        department1?.setValue(employee1, forKey: "manager")
        department2?.setValue(employee2, forKey: "manager")
        
        employee3?.setValue(department3, forKey: "department")
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Error creating relationship error:\(error)")
        }
    }
    
    func createToManyRelationship(){
        //Adding from One end
        let employee1 = getEmployee("John", lastName: "Holden")
        let employee2 = getEmployee("Mary", lastName: "Bobbins")
        let employee3 = getEmployee("Bill", lastName: "Riley")
        let department = getDepartment("Human Resource")
        employee1?.setValue(department, forKey: "belongsTo")
        employee2?.setValue(department, forKey: "belongsTo")
        employee3?.setValue(department, forKey: "belongsTo")
        
        //Adding from Many end
        let employee4 = getEmployee("Jane", lastName: "Miller")
        let employee5 = getEmployee("Andrew", lastName: "Jobs")
        let employee6 = getEmployee("Joseph", lastName: "Handle")
        let department1 = getDepartment("Accounting")
        
        
        let employees1:NSMutableSet? = department1?.mutableSetValue(forKey: "employees")
        employees1?.add(employee4 as Any)
        employees1?.add(employee5 as Any)
        employees1?.add(employee6 as Any)
        
        
        let employee7 = getEmployee("Richard", lastName: "Smith")
        let employee8 = getEmployee("Mary", lastName: "Alderman")
        let employee9 = getEmployee("Henry", lastName: "Rockbottom")
        let employee10 = getEmployee("Bob", lastName: "Rocker")
        let department2 = getDepartment("Production")
        
        let employees2:NSMutableSet? = department2?.mutableSetValue(forKey: "employees")
        employees2?.add(employee7 as Any)
        employees2?.add(employee8 as Any)
        employees2?.add(employee9 as Any)
        employees2?.add(employee10 as Any)
        
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Error creating relationship error:\(error)")
        }
        
    }
    
    //Deleting records
    
    func deleteEmployee(){
        let employee:NSManagedObject!
        
        employee = getEmployee("William", lastName: "Johnson")
        self.managedObjectContext.delete(employee)
        
        //Save context
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteDepartment(){
        let department:NSManagedObject!
        
        department = getDepartment("Production")
        self.managedObjectContext.delete(department)
        
        //Save context
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //Updating records
    
    func updateEmployee(){
        let employee:NSManagedObject!
        employee = getEmployee("John", lastName: "Holden")
        employee.setValue("William", forKey: "firstName")
        employee.setValue("Johnson", forKey: "lastName")
        
        //Save context
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //Deleting relationship
    func deleteRelationship(){
        let department = getDepartment("Human Resource")
        department?.setValue(nil, forKey: "employees")
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Error deleting Person error:\(error)")
        }
    }

    
    
}
