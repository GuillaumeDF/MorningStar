# MorningStar

Tableau de bord santé pour iPad, construit sur HealthKit : poids, calories brûlées, pas,
sommeil et séances d'entraînement sur un seul écran, chacun avec sa tendance.

Projet perso — SwiftUI, HealthKit, Core Data, iOS 17.5+.

## Fonctionnalités

- **Cartes de tendance** pour le poids, les calories, les pas et le sommeil, par jour,
  semaine ou mois, avec un curseur pour lire la valeur d'un point.
- **Séances de la semaine** en barres empilées par intensité. L'intensité est déduite de la
  fréquence cardiaque relevée pendant la séance (`WorkoutIntensityAnalyzer`).
- **Totaux de la semaine** en en-tête : heures d'entraînement et nombre de pas.
- Thème clair et sombre.

## Architecture

```
Views (SwiftUI)
  └─ ViewModels — HealthDashboardViewModel, un view model par graphe
       └─ HealthRepository — coordonne les deux sources
            ├─ HealthKitSource — lecture HealthKit
            └─ CoreDataSource — cache local
```

- **Une factory par métrique** (`HealthDataFactoryProtocol`) : la requête HealthKit, le
  mapping HealthKit ↔ Core Data et la fusion des données vivent au même endroit. Ajouter une
  métrique, c'est ajouter une factory.
- **Synchronisation incrémentale** : seules les données postérieures à la plus récente en
  cache sont relues dans HealthKit, puis fusionnées avec le cache, entrées du même jour
  comprises. La fréquence de synchronisation est une stratégie injectée (`SyncStrategy`).
- **Graphes dessinés à la main** en SwiftUI (`Path`), sans Swift Charts : interpolation
  linéaire entre les points, curseur, squelettes de chargement.

## Lancer et tester

Ouvrir `MorningStar.xcodeproj` et lancer sur un simulateur iPad. L'app lit HealthKit : sur
simulateur, il faut d'abord ajouter des données dans l'app Santé.

```bash
xcodebuild test -project MorningStar.xcodeproj -scheme MorningStar \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)'
```

Les tests unitaires (XCTest) couvrent le mapping et la fusion Core Data / HealthKit de
chaque métrique.

## Licence

[MIT](LICENSE)
