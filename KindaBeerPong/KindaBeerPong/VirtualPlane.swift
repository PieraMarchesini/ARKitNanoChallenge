//
//  VirtualPlane.swift
//  KindaBeerPong
//
//  Created by Piera Marchesini on 28/02/18.
//  Copyright © 2018 Piera Marchesini. All rights reserved.
//

import Foundation
import ARKit

class VirtualPlane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        //Initialize anchor
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initializePlaneMaterial()
        self.planeGeometry.materials = [material]
        
        //Create SceneKit plane node
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        //Update the material representation for this plane
        updatePlaneMaterialDimensions()
        
        //Add node to hierarchy
        self.addChildNode(planeNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.1)
        return material
    }
    
    //adjust the material of the plane to have the right dimensions. difference between SceneKit and ARKit
    func updatePlaneMaterialDimensions() {
        let material = self.planeGeometry.materials.first!
        
        //scale material to width and height of the updated plane
        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
    
    func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
        //atualiza a extensão do plano que pode ter mudado
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        updatePlaneMaterialDimensions()
    }
}
