//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by lucas fernández on 01/08/15.
//  Copyright (c) 2015 lucas fernández. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //@IBOutlet weak var detailDescriptionLabel: UILabel!  .
    @IBOutlet var navigationBar: UINavigationItem!

    @IBOutlet var webView: UIWebView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        
        if let detail: AnyObject = self.detailItem { //aquí básicamente vamos a poner el contenido del objeto al webViewController
            
            navigationBar.title = detail.valueForKey("title") as? String
            
            
            if let wv = self.webView {
                
                
                wv.loadHTMLString(detail.valueForKey("content")!.description!, baseURL: nil) //así al objeto wb, que es el propio webView le vamos a cargar el html del contenido, con la descripción y demás
                
                
                
            }
        }
        
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

