//
//  ViewController.swift
//  ZunigaSoundBoard
//
//  Created by Yefersson Guillermo Zuñiga Justo on 30/10/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones: [Grabacion] = []
    var reproducirAudio: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        tablaGrabaciones.delegate = self
        tablaGrabaciones.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        do {
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        } catch {}
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellIdentifier")
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        cell.detailTextLabel?.text = "Duración: \(formattedTime(grabacion.duracion))"
        return cell
    }

    
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
                reproducirAudio?.play()
        } catch {}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            } catch {}
        }
    }

}

