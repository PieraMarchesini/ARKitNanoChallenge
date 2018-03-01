//
//  ViewController.swift
//  KindaBeerPong
//
//  Created by Piera Marchesini on 28/02/18.
//  Copyright © 2018 Piera Marchesini. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!

    var currentCupSession = ARCupSessionStatus.initialized {
        didSet{
            DispatchQueue.main.async {
                self.statusLabel.text = self.currentCupSession.description
            }
            if currentCupSession == .failed {
                cleanupARSession()
            }
        }
    }
    
    // Planes: every plane is identified by a UUID.
    var planes = [UUID: VirtualPlane](){
        didSet {
            if planes.count > 0 {
                currentCupSession = .ready
            } else {
                if currentCupSession == .ready { currentCupSession = .initialized }
            }
        }
    }
    
    var cupNode: SCNNode!
    var selectedPlane: VirtualPlane?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
         self.sceneView.automaticallyUpdatesLighting = true
        
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.statusLabel.layer.cornerRadius = self.statusLabel.frame.size.height/2
        self.statusLabel.layer.masksToBounds = true
        
        self.initializeCupNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        if planes.count > 0 {
            self.currentCupSession = .ready
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        self.currentCupSession = .temporarilyUnavailable
    }
    
    func cleanupARSession() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    func initializeCupNode() {
        let cupScene = SCNScene(named: "Barrel.scn")!
        self.cupNode = cupScene.rootNode.childNode(withName: "Barrel", recursively: true)!
    }
    
    func virtualPlaneProperlySet(touchPoint: CGPoint) -> VirtualPlane? {
        //if the touch lies within one of our detected planes
        let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        if hits.count > 0, let firstHit = hits.first, let identifier = firstHit.anchor?.identifier, let plane = planes[identifier] {
            //extract an anchor that identifies one of our VirtualPlane instances
            self.selectedPlane = plane
            return plane
        }
        return nil
    }
    
    func addCupToPlane(plane: VirtualPlane, atPoint point: CGPoint) {
        let hits = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        if hits.count > 0, let firstHit = hits.first {
            if let anotherCupYesPlease = cupNode?.clone() {
                anotherCupYesPlease.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(anotherCupYesPlease)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("Unable to identify touches on any place. Ignoring interaction...")
            return
        }
        if self.currentCupSession != .ready {
            print("Unable to place objects when the planes are not ready...")
            return
        }
        let touchPoint = touch.location(in: self.sceneView)
        if let plane = virtualPlaneProperlySet(touchPoint: touchPoint) {
            print("Plane touched: \(plane)")
            addCupToPlane(plane: plane, atPoint: touchPoint)
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        self.currentCupSession = .failed
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.currentCupSession = .temporarilyUnavailable
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.currentCupSession = .ready
    }
    
    //MARK: - Delegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor {
            let plane = VirtualPlane(anchor: arPlaneAnchor)
            self.planes[arPlaneAnchor.identifier] = plane
            node.addChildNode(plane)
            print("Plane added: \(plane)")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor,
            let plane = planes[arPlaneAnchor.identifier] {
            plane.updateWithNewAnchor(arPlaneAnchor)
            print("Plane updated: \(plane)")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor,
            let index = planes.index(forKey: arPlaneAnchor.identifier) {
            print("Plane updated: \(planes[index])")
            planes.remove(at: index)
        }
    }
}
