//
//  ContentView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/4/25.
//

import SwiftUI
import SceneKit

// MARK: - Modelos simples
struct Law: Identifiable { let id = UUID(); let title: String }
struct Politician: Identifiable { let id = UUID(); let name: String }

struct CountryData {
    let code: String
    let name: String
    let lat: Double
    let lon: Double
    let color: UIColor
}

// Un puñado de países de ejemplo (añade los que quieras)
let demoCountries: [CountryData] = [
    .init(code: "PRI", name: "Puerto Rico", lat: 18.2208, lon: -66.5901, color: .systemOrange),
    .init(code: "USA", name: "United States", lat: 39.8283, lon: -98.5795, color: .systemBlue),
    .init(code: "FRA", name: "France", lat: 46.2276, lon:   2.2137, color: .systemGreen),
    .init(code: "BRA", name: "Brazil", lat: -14.2350, lon: -51.9253, color: .systemRed),
]

// Simulación de “API”
func fetchLawsAndPoliticians(for countryCode: String) async -> ([Law],[Politician]) {
    // Aquí llamarías a Wikidata/tu backend.
    // Devuelvo datos de ejemplo:
    let laws = [
        Law(title: "Ley de Transparencia"),
        Law(title: "Ley de Protección de Datos"),
        Law(title: "Ley Electoral")
    ]
    let politicians = [
        Politician(name: "Líder A"),
        Politician(name: "Ministro B"),
        Politician(name: "Diputada C")
    ]
    return (laws, politicians)
}

// MARK: - SceneKit wrapper
struct GlobeView: UIViewRepresentable {
    final class Coordinator: NSObject {
        var parent: GlobeView
        init(_ p: GlobeView) { self.parent = p }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            let p = gesture.location(in: scnView)
            let hits = scnView.hitTest(p, options: [.firstFoundOnly: true])
            if let node = hits.first?.node {
                // Los pines tienen el nombre del país
                if let code = node.name {
                    parent.onPick?(code)
                }
            }
        }
    }
    
    var onPick: ((String) -> Void)?
    var cartoonOceanColor: UIColor = UIColor(red: 0.37, green: 0.67, blue: 0.95, alpha: 1.0)
    var landTint: UIColor = UIColor(white: 1.0, alpha: 0.12) // leve variación
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        
        let scene = SCNScene()
        view.scene = scene
        
        // Cámara
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4.2)
        scene.rootNode.addChildNode(cameraNode)
        
        // Luz simple
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(2, 3, 5)
        scene.rootNode.addChildNode(lightNode)
        
        // Globo “cartoon”: esfera + material unlit/lambert colores planos
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 64
        
        let mat = SCNMaterial()
        mat.diffuse.contents = cartoonOceanColor
        mat.locksAmbientWithDiffuse = true
        mat.lightingModel = .lambert // .constant también sirve si quieres aún más plano
        sphere.firstMaterial = mat
        
        let globeNode = SCNNode(geometry: sphere)
        globeNode.name = "Globe"
        scene.rootNode.addChildNode(globeNode)
        
        // Bordes/falso “relieve” low-poly: un overlay translúcido opcional
        if true {
            let overlay = SCNSphere(radius: 1.001)
            let m = SCNMaterial()
            m.diffuse.contents = landTint
            m.isDoubleSided = true
            m.lightingModel = .constant
            overlay.firstMaterial = m
            let overlayNode = SCNNode(geometry: overlay)
            globeNode.addChildNode(overlayNode)
        }
        
        // Poner “pines” por país (esferas pequeñas con colisión y nombre de país)
        for c in demoCountries {
            let pin = SCNSphere(radius: 0.03)
            let pinMat = SCNMaterial()
            pinMat.diffuse.contents = c.color
            pinMat.lightingModel = .lambert
            pin.firstMaterial = pinMat
            
            let pinNode = SCNNode(geometry: pin)
            pinNode.name = c.code
            pinNode.position = positionOnSphere(lat: c.lat, lon: c.lon, radius: 1.02)
            // Línea “tallo” opcional para destacar
            let stem = SCNCylinder(radius: 0.004, height: 0.10)
            let stemMat = SCNMaterial()
            stemMat.diffuse.contents = c.color.withAlphaComponent(0.8)
            stem.firstMaterial = stemMat
            let stemNode = SCNNode(geometry: stem)
            stemNode.position = SCNVector3(0, -0.07, 0)
            pinNode.addChildNode(stemNode)
            
            globeNode.addChildNode(pinNode)
        }
        
        // Control de cámara “girar/zoom” sin programar gestos a mano
        view.allowsCameraControl = true
        view.defaultCameraController.interactionMode = .orbitTurntable
        view.defaultCameraController.inertiaEnabled = true
        view.defaultCameraController.maximumVerticalAngle = 90
        
        // Tap para selección
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) { }
    
    // Convierte lat/lon a XYZ en la esfera
    private func positionOnSphere(lat: Double, lon: Double, radius: Double) -> SCNVector3 {
        let φ = lat * .pi / 180.0   // latitude in radians
        let θ = lon * .pi / 180.0   // longitude in radians
        let x = radius * cos(φ) * cos(θ)
        let y = radius * sin(φ)
        let z = radius * cos(φ) * sin(θ)
        return SCNVector3(x, y, z)
    }
}

// MARK: - Vista SwiftUI
final class CountryStore: ObservableObject {
    @Published var selectedCode: String? = nil
    @Published var selectedName: String? = nil
    @Published var laws: [Law] = []
    @Published var politicians: [Politician] = []
    @Published var isLoading = false
    
    func pick(_ code: String) {
        selectedCode = code
        selectedName = demoCountries.first(where: { $0.code == code })?.name ?? code
        Task {
            isLoading = true
            let (l, p) = await fetchLawsAndPoliticians(for: code)
            await MainActor.run {
                self.laws = l
                self.politicians = p
                self.isLoading = false
            }
        }
    }
    
    func clear() {
        selectedCode = nil
        laws = []; politicians = []
        isLoading = false
    }
}

struct CircleMap: View {
    @StateObject private var store = CountryStore()
    
    var body: some View {
        ZStack {
            GlobeView { code in
                store.pick(code)
            }
            .ignoresSafeArea()
            
            // Encabezado simple
            VStack {
                Text("World Laws • Cartoon 3D")
                    .font(.title2.weight(.bold))
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
        }
        .sheet(item: Binding(
            get: { store.selectedCode.map { SheetID(id: $0) } },
            set: { _ in store.clear() })
        ) { _ in
            DetailSheet(store: store)
                .presentationDetents([.medium, .large])
        }
    }
    
    private struct SheetID: Identifiable { let id: String }
}

struct DetailSheet: View {
    @ObservedObject var store: CountryStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(store.selectedName ?? "Country")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
            
            if store.isLoading {
                ProgressView("Cargando…")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Group {
                    Text("Leyes clave").font(.headline)
                    ForEach(store.laws) { l in
                        Label(l.title, systemImage: "doc.text")
                    }
                    
                    Divider().padding(.vertical, 6)
                    
                    Text("Políticos principales").font(.headline)
                    ForEach(store.politicians) { p in
                        Label(p.name, systemImage: "person.fill")
                    }
                }
            }
        }
        .padding()
    }
}
#Preview {
    CircleMap()
}
