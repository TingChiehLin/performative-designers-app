import SwiftUI
import SceneKit

struct DailyTaskView: View {
    @State private var xp: Double = 0
    @State private var tasks: [(name: String, reward: Int)] = [
        ("Learn AI Recognition", 20),
        ("Complete a Daily Exercise", 15),
        ("Watch Tutorial Video", 10)
    ]
    @State private var catAnimation: String = "Idle"

    var body: some View {
        NavigationView {
            VStack {
                // 3D Cat View
                SceneView(
                    scene: makeCatScene(),
                    options: [.allowsCameraControl]
                )
                .frame(height: 300)
                .onTapGesture {
                    playCatAffection()
                }

                // XP Bar
                VStack(alignment: .leading) {
                    Text("XP: \(Int(xp))/100")
                        .font(.caption)
                    ProgressView(value: xp, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                        .animation(.easeInOut, value: xp)
                }
                .padding()

                // Task List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(tasks, id: \.name) { task in
                            Button(action: {
                                completeTask(task.reward, name: task.name)
                            }) {
                                HStack {
                                    Text(task.name)
                                        .font(.body)
                                    Spacer()
                                    Text("+\(task.reward) XP") // show reward here
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Daily Tasks")
        }
    }

    // MARK: - 3D Cat Scene
    func makeCatScene() -> SCNScene {
        if let url = Bundle.main.url(forResource: "cat", withExtension: "usdz") {
            do {
                let scene = try SCNScene(url: url, options: nil)
                setupScene(scene)
                return scene
            } catch {
                print("⚠️ Failed to load cat.usdz: \(error.localizedDescription)")
            }
        }

        print("⚠️ Could not find any 3D cat model in bundle")
        return SCNScene()
    }

    // MARK: - Scene Setup
    private func setupScene(_ scene: SCNScene) {
        scene.background.contents = UIColor.gray

        if let catNode = scene.rootNode.childNodes.first {
            catNode.scale = SCNVector3(0.1, 0.1, 0.1)
            catNode.position = SCNVector3(0, -1, 0)

            if let geometry = catNode.geometry {
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "Cat_diffuse")
                material.normal.contents = UIImage(named: "Cat_bump")
                geometry.materials = [material]
            }
        }

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 5)
        scene.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 800
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
    }

    // MARK: - Actions
    func playCatAffection() {
        xp += 5
        if xp > 100 { xp = 100 }
        print("🐱 Cat is happy! XP now \(xp)")
    }

    func completeTask(_ reward: Int, name: String) {
        xp += Double(reward)
        if xp > 100 { xp = 100 }
        print("✅ Completed task: \(name) (+\(reward) XP)")
    }
}
