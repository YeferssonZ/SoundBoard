//
//  SoundViewController.swift
//  ZunigaSoundBoard
//
//  Created by Yefersson Guillermo Zuñiga Justo on 30/10/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL:URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // Detener la grabación
            grabarAudio?.stop()
            // Cambiar texto del botón grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            // Habilitar el botón "Reproducir" después de detener la grabación
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            // Empezar a grabar
            grabarAudio?.record()
            // Cambiar el texto del botón grabar a "DETENER"
            grabarButton.setTitle("DETENER", for: .normal)
            // Deshabilitar el botón "Reproducir" mientras se graba
            reproducirButton.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: UIButton) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    func configurarGrabacion() {
        do {
            // Creando sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            // Creando dirección para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            // Impresión de la ruta donde se guardan los archivos
            print("**********************")
            print(audioURL!)
            print("**********************")

            // Crear opciones para el grabador de audio
            var settings: [String: Any] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?

            // Crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio?.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }

}
