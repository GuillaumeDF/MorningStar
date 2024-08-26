//
//  Color+Theme.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 08/08/2024.
//

import SwiftUI

extension Color {
    // Utilisé pour les titres des cartes, les éléments interactifs (boutons, liens) et les accents visuels importants.
    static let primaryColor = Color("MSPrimaryColor")
    
    // Utilisé pour les arrière-plans des cartes, créant un contraste doux avec les éléments de contenu.
    static let secondaryColor = Color("MSSecondaryColor")
    
    // Fond général du Dashboard pour un aspect propre et épuré.
    static let backgroundColor = Color("MSBackgroundColor")
    
    // Couleur principale pour le texte afin d'assurer une bonne lisibilité.
    static let primaryTextColor = Color("MSPrimaryTextColor")
    
    // Pour les éléments secondaires, comme les textes explicatifs ou les diagrammes moins importants.
    static let secondaryTextColor = Color("MSSecondaryText")
    
    // Exclusif à la carte Calories, pour accentuer l’importance de cette métrique.
    static let calorieColor = Color("MSCalorieColor")
    
    // Exclusif à la carte Entraînement, pour représenter l’activité physique de manière dynamique.
    static let trainingColor = Color("MSTrainingColor")
    
    // Pour les cartes liées aux pas et aux tendances, signifiant l'énergie et le mouvement.
    static let stepColor = Color("MSStepColor")
    
    // Utilisé pour la carte du poids, avec la flèche de tendance (hausse/baisse) dans une teinte plus sombre ou plus claire.
    static let weightColor = Color("MSWeightColor")
    
    // Utilisé pour délimiter les cartes, créant une séparation subtile mais nette.
    static let borderColor = Color("MSBorderColor")
    
    // Color used to indicate success, progress, or positive status
    static let successColor = Color("SuccessColor")
    
    // Color used for warnings or important highlights
    static let warningColor = Color("WarningColor")
    
    // Color used for alerts or error messages
    static let alertColor = Color("AlertColor")
    
    // Color workout intensity
    static let lowIntensityColor = Color("LowIntensityColor")
    static let moderateIntensityColor = Color("ModerateIntensityColor")
    static let highIntensityColor = Color("HighIntensityColor")
    static let veryHighIntensityColor = Color("VeryHighIntensityColor")
}
