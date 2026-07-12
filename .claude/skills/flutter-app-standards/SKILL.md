---
name: flutter-app-standards
description: Standards obligatoires pour toute app Flutter/Firebase que je développe (CRUD complet, responsive, i18n-ready, navigation, notifications, UX/design). Utiliser dès qu'on écrit ou modifie du code Flutter/Dart, dès le début d'un nouveau projet, ou pour ajouter/modifier une feature.
---

# Standards app Flutter/Firebase

Ce skill encode mes règles non-négociables, accumulées après plusieurs projets où l'agent a oublié des choses importantes. Ne pas les redemander à chaque session — les appliquer par défaut.

## 1. CRUD — toujours complet, jamais juste le Create

Pour CHAQUE entité du projet (ex: repas, mesures, commandes), les 4 opérations doivent exister avant de considérer la feature "faite" :
- **Create** : après la création, l'UI doit se mettre à jour SANS refresh manuel.
- **Read** : liste ET détail. Vérifier que le modèle Dart (`fromJson`/`fromMap`) contient exactement les mêmes champs que ce qui est écrit dans Firestore au Create. Un champ ajouté/renommé côté écriture doit être répercuté immédiatement côté modèle de lecture.
- **Update** : modification ET renommage doivent être accessibles depuis l'UI, pas seulement possibles en base.
- **Delete** : toujours accessible depuis l'UI, avec confirmation, et suppression réelle des données liées (pas d'orphelins).

**Règle anti-bug de synchronisation** : les listes doivent utiliser un `StreamBuilder` sur une query Firestore (pas un `Future` chargé une fois au build). Si une liste ne se met pas à jour après un create/update/delete, vérifier en premier : (1) Stream vs Future, (2) cohérence exacte modèle Dart ↔ structure Firestore, (3) erreurs de parsing avalées silencieusement (ajouter un log/catch explicite pendant le dev).

Avant de dire qu'une feature CRUD est terminée : tester dans l'ordre create → vérifier apparition dans la liste sans refresh manuel → update → delete.

## 2. Gestion de contexte sur sessions longues

- Tous les 5-10 prompts, je redonnerai un rappel de contexte (idée de base, features). Si le résumé automatique de session semble avoir perdu des détails, redemande-moi explicitement plutôt que de deviner.
- Au démarrage d'un projet ou d'une feature complexe, demande-moi les questions nécessaires pour bien cerner le besoin avant de coder (pas après).
- Pour toute feature, demande explicitement les attentes UX si ambiguës (ex: ajout multiple possible ou non, comportement si liste vide, etc.) plutôt que de supposer.
- Au démarrage d'un gros projet, propose un plan en phases (grandes lignes, pas trop détaillé) que je pourrai réutiliser comme rappel à chaque session.

## 3. Responsive — dès le premier écran

- Aucune taille de composant en dur (pas de `width: 300` codé brut). Utiliser des unités relatives / un package de responsive design (ex: `flutter_screenutil` ou équivalent) et tester mentalement iPad, iPhone 16/SE, et un Android de taille moyenne.
- Toujours envelopper les écrans dans une `SafeArea` — ne jamais laisser le contenu se mélanger aux boutons de navigation natifs ou à la Dynamic Island.

## 4. Textes — jamais en dur

- Aucun texte affiché ne doit être une string codée en dur dans le widget. Passer par un système de clés/traductions dès le début (même si une seule langue est active pour l'instant), pour permettre le multilingue plus tard sans réécriture.

## 5. Navigation et routing

- Utiliser un routeur déclaratif (type `go_router`) plutôt que la navigation par défaut, configuré dès le début du projet.
- Le routing doit être pensé pour supporter plus tard : deep links (clic sur un lien qui ouvre directement un écran précis de l'app), parrainage, partage de lien. Ne pas fermer cette porte par une architecture de navigation trop rigide.

## 6. Notifications

- Prévoir la configuration de base des notifications push (setup des dépendances/permissions) dès le début du projet, même si aucune notification n'est encore envoyée.

## 7. Auth et sécurité

- Authentification, règles de sécurité Firestore, et gestion des configs sensibles (clés, env) doivent être mises en place dès le début, pas ajoutées après coup.

## 8. Design et UX

- Aucun emoji dans l'UI, sauf demande explicite contraire.
- Composants réutilisables, code épuré — éviter la duplication de widgets similaires.
- Toujours prévoir un onglet/écran Paramètres-Profil (au minimum : personnalisation couleur/thème, gestion du compte).
- Si le thème est sombre, ne pas utiliser de bordures blanches pures (agressif visuellement) — préférer des tons gris clair/atténués pour les séparateurs et bordures.
- Si l'app a beaucoup de modules/fonctionnalités, prévoir un moyen de désactiver ceux qui ne sont pas utilisés (éviter la surcharge visuelle/cognitive).
- Prévoir la possibilité de plusieurs types de visualisation quand c'est pertinent (ex: liste ET calendrier pour des éléments datés).

## 9. Architecture

- Structurer le projet pour qu'il reste facilement scalable (séparation claire des couches : data/domain/UI, pas de logique métier dans les widgets).

## Checklist avant de considérer une feature "terminée"

- [ ] Create / Read / Update / Delete tous fonctionnels et accessibles depuis l'UI
- [ ] Liste se met à jour sans refresh manuel après chaque opération
- [ ] Modèle Dart cohérent avec la structure Firestore actuelle
- [ ] Aucune taille en dur, testé mentalement sur petit et grand écran
- [ ] SafeArea appliquée
- [ ] Aucun texte en dur (passe par le système de traduction)
- [ ] Aucun emoji non demandé
- [ ] Navigation compatible deep link si pertinent pour cette feature
