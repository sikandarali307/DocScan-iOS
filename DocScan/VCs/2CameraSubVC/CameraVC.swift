//
//  DocumentsVC.swift
//  DocScan
//
//  Created by Ankit on 16/10/20.
//

import UIKit
import Vision
import VisionKit
import PDFKit

class CameraVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    //var arrImages = [UIImage]()
    var arrImages = ["appIcon","appIcon"]
    var pdfView: PDFView!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    
    @IBAction func shareBttnAction(_ sender: Any) {
        shareAction()
    }
    @IBAction func openCameraTapped(_ sender: Any) {
        configureDocumentView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // To hide the top line
        self.navigationController?.navigationBar.shadowImage = UIImage()
        configureDocumentView()
        imgView.layer.cornerRadius = 10
        imgView2.layer.cornerRadius = 10
    }
    //MARK:- Set up collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ScannedImgCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScannedImgCell", for: indexPath) as! ScannedImgCell
        cell.scannedImg.image = UIImage(named: arrImages[indexPath.row])
        cell.backgroundColor = UIColor(named:"AppWhiteColor")
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        return cell
    }
    
    //MARK:- Code below this is used to create the PDF and perform other actions.
    @objc func shareAction() {
      // 1
      guard
        let imageV1 = imgView.image,
        let imageV2 = imgView2.image
        else{
          // 2
          let alert = UIAlertController(title: "Can't share the file!", message: "Please scan the file and try agin ☺️", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Do you have any other option?", style: .default, handler: nil))
          present(alert, animated: true, completion: nil)
          return
      }
      
      // 3
      let pdfCreator = PDFCreator(image1: imageV1, image2: imageV2)
      let pdfData = pdfCreator.CreatePDF()
      let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: [])
      present(vc, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
      if
        let _ = imgView.image {
        return true
      }
      
      let alert = UIAlertController(title: "Can't create the preview!", message: "Please scan the file and try agin ☺️", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      
      return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "previewSegue" {
        guard let vc = segue.destination as? PDFPreviewViewController else { return }
        
        if let imageView1 = imgView.image,
           let imageView2 = imgView2.image{
          let pdfCreator = PDFCreator(image1: imageView1, image2: imageView2)
          vc.documentData = pdfCreator.CreatePDF()
        }
      }
    }
    
    
    //MARK:- Set up scanner
    private func configureDocumentView(){
        let scanningDocumentVC = VNDocumentCameraViewController()
        scanningDocumentVC.delegate = self
        self.present(scanningDocumentVC, animated: true, completion: nil)
    }
    
    
}

extension CameraVC:VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        /*
         for pageNumber in 0..<scan.pageCount {
                     let Outimage = scan.imageOfPage(at: pageNumber)
                     imgView.image = scan.imageOfPage(at: 0)
                     imgView2.image = scan.imageOfPage(at: 1)
         controller.dismiss(animated: true, completion: nil)
         */
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        print("Found \(scan.pageCount)")
        let pdfDocument = PDFDocument()

        for i in 0 ..< scan.pageCount {
            let img = scan.imageOfPage(at: i)
            // ... your code here
            let pdfPage = PDFPage(image: img)
            pdfDocument.insert(pdfPage!, at: i)
        }
        let data = pdfDocument.dataRepresentation()
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")
        do{
            print("Documet: \(docURL)")
            try data?.write(to: docURL)
        }catch(let error){
            print("error is \(error.localizedDescription)")
        }
//        let originalImage = scan.imageOfPage(at: 0)
//        let newImage = compressedImage(originalImage)
        controller.dismiss(animated: true)
//        processImage(newImage)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        
        controller.dismiss(animated: true)
    }
}
/*
 // Use this to enable camer picker fucnctionality.
extension CameraVC: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    
    guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      return
    }
    
    imgView.image = selectedImage
    imgView.isHidden = false
    
    dismiss(animated: true, completion: nil)
  }
}
*/
