//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by lucas fernández on 01/08/15.
//  Copyright (c) 2015 lucas fernández. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil //esto es un contexto que nos deja manejar toooodos los datos del coredata y nos permite usarlo facilmente
    
    
    override func awakeFromNib() { //es una forma para de xib para la página de inicio, la que es launchscreen
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton*/
        
        //Vamos a guardar nuestras cosas en el storedadta
        
        var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //Crearemos el delegate para guardar cosas
        
        var context: NSManagedObjectContext = appDel.managedObjectContext!  //es el contexto para que funcione el delegado
        
        
        
        //Tenemos que descargar los post del googlepòs
        
        
        
        let url = NSURL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyC_mfh-kySir9Asp4T0fIHGo64-lAEl9KY")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil{
                
                
                print(error)
                
            }else{
                
                dispatch_async(dispatch_get_main_queue()){
                
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                
                let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                
                if jsonResult.count > 0{
                    
                    if let items = jsonResult["items"] as? NSArray{
                        
                        //fetch = buscar algo, es para buscar todos los posts para actualizar
                        var request = NSFetchRequest(entityName: "Posts")
                        
                        request.returnsObjectsAsFaults = false
                        
                        var results = try! context.executeFetchRequest(request)

                       
                        if results.count > 0 {
                        
                            
                        for result in results{
                            
                            
                            context.deleteObject(result as! NSManagedObject)
                            
                            do {
                                try context.save()
                            } catch _ {
                            }
                            
                        }
                        }
                        for item in items{
                            
                            //println(item)
                            
                            //esto es para guardar el contenido si existe
                            
                            if let title = item["title"] as? String{
                                
                                if let content = item["content"] as? String{
                                    
                                    if let date = item["updated"] as? String{
                                    
                                    var newPost: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context) as! NSManagedObject //Para crear la entidad de la descripción, y así guardar el objeto
                                  
                                        
                                    newPost.setValue(title, forKey: "title")
                                        
                                    newPost.setValue(date, forKey: "date")
                                    
                                    newPost.setValue(content, forKey: "content")
                                    
                                    do {
                                        try context.save()
                                    } catch _ {
                                    }
                                    
                                    }
                                }
                            }
                        }
                        
                        
                    }
                    
                    }
                }
                
               
                
                self.tableView.reloadData() //para que se vea el conetnido en la tabla
                
            }
            
            
        })
        
        
        task.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func insertNewObject(sender: AnyObject) {
    let context = self.fetchedResultsController.managedObjectContext
    let entity = self.fetchedResultsController.fetchRequest.entity!
    let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! NSManagedObject
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    newManagedObject.setValue(NSDate(), forKey: "timeStamp")
    
    // Save the context.
    var error: NSError? = nil
    if !context.save(&error) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //println("Unresolved error \(error), \(error.userInfo)")
    abort()
    }
    }*/
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) { //Este es el código que pasará cuando se llega a la vista del detalle
        if segue.identifier == "showDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            (segue.destinationViewController as! DetailViewController).detailItem = object //busca el viewControler de destino y da el detalle del objeto y pone el valor de objeto en detailItem
            }
            
            
            
            
            
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 /*self.fetchedResultsController.sections?.count ?? 0*/ //Lo dejamos con una sola porque solo vamos a tener una sección
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] //aquí crea una variable que saca del fetch el número de objetos en esa sección
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        self.configureCell(cell, atIndexPath: indexPath)
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false /*true*/
    }
    
    /*override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    let context = self.fetchedResultsController.managedObjectContext
    context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
    
    var error: NSError? = nil
    if !context.save(&error) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //println("Unresolved error \(error), \(error.userInfo)")
    abort()
    }
    }
    }*/
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) { //esto es para configurar la celda, crea la celda para cada indexpath, y crea un objeto para cada obtención

    
    
    let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
    cell.textLabel!.text = object.valueForKey("title")!.description //así creamos la celda poniendo title
    
        if object.valueForKey("date")?.description != nil{
            let delimiter = "T"
            let fecha = object.valueForKey("date")!.description as String
            var token = fecha.componentsSeparatedByString(delimiter)
            
    
    cell.detailTextLabel?.text = token[0]
       
        }
        
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController { //esto busca todo lo que hay en el coredata y lo muestra en la tabla
    if _fetchedResultsController != nil {
    return _fetchedResultsController!
    }
    
    let fetchRequest = NSFetchRequest()
    // Edit the entity name as appropriate.
    let entity = NSEntityDescription.entityForName("Posts", inManagedObjectContext: self.managedObjectContext!) //hay que cambiar el nombre de donde lo encuentra, ahora se llamara Posts por eso de que nuestra entidad se llama así
    fetchRequest.entity = entity
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true) //Esto es la clave con la que los datos serán mostrados. UPDATE CON TIMESTAMP!!!!!!
    let sortDescriptors = [sortDescriptor]
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
    var error: NSError? = nil
    do {
        try _fetchedResultsController!.performFetch()
    } catch let error1 as NSError {
        error = error1
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //println("Unresolved error \(error), \(error.userInfo)")
    abort()
    }
    
    return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
    self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
    self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    default:
    return
    }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
    self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    default:
    return
    }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
    }
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
    
}

