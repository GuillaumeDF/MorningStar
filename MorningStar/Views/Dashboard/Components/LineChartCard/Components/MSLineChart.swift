//
//  MSLineChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

struct MSLineChart: View {
    let backgroundColor: Color // Couleur de fond du graphique
    @State private var sliderPosition: CGFloat = 0.5  // Position du curseur, initialisée à 50%
    @State private var value: Int = 0  // Nombre de calories à afficher
    @State private var intersectionPoint: CGPoint = .zero  // Point d'intersection entre la barre et la courbe

    // Données des calories brûlées par heure
    let caloriesBurnedPerHour = [
        65, 60, 60, 60, 60, 65, 90, 150, 110, 100, 100, 120,
        180, 130, 100, 110, 120, 200, 350, 250, 120, 90, 80, 70
    ]

    var body: some View {
        GeometryReader { geometry in
            // Obtention des dimensions de la vue
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Création de la courbe
                Path { path in
                    // Calcul du facteur d'échelle pour ajuster les valeurs à la hauteur de la vue
                    let maxValue = CGFloat(caloriesBurnedPerHour.max() ?? 0)
                    let scaleFactor = height / maxValue

                    // Déplacement au point de départ
                    path.move(to: CGPoint(x: 0, y: height - CGFloat(caloriesBurnedPerHour[0]) * scaleFactor))

                    // Création de la courbe point par point
                    for (index, value) in caloriesBurnedPerHour.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(caloriesBurnedPerHour.count - 1)
                        let y = height - CGFloat(value) * scaleFactor

                        if index > 0 {
                            let prevX = width * CGFloat(index - 1) / CGFloat(caloriesBurnedPerHour.count - 1)
                            let prevY = height - CGFloat(caloriesBurnedPerHour[index - 1]) * scaleFactor
                            let controlX = (x + prevX) / 2
                            // Ajout d'une courbe de Bézier pour lisser la ligne
                            path.addCurve(to: CGPoint(x: x, y: y),
                                          control1: CGPoint(x: controlX, y: prevY),
                                          control2: CGPoint(x: controlX, y: y))
                        }
                    }

                    // Fermeture du chemin pour créer une forme fermée
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(  // Remplissage avec un dégradé
                    LinearGradient(
                        gradient: Gradient(colors: [backgroundColor.opacity(0.3), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .stroke(backgroundColor, lineWidth: 2)  // Ajout d'un contour

                // Barre verticale mobile
                Rectangle()
                    .fill(backgroundColor)
                    .frame(width: 2)
                    .position(x: sliderPosition * width, y: height / 2)

                // Point d'intersection
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 10, height: 10)
                    .position(intersectionPoint)

                // Affichage des calories
                Text("\(value) calories")
                    .position(x: sliderPosition * width, y: height * 0.1)

                // Zone de geste pour déplacer la barre
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Mise à jour de la position du curseur
                                sliderPosition = max(0, min(1, value.location.x / width))
                                // Mise à jour des calories et du point d'intersection
                                updateCaloriesAndIntersection(at: sliderPosition, in: geometry)
                            }
                    )
            }
            .onAppear {
                // Initialise la position du point d'intersection au chargement de la vue
                updateCaloriesAndIntersection(at: sliderPosition, in: geometry)
            }
        }
    }

    // Fonction pour mettre à jour les calories et le point d'intersection
    private func updateCaloriesAndIntersection(at position: CGFloat, in geometry: GeometryProxy) {
        let width = geometry.size.width
        let height = geometry.size.height
        let x = position * width

        let maxValue = CGFloat(caloriesBurnedPerHour.max() ?? 0)
        let scaleFactor = height / maxValue

        // Calcul de l'index flottant pour l'interpolation
        let floatIndex = position * CGFloat(caloriesBurnedPerHour.count - 1)
        let lowerIndex = Int(floatIndex)
        let upperIndex = min(lowerIndex + 1, caloriesBurnedPerHour.count - 1)
        let fraction = floatIndex - CGFloat(lowerIndex)

        // Interpolation linéaire des calories
        let lowerValue = CGFloat(caloriesBurnedPerHour[lowerIndex])
        let upperValue = CGFloat(caloriesBurnedPerHour[upperIndex])
        let interpolatedValue = lowerValue + (upperValue - lowerValue) * fraction

        // Calcul de la position y du point d'intersection
        let y = height - interpolatedValue * scaleFactor

        // Mise à jour du point d'intersection et des calories
        intersectionPoint = CGPoint(x: x, y: y)
        value = Int(interpolatedValue)
    }
}

#Preview {
//    let caloriesBurnedPerHour = [
//        65,  // 00:00 - 01:00 (sommeil)
//        60,  // 01:00 - 02:00 (sommeil)
//        60,  // 02:00 - 03:00 (sommeil)
//        60,  // 03:00 - 04:00 (sommeil)
//        60,  // 04:00 - 05:00 (sommeil)
//        65,  // 05:00 - 06:00 (sommeil léger)
//        90,  // 06:00 - 07:00 (réveil, préparation)
//        150, // 07:00 - 08:00 (petit-déjeuner, déplacement)
//        110, // 08:00 - 09:00 (travail de bureau)
//        100, // 09:00 - 10:00 (travail de bureau)
//        100, // 10:00 - 11:00 (travail de bureau)
//        120, // 11:00 - 12:00 (travail de bureau, un peu de marche)
//        180, // 12:00 - 13:00 (pause déjeuner, marche)
//        130, // 13:00 - 14:00 (retour au travail)
//        100, // 14:00 - 15:00 (travail de bureau)
//        110, // 15:00 - 16:00 (travail de bureau)
//        120, // 16:00 - 17:00 (travail de bureau, un peu de marche)
//        200, // 17:00 - 18:00 (trajet de retour, un peu de marche)
//        350, // 18:00 - 19:00 (exercice modéré)
//        250, // 19:00 - 20:00 (douche, préparation du dîner)
//        120, // 20:00 - 21:00 (dîner, relaxation)
//        90,  // 21:00 - 22:00 (relaxation, TV)
//        80,  // 22:00 - 23:00 (préparation pour le coucher)
//        70   // 23:00 - 00:00 (début du sommeil)
//    ]
    
    MSLineChart(backgroundColor: Color.weightColor)
}
