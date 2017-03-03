//
//  CodigoDetallesViewController.swift
//  Inventario App
//
//  Created by Ramses Miramontes Meza on 02/02/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit

class CodigoDetallesViewController: UIViewController {
    var codigo : String!
    var jsonData : JSON!
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var proveedorLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var serieLabel: UILabel!
    @IBOutlet weak var cantidadLabel: UILabel!
    @IBOutlet weak var categoriaLabel: UILabel!
    @IBOutlet weak var empresaLabel: UILabel!
    @IBOutlet weak var responsableLabel: UILabel!
    @IBOutlet weak var ubicacionLabel: UILabel!
    @IBOutlet weak var empresaImageView: UIImageView!
    @IBOutlet weak var idPedidoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://inventario.corporativostr.com/movil")
        var request = URLRequest(url:url!)
        let postValues = "codigo_barras=\(codigo!)"
        print(postValues)
        request.httpBody = postValues.data(using: String.Encoding.utf8, allowLossyConversion: true)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                // handle error here
                print("Error al principio")
                print(error)
                return
            }
            
            // if response was JSON, then parse it
            
            do {
                self.jsonData = JSON(data: data!, options: [], error: nil)
                print("respuesta=\(self.jsonData)")
                DispatchQueue.main.async {
                    // Actualizar campos
                    if (self.jsonData["error"].stringValue==""){
                        self.codigoLabel.text = self.codigo
                        self.nombreLabel.text = self.jsonData["0"]["nombre"].stringValue
                        self.proveedorLabel.text = self.jsonData["0"]["proveedor"].stringValue
                        self.descripcionLabel.text = self.jsonData["0"]["descripcion"].stringValue
                        self.serieLabel.text = self.jsonData["0"]["num_serie"].stringValue
                        self.cantidadLabel.text = self.jsonData["0"]["cantidad"].stringValue
                        self.categoriaLabel.text = self.jsonData["0"]["categoria"].stringValue
                        self.empresaLabel.text = self.jsonData["0"]["empresa"].stringValue
                        self.responsableLabel.text = self.jsonData["0"]["responsable"].stringValue
                        self.ubicacionLabel.text = self.jsonData["0"]["ubicacion"].stringValue
                        self.idPedidoLabel.text = self.jsonData["0"]["id_pedido"].stringValue
                        //let empresa = self.jsonData["empresa"].stringValue
                        self.empresaImageView.image = UIImage(named: self.jsonData["0"]["empresa"].stringValue)
                        /*
                         switch empresa {
                         case "Corporativo STR" : self.empresaImageView.image = UIImage(named: empre)
                         case "Siteldi Solutions" :
                         case "Rasoft" :
                         case "Tairda" :
                         case "Kinergy" :
                         case "Sistemas" :
                         case "Cicsa" :
                         }
                         */
                    } else {
                        self.codigoLabel.text = self.codigo
                        self.nombreLabel.text = "-"
                        self.proveedorLabel.text = "-"
                        self.descripcionLabel.text = "-"
                        self.serieLabel.text = "-"
                        self.cantidadLabel.text = "-"
                        self.categoriaLabel.text = "-"
                        self.empresaLabel.text = "-"
                        self.responsableLabel.text = "-"
                        self.ubicacionLabel.text = "-"
                        //let empresa = self.jsonData["empresa"].stringValue
                        self.empresaImageView.image = UIImage(named: "")
                        /*
                         switch empresa {
                         case "Corporativo STR" : self.empresaImageView.image = UIImage(named: empre)
                         case "Siteldi Solutions" :
                         case "Rasoft" :
                         case "Tairda" :
                         case "Kinergy" :
                         case "Sistemas" :
                         case "Cicsa" :
                         }
                         */
                    }
                    
                }
                if let responseDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    DispatchQueue.main.async {
                        print("Recargo datos")
                    }
                }
            } catch {
                print(error)
                
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("responseString = \(responseString)")
            }
        }
        task.resume()
        // Do any additional setup after loading the view.
        codigoLabel.text = codigo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
