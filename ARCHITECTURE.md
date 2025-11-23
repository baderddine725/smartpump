# Architecture de l'Application SmartPump

## Structure des Fichiers

L'application suit une architecture Clean Architecture avec séparation en couches :

### 📁 lib/core/
Contient les éléments fondamentaux de l'application :
- **constants/** : Constantes globales (app_constants, modbus_constants, route_constants)
- **errors/** : Gestion des erreurs (app_exceptions, failure)
- **themes/** : Thèmes et styles (app_theme, color_palette, text_styles)
- **utils/** : Utilitaires (date_utils, number_utils, validators, extensions)
- **widgets/** : Widgets communs réutilisables

### 📁 lib/data/
Couche d'accès aux données :
- **models/** : Modèles de données (JSON)
  - **pump/** : pump_status.dart, pump_error.dart, pump_config.dart, pump_alert.dart
  - **site/** : site_model.dart, site_performance.dart
  - **business/** : roi_analysis.dart, decision_analysis.dart, performance_metrics.dart
  - **user/** : user_model.dart, user_preferences.dart
- **datasources/** : Sources de données (remote, local)
- **repositories/** : Implémentations des repositories
  - pump_repository.dart
  - pump_error_repository.dart
  - mock_pump_repository.dart (pour le développement)
  - site_repository.dart
  - business_repository.dart
  - user_repository.dart

### 📁 lib/domain/
Logique métier :
- **entities/** : Entités métier (pump_status.dart)
- **repositories/** : Interfaces des repositories (pump_repository_interface.dart)
- **usecases/** : Cas d'utilisation métier

### 📁 lib/presentation/
Interface utilisateur :
- **blocs/** : Gestion d'état avec BLoC
  - **pump/** : pump_status_bloc, pump_control_bloc, pump_alert_bloc, pump_error_bloc
  - **site/** : site_management_bloc, multi_site_bloc
  - **business/** : roi_analysis_bloc, decision_bloc, report_bloc
  - **auth/** : auth_bloc, user_bloc
- **pages/** : Écrans de l'application
  - **farmer/** : farmer_home_screen, pump_detail_screen, water_consumption_screen, simple_alert_screen
  - **technician/** : technician_dashboard, diagnostic_screen, parameter_settings_screen, maintenance_screen, firmware_update_screen, pump_error_screen
  - **entrepreneur/** : executive_dashboard, roi_analysis_screen, multi_site_screen, team_management_screen, performance_screen
  - **auth/** : login_screen, splash_screen
  - **common/** : profile_screen, settings_screen
- **widgets/** : Composants UI réutilisables
  - farmer_widgets/
  - technician_widgets/
  - business_widgets/
  - shared_widgets/
- **routes/** : Gestion de la navigation (app_router.dart, route_names.dart, route_generator.dart)

## Use Cases Implémentés

### 👨‍🌾 Agriculteur (Interface Simplifiée)
- ✅ Voir l'état simple de la pompe
- ✅ Démarrer/Arrêter la pompe
- ✅ Recevoir des alertes simples
- ✅ Consulter la consommation d'eau

### 🔧 Technicien (Interface Technique)
- ✅ Diagnostiquer les pannes (PumpErrorBloc + PumpErrorScreen)
- ✅ Paramétrer les onduleurs
- ✅ Maintenance préventive
- ✅ Mettre à jour le firmware

### 💼 Entrepreneur (Interface Business)
- ✅ Analyser le ROI de l'investissement (ExecutiveDashboardScreen avec ROI)
- ✅ Superviser multiple sites (MultiSiteScreen)
- ✅ Gérer l'équipe de techniciens
- ✅ Évaluer la performance du système

## BLoCs Créés

1. **PumpStatusBloc** : Gestion de l'état des pompes
   - Events: PumpStatusRequested, PumpStartRequested, PumpStopRequested, AllPumpsStatusRequested
   - States: PumpStatusInitial, PumpStatusLoadInProgress, PumpStatusLoadSuccess, PumpStatusLoadFailure, AllPumpsStatusLoadSuccess, PumpOperationInProgress, PumpOperationSuccess, PumpOperationFailure

2. **PumpErrorBloc** : Gestion des erreurs de pompes
   - Events: PumpErrorRequested
   - States: PumpErrorInitial, PumpErrorLoadInProgress, PumpErrorLoadSuccess, PumpErrorLoadFailure

## Modèles de Données

- **PumpStatusModel** : Statut d'une pompe avec toutes les métriques
- **PumpError** : Erreurs de pompe avec code, description, sévérité, causes et solutions
- **ROIAnalysis** : Analyse ROI avec investissement, économies, TRI, NPV, IRR
- **DecisionAnalysis** : Analyse de décision avec options et critères
- **Site** : Modèle de site avec performance et métriques

## Configuration

Le fichier `main.dart` configure :
- RepositoryProvider pour l'injection de dépendances
- BlocProvider pour la gestion d'état
- MaterialApp avec thème vert (couleur primaire pour agriculture)

## Dépendances Principales

- **flutter_bloc** : Gestion d'état
- **equatable** : Comparaison d'objets
- **http** : Requêtes HTTP
- **hive/hive_flutter** : Stockage local
- **syncfusion_flutter_charts** : Graphiques
- **fl_chart** : Graphiques avancés

## Prochaines Étapes

1. Implémenter les widgets réutilisables manquants
2. Compléter les BLoCs business (ROI, Decision, Report)
3. Configurer la navigation complète avec routes
4. Ajouter les datasources remote (API/Modbus)
5. Implémenter les tests unitaires

