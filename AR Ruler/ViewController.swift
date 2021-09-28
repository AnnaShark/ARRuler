//
//  ViewController.swift
//  AR Ruler
//
//  Created by Anna Shark on 28/9/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Dice rendering methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("screen tapped")
        if dotNodes.count >= 2 {
            print("inside dotNodes.count")
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        
        if let touch = touches.first {
            print("inside touch")
            let touchLocation = touch.location(in: sceneView)

            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                print("inside query")
                let results = sceneView.session.raycast(query)
                print(results.first)
                if let hitResult = results.first {
                //addDice(atLocation: hitResult)
                    print("inside hitresult")
                    print(hitResult)
                    addDot(at: hitResult)
                }
            }
        }
    }
    func addDot(at hitResult: ARRaycastResult)  {
        let dotGeometry = SCNSphere(radius: 0.005)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.red
        dotGeometry.materials = [sphereMaterial]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
       
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        print(start.position)
        print(end.position)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        updateText(text: "\(String(format: "%.1f", distance * 100))cm", atPosition: end.position)
    }
    
    func  updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        sceneView.scene.rootNode.addChildNode(textNode)
    }

}
