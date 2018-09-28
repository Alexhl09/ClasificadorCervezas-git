//
//  Tabla.swift
//  ClasificadorCervezas
//
//  Created by Alejandro on 9/28/18.
//  Copyright © 2018 com.AlexStudios. ClasificadorCervezas. All rights reserved.
//

import UIKit

class Tabla: UITableViewController  {

    let modelos : [String] = ["ssd_mobilenet.mlmodel", "ssd_mobilenet_2.mlmodel", "ssd_mobilenet_3.mlmodel", "ssd_mobilenet_4.mlmodel", "ssd_mobilenet_5.mlmodel", "ssd_mobilenet_6.mlmodel", "ssd_mobilenet_7.mlmodel", "ssd_mobilenet_8.mlmodel", "ssd_mobilenet_9.mlmodel"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Elige el modelo a usar"
        print(modelos)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return modelos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = self.modelos[indexPath.row]
        cell.layer.cornerRadius = cell.frame.height / 2
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cc = tabBarController as! Tabulador
        let ip = self.tableView.indexPathForSelectedRow
        cc.model = modelos[ip?.row ?? 0]
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
   
   
}
