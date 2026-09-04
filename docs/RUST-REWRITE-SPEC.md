# KpRm — Spécification pour une réécriture en Rust

> Document de référence pour reconstruire KpRm "à l'identique" (parité fonctionnelle côté
> utilisateur) avec un code base moderne, maintenable et testable, écrit en Rust,
> développé sous Linux et compilé/cross-compilé pour s'exécuter sur Windows.
>
> Ce document ne dit pas "copiez ce code AutoIt en Rust" : chaque section décrit le
> **comportement observable** attendu, le **pourquoi**, puis une **proposition d'implémentation
> Rust idiomatique**, en signalant explicitement où on peut (et devrait) faire mieux que
> l'existant.

---

## 0. Résumé exécutif

KpRm est un outil Windows, développé en **AutoIt3**, utilisé en fin de désinfection pour
nettoyer l'ordinateur des dizaines d'outils de désinfection tiers (AdwCleaner, ZHPCleaner,
FRST, Dr.Web CureIt, ESET *Cleaner, décrypteurs de ransomware, etc.) qu'un technicien ou un
particulier a utilisés. Il :

1. supprime les fichiers/dossiers/clés de registre/tâches planifiées/process de **202 outils**
   connus, décrits dans un fichier de config XML (`tools.xml`, ~1250 lignes) ;
2. sait fonctionner en mode **« recherche personnalisée »** (scan, puis l'utilisateur choisit
   quoi supprimer dans une liste) ;
3. gère la **quarantaine** de certains outils (suppression immédiate, différée de 7 jours via
   une tâche planifiée, ou conservation) ;
4. sauvegarde le registre (ruche `SOFTWARE` + `NTUSER.DAT`) via un instantané VSS ou, en
   secours, via un utilitaire externe embarqué (`HoboCopy.exe`) ;
5. crée/supprime des points de restauration système ;
6. restaure les valeurs par défaut de l'UAC et remet à zéro des réglages réseau/Explorer ;
7. s'auto-supprime après exécution (« HaraKiri ») ;
8. est traduit en 8 langues (FR/EN/DE/IT/PT/RU/ES/NL), sélection automatique via la langue
   OS ;
9. nécessite les droits administrateur (`#RequireAdmin`).

Le code source (`src/`) pèse ~9 080 lignes d'AutoIt réparties sur 23 fichiers, plus 4 DLL et
2 EXE tiers embarqués (HoboCopy 32/64 bits), plus le catalogue XML de 202 outils.

L'objectif de la réécriture : **même service rendu à l'utilisateur (idéalement meilleur)**,
mais un code base :

- compilé (pas de runtime AutoIt à distribuer),
- **couvert par des tests unitaires** dès le premier commit — c'est une exigence non
  négociable de ce projet, pas une amélioration facultative à faire "si le temps le permet".
  Le moteur de suppression actuel est aujourd'hui **intestable** (indissociable de la GUI,
  état global mutable) : c'est précisément le défaut principal que l'architecture en traits
  du §5.1 est conçue pour éliminer, dans le but explicite de pouvoir écrire ces tests unitaires
  (détail des attentes et de la stratégie en §9),
- sans binaire tiers non auditable embarqué en hexadécimal dans le source (`_DosDev_Exe`, voir
  §3.6),
- avec un format de configuration versionnable/diffable proprement et validable,
- avec des interfaces stables entre "catalogue de règles", "moteur d'exécution" et "UI",
  permettant un mode CLI headless en plus du mode GUI,
- buildable depuis Linux (toolchain croisée `x86_64-pc-windows-gnu` ou `-msvc` via `xwin`),
  avec une CI qui exécute les tests sur un runner Windows.

---

## 1. Analyse du projet existant

### 1.1 Arborescence et rôle des fichiers

```
src/
├── kpRm.au3                          # point d'entrée, GUI principale, boucle d'événements
├── config/
│   └── tools.xml                     # catalogue des 202 outils à nettoyer (règles)
├── assets/                           # icône, logo animé, bouton de fermeture (gif)
├── binaries/
│   ├── hobocopy32/HoboCopy.exe(+dll) # copie de fichiers verrouillés (registre), fallback
│   └── hobocopy64/HoboCopy.exe(+dll)
└── kp_includes/
    ├── includes.au3                  # agrège tous les #include (UDF stdlib + libs + fonctions)
    ├── variables.au3                 # état global (versions, couleurs UI, dimensions, etc.)
    ├── kp_languages.au3              # 8 traductions statiques, sélection via @OSLang
    ├── kprm_is_running.au3           # empêche une 2e instance (mutex nommé)
    ├── functions/
    │   ├── functions.au3             # orchestration haut niveau (Init, KpRemover, KpSearch, RunRemoveTools, parsing du XML → tâches)
    │   ├── remove.au3                # bas niveau : suppression fichier/dossier/clé, énumération, permissions
    │   ├── backup.au3                # sauvegarde registre (VSS + fallback HoboCopy)
    │   ├── system_restore.au3        # points de restauration (WMI / SrClient.dll / PowerShell)
    │   ├── quarantines.au3           # quarantaine différée (tâche planifiée + registre)
    │   ├── search.au3                # mode "scan puis sélection manuelle"
    │   ├── uac.au3                   # restauration des valeurs UAC par défaut
    │   ├── system_settings.au3       # reset réseau + réglages Explorer
    │   ├── style.au3                 # wrapper thème XP + custom msgbox
    │   └── progress_bar.au3          # barre de progression (26 étapes)
    └── libs/                         # UDF (bibliothèques) tierces/maison, réutilisables telles quelles
        ├── permissions.au3           # ACL Windows : take ownership, grant/deny access (1741 lignes)
        ├── xml_dom_wrapper.au3       # wrapper MSXML/XPath (1756 lignes) — sert à lire tools.xml
        ├── ext_msg_box.au3           # message box custom dessinée (845 lignes)
        ├── taskplaner_com.au3        # wrapper COM Task Scheduler 2.0 (777 lignes)
        ├── jsmn.au3                  # parseur JSON — **inclus mais jamais appelé** (mort)
        ├── string_size.au3           # mesure de texte GDI, utilisé par ext_msg_box
        └── comerrorhandler.au3       # handler d'erreurs COM générique
```

### 1.2 Dépendances externes

- Runtime AutoIt3 (compilé en exécutable autonome via Aut2Exe, donc pas de dépendance à
  l'installation mais un gros binaire).
- `HoboCopy.exe` (projet tiers, licence Apache-2.0, https://github.com/candera/hobocopy),
  embarqué en 32 et 64 bits avec ses DLL runtime MSVC 2010 (`msvcp100.dll`, `msvcr100.dll`).
- COM : `Scripting.Dictionary`, `Microsoft.XMLDOM`/MSXML, WMI (`winmgmts:root/default`,
  classe `SystemRestore`), Task Scheduler (`Schedule.Service`).
- `powershell.exe` utilisé en fallback pour lister/activer les points de restauration
  (`Get-ComputerRestorePoint`, `Enable-ComputerRestore`, `Checkpoint-Computer`).
- `netsh`, `ipconfig`, `schtasks.exe`, `wmic.exe`, `vssadmin.exe` invoqués en sous-process.
- Un petit utilitaire "dosdev" (assignation de lettre de lecteur à un volume shadow copy)
  **embarqué comme flux d'octets hexadécimaux directement dans le code source** et écrit sur
  disque à l'exécution (`_DosDev_Exe` dans `backup.au3`). C'est un exécutable PE32 complet,
  non versionné en tant que binaire, non recompilable depuis les sources du dépôt : c'est le
  pire des deux mondes (ni du code, ni un artefact traçable).

### 1.3 Licence

Le dépôt est sous **GPLv3** (`LICENSE`). Une réécriture qui repart de zéro conceptuellement
(nouveau langage, nouvelle architecture) mais qui **reprend le catalogue `tools.xml`** (la
vraie valeur du projet : des années de contributions communautaires identifiant précisément
chaque outil) doit rester compatible GPLv3, sauf si vous êtes vous-même titulaire des droits
suffisants pour changer la licence. À trancher en amont du projet, indépendamment de la partie
technique — ce document suppose que vous restez sous GPLv3 ou une licence compatible.

---

## 2. Ce que fait KpRm — spécification fonctionnelle observable

Cette section décrit le comportement **du point de vue utilisateur**, indépendamment de
l'implémentation, pour servir de base à la définition de "parité" avec le futur outil Rust.

### 2.1 Démarrage

1. L'exécutable **exige l'élévation administrateur** (UAC) dès le lancement.
2. Un **mutex nommé** (`KpRm_MUTEX`) empêche une deuxième instance ; si détectée, message
   "KpRm déjà lancé" / "Already Running!" (selon la langue du système) puis sortie.
3. Un répertoire temporaire est recréé (`%TEMP%\KPRM`), et les assets embarqués (catalogue
   XML, logo, icône de fermeture) y sont extraits.
4. **Mode CLI caché** : si l'exécutable est lancé avec l'argument `quarantines <timestamp>`,
   il ne montre **aucune** UI : il exécute la suppression différée des éléments mis en
   quarantaine 7 jours plus tôt (voir §2.7), puis quitte. C'est ce mode qui est invoqué par la
   tâche planifiée créée automatiquement.
5. Sinon, affichage d'un **écran de disclaimer** (licence "AS IS", pas d'usage commercial) —
   Oui/Non. Si Non → sortie immédiate sans rien faire.

### 2.2 Fenêtre principale

Fenêtre sans bordure standard (dessinée à la main, déplaçable en drag sur la primary-down),
500×263px, thème sombre (fond noir, texte blanc/bleu/vert). Contient :

- Titre + version.
- Deux onglets logiques bascule par labels cliquables (pas de vrais tabs Win32 visibles) :
  **"Automatique"** et **"Personnalisé"**.
- Une barre de statut texte en bas ("Ready...", puis messages d'avancement en temps réel).
- Une barre de progression en bas (0–100%).
- Un logo animé (gif) et un bouton de fermeture custom (image), pas de barre de titre Windows
  standard.

#### Onglet "Automatique"

Groupe **Actions** (checkboxes) :
- ☐ Supprimer les outils
- ☐ Supprimer les points de restauration
- ☐ Créer un point de restauration
- ☐ Sauvegarder le registre
- ☐ Restaurer UAC
- ☐ Restaurer les paramètres système

Groupe **Supprimer les quarantaines** (mutuellement exclusif entre les deux, et chacun
sélectionne automatiquement "Supprimer les outils" s'il est coché) :
- ☐ Supprimer maintenant
- ☐ Supprimer dans 7 jours

Bouton **Exécuter** : si aucune case n'est cochée → avertissement "Vous devez choisir une
action". Sinon, exécute les actions cochées dans cet ordre fixe (voir §2.5), avec logging et
barre de progression, affiche "Toutes les opérations sont terminées", ouvre le rapport dans
notepad, redémarre si nécessaire, **puis l'exécutable se supprime lui-même**.

#### Onglet "Personnalisé"

- Bouton **Analyser** : lance un scan en lecture seule de tout ce que le catalogue peut
  détecter (mêmes règles que le mode automatique mais rien n'est supprimé), puis remplit une
  **liste à cocher** (une ligne par chemin fichier/dossier/clé de registre détecté, triée).
  Si rien trouvé → message "Aucun outil trouvé".
- Boutons **Tous** / **Aucun** / **Vider** pour manipuler la sélection ou réinitialiser la
  liste (repasse en mode "Analyser").
- Bouton **Supprimer** (remplace "Analyser" une fois qu'un scan a trouvé quelque chose) :
  ferme les process associés aux lignes cochées, supprime chaque élément coché (fichier,
  dossier ou clé de registre — reconnu par la forme du chemin), écrit le rapport, ouvre
  notepad. **Ce mode ne respecte pas la logique de quarantaine 7 jours ni le check "keep"** :
  suppression immédiate systématique de ce qui est coché.

### 2.3 Fermeture / fin de traitement

- Croix custom ou fermeture standard → sortie immédiate, sans confirmation.
- Après une exécution réussie (auto ou custom) : message "Terminé", ouverture du rapport texte
  dans Notepad, et **l'exécutable planifie sa propre suppression** (`del` différé de 5s via
  `cmd.exe`, ou `MoveFileEx` avec `MOVE_FILE_DELAY_UNTIL_REBOOT` si un redémarrage est
  nécessaire).

### 2.4 Détection multilingue

Langue choisie automatiquement selon `@OSLang` (code de langue Windows), mapping :
`0C→FR, 10→IT, 07→DE, 0A→ES, 16→PT, 13→NL, 19→RU, sinon EN`. Pas de sélecteur manuel dans
l'UI.

### 2.5 Ordre d'exécution du mode automatique

Fixé dans `KpRemover()` (`functions.au3`), toujours dans cet ordre si coché :

1. Initialisation (crée `%HOMEDRIVE%\KPRM`, écrit l'en-tête du rapport : date, version,
   utilisateur, machine, OS, nombre de passages précédents).
2. Initialisation des ressources de permissions (privilèges `SeTakeOwnership`,
   `SeRestore`, `SeBackup`, `SeSecurity`, `SeDebug` — voir §3.1).
3. **Sauvegarde du registre** si cochée.
4. **Suppression des outils** si cochée (sinon la barre de progression avance quand même pour
   rester cohérente visuellement) — voir §2.6.
5. **Restauration des paramètres système** si cochée.
6. **Restauration UAC** si cochée.
7. **Suppression des points de restauration** si cochée.
8. **Création d'un point de restauration** si cochée.
9. Libération des ressources de permissions.
10. Programmation de la suppression différée des quarantaines à 7 jours si ce mode a été
    choisi.
11. Redémarrage si des éléments n'ont pas pu être supprimés (voir §2.8).
12. Message de fin, ouverture du rapport, auto-suppression de l'exécutable.

### 2.6 Moteur de suppression des outils — les 20 types d'action

Le catalogue XML (`tools.xml`) décrit, pour chacun des 202 outils, une liste d'« actions »
(éléments XML enfants de `<tool name="...">`). Chaque type d'action a une sémantique propre.
**Toutes les recherches par nom de fichier/process/clé sont des regex** (syntaxe PCRE, presque
toujours `(?i)^...` insensible à la casse, ancré en début de chaîne).

Table de référence — c'est le **cœur du domaine métier** à réimplémenter fidèlement :

| Action (tag XML)      | Attributs                                   | Portée parcourue                                                                 | Comportement |
|---|---|---|---|
| `process`              | `process` (regex), `companyName` (regex opt.), `force` (0/1) | Tous les process en cours (`ProcessList()`) | Ferme tout process dont le nom matche la regex (et dont le `CompanyName` du binaire matche si fourni), sauf liste blanche (§2.9). `force=1` → tue directement (`TerminateProcess` via l'API permissions) ; sinon `ProcessClose` + attente ~12.5s (50×250ms) avant abandon. |
| `uninstall`             | `folder` (regex), `uninstaller` (regex)     | Sous-dossiers de `Program Files` / `Program Files (x86)` | Cherche un dossier dont le nom matche `folder`, puis dedans un exécutable dont le nom matche `uninstaller`, et le **lance** (`RunWait`) — désinstallation "propre" via le désinstalleur fourni par l'outil lui-même. |
| `task`                  | `name` (nom exact)                          | Planificateur de tâches                | `schtasks /delete /tn "<name>" /f` |
| `desktop`               | `pattern` (regex), `companyName`, `type` (file/folder) | `%DESKTOP%`, profondeur -2 (récursif limité), filtré sur extensions `exe;txt;lnk;log;reg;zip;dat;scr;com;bat;mbr;iso;pif;rtf` | Supprime fichiers/dossiers correspondants |
| `desktopCommon`         | idem                                         | Desktop commun à tous les utilisateurs (non récursif) | idem |
| `download`              | idem                                         | `%USERPROFILE%\Downloads`, récursif limité (-2) | idem |
| `programFiles`          | (aucun — dérivé de `desktop`/`download` etc. avec le même nom/pattern que les autres actions du même tool) | `Program Files` + `Program Files (x86)` (non récursif racine) | idem (partage la même liste de règles que les autres actions "fichier" du tool) |
| `homeDrive`             | `pattern`, `companyName`, `type`, `quarantine` (0/1) | Racine du lecteur système (non récursif) | idem, avec **gestion de quarantaine** (voir §2.7) si `type=folder` |
| `appData`, `appDataCommon`, `appDataLocal`, `windowsFolder` | `pattern`, `companyName`, `type` | `%APPDATA%`/commun/local, `%WINDIR%` (non récursif racine) | idem |
| `softwareKey`           | `pattern` (regex sur le nom de sous-clé)    | `HKCU\SOFTWARE` et `HKLM\SOFTWARE` (+ vue 64 bits `...64` si OS x64) | Énumère les sous-clés, supprime celles dont le nom matche |
| `registryKey`           | `key` (chemin exact)                        | Clé de registre donnée                 | Vérifie l'existence (a au moins une valeur), supprime récursivement |
| `searchRegistryKey`     | `key`, `pattern` (regex), `value` (nom de la valeur à lire) | Sous-clés de `key`                     | Énumère les sous-clés de `key`, lit la valeur nommée `value` de chacune, si son **contenu** matche `pattern` → supprime cette sous-clé (sert typiquement à retrouver une entrée `Uninstall` par son `DisplayName`) |
| `startMenu`             | `pattern`, `companyName`, `type`            | Menu Démarrer commun                    | idem |
| `userStartMenu`         | idem                                         | Menu Démarrer de l'utilisateur          | idem |
| `cleanDirectory`        | `path` (avec macros, voir §2.10), `companyName`, `quarantine` | Contenu (fichiers directs, non récursif) du dossier donné | Vide le **contenu** d'un dossier connu (ex : dossier de quarantaine d'un AV) sans forcément matcher un pattern par fichier — avec gestion de quarantaine |
| `file`                  | `path` (avec macros), `companyName`         | Chemin de fichier absolu donné          | Supprime ce fichier précis s'il existe |
| `folder`                | `path` (avec macros), `quarantine`          | Chemin de dossier absolu donné          | Supprime ce dossier précis s'il existe, avec gestion de quarantaine |

Notes transverses :

- Une **liste blanche codée en dur** de noms de fichiers (extensions MKV Toolnix) et de
  process (composants SoftGrid `sftvsa.exe`, `sftlist.exe`, `SftService.exe`) est vérifiée
  avant toute suppression de fichier/process pour éviter des faux positifs connus.
- Le paramètre `companyName` est un filtre de sécurité additionnel : avant de supprimer un
  `.exe`/`.com`, on lit son attribut de version `CompanyName` et on vérifie qu'il matche la
  regex attendue (`FileGetVersion`) — évite de supprimer un fichier homonyme appartenant à un
  autre éditeur.
- Toute suppression réussie mais dont le fichier ne peut pas être physiquement effacé
  immédiatement (verrouillé) déclenche : (a) tentative `DeleteFileW` bas niveau, (b) sinon
  planification via `MoveFileExW(..., MOVE_FILE_DELAY_UNTIL_REBOOT)`, (c) ajout à la liste des
  éléments nécessitant un redémarrage + écriture d'une clé `RunOnce` de secours (commande
  `cmd.exe /c IF EXIST ... DEL/RMDIR`).
- Avant suppression, chaque fichier/dossier/clé a ses **permissions réinitialisées** : DACL
  effacée, accès complet accordé à l'utilisateur courant, attributs (Read-only, System,
  Hidden, etc.) retirés (voir §3.1).
- L'ordre de parcours des 20 types d'action est fixe (`aListActions` dans `functions.au3`) et
  commence toujours par tuer les process, avant de fermer `notepad.exe` s'il tourne (pour ne
  pas garder le rapport précédent ouvert).
- Après suppression, un **rapport de contrôle** vérifie a posteriori pour chaque type d'élément
  visé par au moins un outil trouvé si l'action a réellement abouti (process toujours vivant ?
  clé encore lisible ? fichier encore présent ?) et logge `[OK]` / `[X]` / `[R]` (R =
  suppression différée au redémarrage) en conséquence.

### 2.7 Gestion de la quarantaine

Certains éléments (`homeDrive`, `cleanDirectory`, `folder`) peuvent porter `quarantine="1"`.
Comportement :

- **Suppression immédiate** cochée → supprimé comme n'importe quel autre élément.
- **Suppression dans 7 jours** cochée → l'élément est **conservé** pour ce passage, son chemin
  est écrit dans le rapport ("Quarantines that will be deleted in 7 days (<date>)"), puis :
  1. l'exécutable courant est **copié** vers `%HOMEDRIVE%\KPRM\tasks-quarantines\kprm-quarantines.exe` ;
  2. chaque chemin à garder est écrit comme valeur dans
     `HKLM[64]\Software\KPRM\quarantines\<timestamp>` ;
  3. une **tâche planifiée** `KpRm-quarantines\KpRm-quarantines-<timestamp>` est créée
     (déclencheur temporel dans 7 jours, avec une fenêtre de 4 mois pour rattraper si la
     machine était éteinte, exécution 5 min après logon, niveau "highest", "seulement si
     utilisateur connecté") qui lance `kprm-quarantines.exe quarantines <timestamp>`.
- **Aucune des deux cochée** → l'élément est **conservé indéfiniment**, juste listé dans le
  rapport sous "Quarantines keeped".
- **Cas spécial permanent** : le dossier de quarantaine `%APPDATA%\ZHP` n'est **jamais**
  proposé à la suppression (choix explicite du projet en respect de l'éditeur ZHPCleaner), il
  est seulement mentionné dans le rapport ("Quarantines never deleted").

Exécution différée (`quarantines <timestamp>`, invoquée par la tâche planifiée, sans UI) :
1. Ouvre (si présents) le rapport du jour J (`%HOMEDRIVE%\KPRM\kprm-<timestamp>.txt`) et sa
   copie sur le Bureau, y ajoute une section "Deletions scheduled (<date>)".
2. Relit chaque valeur de `HKLM[64]\Software\KPRM\quarantines\<timestamp>`, supprime le fichier
   ou dossier correspondant, logge le résultat.
3. Nettoie la clé de registre du run, puis la clé parente `quarantines` et `KPRM` si elles
   deviennent vides.
4. Supprime la tâche planifiée elle-même ; si le **dossier** de tâches
   `KpRm-quarantines` devient vide (aucune autre suppression différée en attente), le
   supprime aussi.
5. S'auto-supprime (HaraKiri).

### 2.8 Nécessité de redémarrage

Si au moins un élément n'a pas pu être supprimé immédiatement (verrouillé), après la fin de
toutes les actions cochées :
- Écrit une clé `RunOnce` par élément restant (commande `DEL`/`RMDIR` conditionnelle).
- Écrit une clé `RunOnce` supplémentaire pour rouvrir le rapport texte après redémarrage.
- Planifie l'auto-suppression de l'exécutable au redémarrage (`MoveFileEx` delay-until-reboot).
- Affiche "Vous devez redémarrer votre ordinateur…" puis propose un redémarrage immédiat
  (`Shutdown(6)` = restart+force, avec repli `Shutdown(2)` = restart simple si le premier
  échoue) — **sans demander confirmation supplémentaire**, dès que l'utilisateur a validé la
  boîte de dialogue précédente.

### 2.9 Liste blanche anti faux-positifs

Codée en dur (`utils.au3`) :
- Fichiers : `MKVPlayerSetup*.exe`, `MKVExtractGUI*.exe`, `mkvpropedit*.exe`,
  `mkvinfo*.exe`, `mkvextract*.exe`, `mkvmerge*.exe`, `mkvtoolnix*.exe`, `MkvToMp4*.exe`.
- Process : `sftvsa.exe`, `sftlist.exe`, `SftService.exe` (App-V / SoftGrid — un pattern
  regex trop large dans le catalogue peut sinon les confondre avec un outil de désinfection).

### 2.10 Macros de chemin

Les chemins `path="..."` du catalogue XML peuvent commencer par un pseudo-variable résolu à
l'exécution (`FormatPathWithMacro`) : `@AppDataCommonDir`, `@DesktopDir`, `@LocalAppDataDir`,
`@HomeDrive`, `@TempDir`, `@UserProfileDir`.

### 2.11 Sauvegarde du registre

Deux ruches sauvegardées : `HKLM\SOFTWARE` (fichier `%WINDIR%\System32\config\SOFTWARE`) et le
profil utilisateur courant (`NTUSER.DAT`). Stratégie à deux niveaux :
1. **Principal** : instantané VSS (Volume Shadow Copy) du lecteur système via `wmic shadowcopy
   call create`, assignation d'une lettre de lecteur libre au volume shadow (via un utilitaire
   externe minimal type `dosdev`/`DefineDosDevice`), copie des fichiers de ruche depuis ce
   volume gelé (contourne le verrouillage des ruches en cours d'utilisation), puis suppression
   du shadow copy et de la lettre temporaire.
2. **Fallback** si VSS échoue : `HoboCopy.exe` (32 ou 64 bits selon l'arch), un outil tiers
   capable de copier des fichiers verrouillés sans VSS.

Destination : `%HOMEDRIVE%\KPRM\backup\<horodatage>\...` (arborescence miroir du chemin
d'origine).

### 2.12 Points de restauration système

- **Suppression de tous les points existants** : énumération via WMI
  (`winmgmts:root/default!SystemRestore`, avec repli PowerShell `Get-ComputerRestorePoint`
  si WMI indisponible), suppression un par un via `SrClient.dll!SRRemoveRestorePoint`,
  avec re-vérification après un délai de 5s en cas d'échec apparent (contournement d'un bug
  connu où l'API renvoie parfois un code d'erreur alors que la suppression a réussi).
- **Création d'un nouveau point** : active la protection système sur le lecteur système (WMI
  `SystemRestore.Enable`, repli PowerShell `Enable-ComputerRestore`), tente WMI
  `SystemRestore.CreateRestorePoint("KpRm", 100, 7)`, vérifie s'il existe déjà un point nommé
  "KpRm" ; sinon tente l'API native `SRSetRestorePointW` ; sinon supprime les points trop
  récents (<24.5h) puis retente en PowerShell `Checkpoint-Computer`. Logge succès/échec.

### 2.13 Restauration UAC

Réécrit 10 valeurs `REG_DWORD` sous
`HKLM[64]\Software\Microsoft\Windows\CurrentVersion\Policies\System` à leurs valeurs par
défaut Windows (table complète en §2.13 du README, reproduite ici) :

| Valeur | Défaut |
|---|---|
| EnableLUA | 1 |
| ConsentPromptBehaviorAdmin | 5 |
| ConsentPromptBehaviorUser | 3 |
| EnableInstallerDetection | 0 |
| EnableSecureUIAPaths | 1 |
| EnableUIADesktopToggle | 0 |
| EnableVirtualization | 1 |
| FilterAdministratorToken | 0 |
| PromptOnSecureDesktop | 1 |
| ValidateAdminCodeSignatures | 0 |

### 2.14 Restauration des paramètres système

- `netsh winsock reset`, `netsh winhttp reset proxy`, `netsh winhttp reset tracing`,
  `netsh winsock reset catalog`, `netsh int ip reset all`, `netsh int ipv4 reset catalog`,
  `netsh int ipv6 reset catalog`, `ipconfig /flushdns`.
- `HKCU\...\Explorer\Advanced` : `Hidden=2` (cacher fichiers cachés), `HideFileExt=0` (montrer
  les extensions), `ShowSuperHidden=0` (cacher fichiers protégés système).
- Redémarre `explorer.exe` proprement pour appliquer ces changements immédiatement.

### 2.15 Journalisation

- Fichier texte simple, écrit **en double** : `%HOMEDRIVE%\KPRM\kprm-<AAAAMMJJHHMMSS>.txt` et
  `%DESKTOP%\kprm-<même timestamp>.txt` (le deuxième pour que l'utilisateur/technicien le
  retrouve facilement, ouvert automatiquement en fin de run).
- Format texte humain avec sections (`- Delete Tools -`, `- Errors -`, etc.) et préfixes
  `[OK]` / `[X]` / `[I]` / `[R]` / `[?]`, pas de format structuré (pas de JSON/CSV).
- Aucune rotation/purge automatique des anciens rapports dans `%HOMEDRIVE%\KPRM`.

---

## 3. Sous-systèmes Windows à réimplémenter

### 3.1 Gestion des permissions/ACL

`permissions.au3` réimplémente en AutoIt, via `DllCall` bruts, une bonne partie de l'API
Windows de sécurité (`GetNamedSecurityInfo`, `SetNamedSecurityInfo`, construction manuelle de
DACL/ACE, `LookupAccountName`, `ConvertStringSidToSid`, privilèges de process via
`AdjustTokenPrivileges`…). En Rust, on n'a **pas besoin de réinventer ça** :

- Crate **[`windows`](https://crates.io/crates/windows)** (bindings officiels Microsoft,
  générés depuis les métadonnées Win32) pour tout ce qui est bas niveau : `Security`,
  `Storage::FileSystem`, `System::Registry`, `System::Threading`, `System::Com`,
  `System::TaskScheduler`.
- Crate **[`windows-acl`](https://crates.io/crates/windows-acl)** pour manipuler des ACL de
  fichiers/registre à un niveau plus haut (équivalent direct de
  `_GrantAllAccess`/`_ClearObjectDacl`/`_SetObjectPermissions`).
- Privilèges à activer au démarrage (équivalent de `_InitiatePermissionResources`) :
  `SeTakeOwnershipPrivilege`, `SeRestorePrivilege`, `SeBackupPrivilege`, `SeSecurityPrivilege`,
  `SeDebugPrivilege` (ce dernier nécessaire pour pouvoir terminer des process appartenant à
  d'autres utilisateurs/services). Encapsuler ça dans un RAII guard Rust
  (`PrivilegeGuard::acquire(&[...])`, restaure/relâche au `Drop`) — c'est strictement plus sûr
  que le couple `_InitiatePermissionResources`/`_ClosePermissionResources` manuel actuel, où un
  chemin d'erreur/`Exit` prématuré peut sauter la libération.

### 3.2 Suppression de fichiers verrouillés

Reproduire fidèlement la cascade :
1. `std::fs::remove_file` / `remove_dir_all` (équivalent `DeleteFile`/`RemoveDirectory`).
2. Si échec, retirer les attributs read-only/system/hidden puis réessayer.
3. Si toujours verrouillé, appeler `MoveFileExW` avec
   `MOVEFILE_DELAY_UNTIL_REBOOT` (nécessite `SeRestorePrivilege`, déjà acquis en §3.1) via le
   crate `windows`. Fonction sûre à écrire une fois, testée isolément.
4. Repli supplémentaire : écrire une entrée `RunOnce` avec une commande `cmd /c del /f /q` /
   `rmdir /s /q` conditionnelle, pour les cas où même `MoveFileEx` échoue — **note** : c'est
   une redondance historique dans le code d'origine (`MoveFileEx` delay-until-reboot est déjà
   censé garantir la suppression). À conserver pour compatibilité comportementale/robustesse
   mais documenter que c'est une ceinture-et-bretelles.

### 3.3 Sauvegarde de registre — simplification recommandée

L'original utilise VSS + un utilitaire externe embarqué en hexadécimal comme roue de secours
(`HoboCopy`). Recommandation forte pour la réécriture : **remplacer toute cette mécanique par
l'API registre native `RegSaveKeyExW`**, qui sait sauvegarder une ruche même en cours
d'utilisation via le flag `REG_LATEST_FORMAT`, sans passer par VSS ni par un outil tiers, à
condition d'avoir `SeBackupPrivilege` (déjà acquis en §3.1). C'est disponible directement via
le crate `windows` (`Win32::System::Registry::RegSaveKeyExW`), pas de `DllCall` à la main, pas
de binaire tiers à embarquer/auditer, pas de dépendance à `wmic`/VSS pour ce cas précis.

- Éliminer entièrement `HoboCopy.exe`/DLL embarqués et le hack `_DosDev_Exe` (binaire PE en
  hex dans le source, cf. §1.2) : c'est à la fois une dette technique et un point d'attention
  sécurité (un binaire non signé, non recompilable depuis les sources, exécuté avec des
  privilèges élevés).
- Si un jour un vrai besoin de "copier des fichiers verrouillés génériques" apparaît (pas
  seulement les ruches), VSS reste faisable proprement via le crate
  **[`vss`](https://crates.io/crates/vss)** ou des bindings `windows` directs sur
  `IVssBackupComponents` (COM), sans réimplémenter une usine à gaz `wmic`+parsing de texte
  comme le fait le code actuel (`_wmic_CreateShadowCopy` parse la sortie texte de `wmic` avec
  des `StringInStr`…).

### 3.4 Points de restauration système

- `SrClient.dll!SRSetRestorePointW` / `SRRemoveRestorePoint` : bindings directs possibles via
  `windows-sys`/`windows` en déclarant l'appel `extern "system"` (la DLL n'a pas de métadonnées
  Win32 officielles, donc `link!`/`LoadLibrary`+`GetProcAddress` à la main, comme le fait déjà
  l'AutoIt — mais typé et testé en Rust plutôt que via `DllStructCreate` générique).
- Énumération WMI (`root\default`, classe `SystemRestore`) : crate
  **[`wmi`](https://crates.io/crates/wmi)** (désérialisation typée via `serde`, bien plus sûr
  que le parsing manuel actuel), avec repli PowerShell (`Command::new("powershell")`,
  `Get-ComputerRestorePoint`) si WMI est indisponible (postes durcis où WMI est bridé).
- Conserver la logique de "double vérification après délai" (bug connu de l'API), mais
  l'exprimer clairement comme un commentaire technique (`// SRRemoveRestorePoint retourne
  parfois un échec alors que la suppression a réussi ; on revérifie après 5s`) plutôt que
  comme un commentaire d'excuse ("This horrible code exists because…").

### 3.5 Planificateur de tâches

`taskplaner_com.au3` est un wrapper COM maison assez complet du Task Scheduler 2.0
(`Schedule.Service`). En Rust : bindings directs via le crate `windows`
(`Win32::System::TaskScheduler`, interfaces `ITaskService`, `ITaskFolder`, `IRegisteredTask`,
`ITaskDefinition`, `ITriggerCollection`, etc.), typés, sans réinventer le parsing d'erreurs COM
à la main (`comerrorhandler.au3` devient inutile : le crate `windows` retourne des `Result<_,
windows::core::Error>` normaux).

- Fonctions à couvrir, équivalentes à celles de `taskplaner_com.au3` : créer/supprimer un
  dossier de tâches, créer une tâche avec déclencheur temporel + fenêtre de rattrapage,
  supprimer une tâche, lister les tâches d'un dossier, vérifier l'existence.
- Alternative plus simple à considérer pour le MVP : shell out vers `schtasks.exe` (déjà fait
  par l'original pour la *suppression* de tâches d'outils tiers). Moins élégant que la COM
  typée mais réduit la surface de code Windows-spécifique au début du projet ; on peut migrer
  vers la COM typée dans un second temps sans changer le contrat (`TaskScheduler` trait, voir
  §5).

### 3.6 UAC / réglages système / réseau

Purement registre (`RegSetValueExW`, via le crate `windows` ou même simplement le crate
**[`winreg`](https://crates.io/crates/winreg)**, plus ergonomique pour ce genre d'accès
simples) + quelques `Command::new("netsh"/"ipconfig")`. Partie la plus simple du projet.

### 3.7 Détection/fermeture de process

- Snapshot des process : `CreateToolhelp32Snapshot` + `Process32First/Next` (via `windows`) ou
  crate **[`sysinfo`](https://crates.io/crates/sysinfo)** (multi-plateforme, pratique aussi
  pour un futur portage/tests sous Linux du moteur "hors I/O Windows spécifique").
- Chemin de l'exécutable d'un PID : `QueryFullProcessImageNameW`.
- `CompanyName` d'un binaire : lire les ressources de version (`GetFileVersionInfoW` +
  `VerQueryValueW`), ou crate **[`pelite`](https://crates.io/crates/pelite)** /
  **[`rust-version-info`]** pour parser proprement le bloc `VS_VERSIONINFO` sans FFI manuel.
- Fermeture "douce" (`WM_CLOSE`/`ProcessClose` équivalent : envoyer un signal de fermeture puis
  attendre) vs "forcée" (`TerminateProcess`, nécessite `SeDebugPrivilege` pour les process
  d'autres utilisateurs/services) — reproduire les deux modes (`force="0"/"1"` du catalogue).

### 3.8 Auto-suppression ("HaraKiri")

Deux cas à couvrir, comme l'original :
- Suppression décalée simple : relancer un processus détaché (`cmd /c timeout 5 && del /f /q
  "<exe>"`, ou plus propre : un petit sleep+delete dans un processus enfant détaché écrit en
  Rust plutôt qu'en invoquant `cmd.exe` — trivial et évite une dépendance à `cmd.exe`).
- Suppression au redémarrage : `MoveFileExW(current_exe, None,
  MOVEFILE_DELAY_UNTIL_REBOOT)`.

### 3.9 Élévation et manifeste

`#RequireAdmin` en AutoIt équivaut, en Rust, à embarquer un **manifeste d'application** avec
`requestedExecutionLevel="requireAdministrator"` dans les ressources du binaire. Depuis Linux,
c'est faisable sans MSVC via le crate build-dep
**[`winresource`](https://crates.io/crates/winresource)** (fork actif de `winres`, fonctionne
avec `llvm-rc`/`rc.exe` selon la toolchain) ou **[`embed-manifest`](https://crates.io/crates/embed-manifest)**,
déclenché dans `build.rs`, en embarquant aussi l'icône (`.ico`, à regénérer depuis
`assets/bug.ico`/`bug.gif`) et les métadonnées de version (nom produit, version, copyright —
équivalent des directives `#AutoIt3Wrapper_Res_*`).

### 3.10 Détection de langue / dossiers connus

- Langue UI Windows : `GetUserDefaultUILanguage`/`GetSystemDefaultUILanguage` via `windows`, ou
  simplement lire la locale via le crate **[`sys-locale`](https://crates.io/crates/sys-locale)**
  puis mapper vers le même jeu de 8 langues (garder la table de mapping identique pour la
  parité, voir §6).
- Dossiers connus (`@DesktopDir`, `@AppDataDir`, etc.) : `SHGetKnownFolderPath` via `windows`,
  ou crate **[`known-folders`](https://crates.io/crates/known-folders)** /
  **[`dirs`](https://crates.io/crates/dirs)** pour la version multi-plateforme (utile si vous
  gardez un moteur testable sous Linux, voir §7).

---

## 4. Catalogue d'outils — nouveau format proposé

### 4.1 Limites du format actuel

- XML + XPath re-résolu par requête (`_XMLSelectNodes("/tools/tool[" & $i & "]/*")` dans une
  boucle imbriquée) : fonctionnel mais lent (re-parse une expression XPath à chaque accès) et
  aucune validation de schéma appliquée en pratique (pas de XSD chargé au runtime).
- Pas de commentaire structuré au-delà des `<!-- -->` HTML classiques (un seul dans tout le
  fichier, "Please keep me after AdsFix" — indique une dépendance d'ordre implicite fragile
  entre deux entrées, à rendre explicite dans le nouveau format, voir §4.3).
- Attributs booléens en chaînes `"0"`/`"1"` plutôt que des booléens typés.
- Pas de métadonnées (auteur de l'outil, URL, date d'ajout) autres que le commentaire libre
  dans le README (liste "nom (auteur)").

### 4.2 Format proposé : TOML, un fichier par outil, dans un répertoire `tools.d/`

Plutôt qu'un unique fichier de 1250 lignes, préférer **un fichier TOML par outil** (202
petits fichiers `tools.d/<slug>.toml`), pour des diffs Git lisibles et des revues de PR
ciblées (contribution communautaire, comme aujourd'hui sur `tools.xml` mais bien plus
accessible à un contributeur non technicien) :

```toml
# tools.d/adwcleaner.toml
name = "AdwCleaner"
author = "Malwarebytes"          # optionnel, informatif — remplace la colonne README
homepage = "https://www.malwarebytes.com/adwcleaner"  # optionnel

[[actions]]
type = "desktop"
pattern = '(?i)^AdwCleaner.*\.exe$'
company_name = '(?i)^Malwarebytes'

[[actions]]
type = "download"
pattern = '(?i)^AdwCleaner.*\.exe$'
company_name = '(?i)^Malwarebytes'

[[actions]]
type = "home_drive"
pattern = '(?i)^AdwCleaner'
kind = "folder"
quarantine = true

[[actions]]
type = "process"
pattern = '(?i)^AdwCleaner.*\.exe$'
company_name = '(?i)^Malwarebytes'
force = false
```

- `type` = un des 20 types listés en §2.6, en `snake_case`.
- Champs optionnels absents = valeurs par défaut (`company_name = ""`, `force = false`,
  `quarantine = false`), validés par `serde` avec `#[serde(default)]` — remplace la logique
  `GetSwapOrder`/`Swap` de remplissage manuel des colonnes manquantes.
- **Validation au build/CI** : un test charge tous les fichiers de `tools.d/`, vérifie que
  chaque regex compile (crate `regex`), que les champs requis par type d'action sont présents
  (erreur de compilation de test si un outil a un `path` manquant pour `type = "file"`, etc.),
  et peut détecter les doublons de `name`. C'est un contrôle **statique en CI**, alors
  qu'aujourd'hui une erreur de ce type (`__REQUIRED__` manquant) n'est détectée **qu'à
  l'exécution**, potentiellement chez l'utilisateur final (`CustomMsgBox(16, "Fail", ...)`
  suivi d'un `Exit` brutal).
- Au démarrage, l'application charge et fusionne tous les fichiers de `tools.d/` (soit
  embarqués via `include_str!`/`rust-embed` dans le binaire pour rester un exécutable unique
  distribuable, soit lus depuis un dossier `tools.d/` à côté de l'exe pour permettre une mise à
  jour du catalogue indépendante des releases — les deux ne sont pas exclusifs, voir §8).
- **Migration automatique** : écrire un petit script ponctuel (Rust ou même Python, jetable)
  qui parse `tools.xml` existant et génère les 202 fichiers TOML — préserve tout
  l'historique/la connaissance déjà encodée, à faire une seule fois en tout début de projet
  puis ne plus jamais retoucher `tools.xml`.
- **Dépendance d'ordre implicite** (`AdsFix` avant `Ads`, cf. commentaire XML) : dans le
  moteur actuel, l'ordre de match importe uniquement si deux outils différents ont des règles
  qui se chevauchent sur le même fichier — dans le nouveau moteur, documenter et **tester
  explicitement** ce cas de chevauchement plutôt que compter sur l'ordre des entrées d'un
  fichier (voir §4.3).

### 4.3 Chevauchements de règles — clarifier le contrat

Le format actuel ne dit jamais explicitement ce qui doit se passer si deux outils ont un
`pattern` qui matche le même fichier. En pratique, `RemoveFileHandler` boucle sur toutes les
règles et applique **la première qui matche** puis continue à boucler (donc un fichier peut en
théorie déclencher plusieurs outils). À spécifier clairement dans le nouveau moteur : soit on
garde ce comportement "premier ou tous les matches déclenchent, sans exclusivité" (le plus
proche de la parité), soit on le durcit en détectant/loggant les chevauchements en test (cf.
`AdsFix`/`Ads`) pour aider les contributeurs à écrire des regex plus précises. Recommandation :
garder le comportement à la parité, mais ajouter un **lint CI** qui liste les paires de règles
dont les `pattern` peuvent matcher la même chaîne (test de génération de contre-exemples avec
un fuzzing léger ou une simple heuristique de préfixe), en warning non bloquant.

---

## 5. Architecture Rust proposée

### 5.1 Organisation en workspace Cargo

```
kprm/
├── Cargo.toml                 # workspace
├── crates/
│   ├── kprm-catalog/          # parsing + modèle de données tools.d/*.toml, validation
│   ├── kprm-engine/           # moteur d'exécution : traits d'abstraction + logique métier pure
│   ├── kprm-windows/          # implémentation concrète des traits pour Windows (permissions, registre, VSS, tâches planifiées, WMI, process)
│   ├── kprm-report/           # génération du rapport (texte humain, parité ; + JSON structuré, amélioration)
│   ├── kprm-i18n/             # chaînes traduites (Fluent) + détection de langue
│   ├── kprm-cli/              # binaire headless (scan/remove/quarantines <ts>, scriptable)
│   └── kprm-gui/              # binaire GUI (le produit final équivalent à KpRm.exe)
└── tools.d/                   # catalogue (202+ fichiers TOML)
```

Le point clé de cette découpe : **`kprm-engine` ne dépend d'aucune API Windows concrète**, il
définit des traits (`FileSystem`, `Registry`, `ProcessManager`, `TaskScheduler`,
`RestorePoints`, `RegistryBackup`) que `kprm-windows` implémente. Ça règle le problème n°1 du
code actuel — **le moteur de suppression est aujourd'hui indissociable de la GUI** (les
fonctions comme `RemoveFile`/`RemoveFolder` lisent des variables globales `$bSearchOnly`,
`$oListView`, etc. directement) — en le rendant **unitairement testable sur Linux/macOS avec
des doubles de test (fakes) en mémoire**, avant même de toucher à une vraie machine Windows.

```rust
// kprm-engine/src/ports.rs — esquisse des abstractions
pub trait FileSystem {
    fn exists(&self, path: &Path) -> ExistsKind; // None | File | Dir
    fn remove_file(&mut self, path: &Path) -> Result<Removal>;
    fn remove_dir(&mut self, path: &Path) -> Result<Removal>;
    fn list_dir(&self, path: &Path, max_depth: Depth) -> Vec<PathBuf>;
    fn company_name(&self, exe: &Path) -> Option<String>;
}

pub trait Registry {
    fn key_exists(&self, key: &RegKey) -> bool;
    fn enum_subkeys(&self, key: &RegKey) -> Vec<String>;
    fn read_value(&self, key: &RegKey, name: &str) -> Option<String>;
    fn delete_key(&mut self, key: &RegKey) -> Result<()>;
}

pub trait ProcessManager {
    fn list(&self) -> Vec<ProcessInfo>;
    fn close(&mut self, pid: Pid, force: bool) -> Result<bool>;
}

pub enum Removal { DeletedNow, ScheduledOnReboot, Failed }
```

Le moteur métier (`run_action(action: &ToolAction, ctx: &mut dyn EngineContext) -> Outcome`)
manipule uniquement ces traits + le modèle `kprm-catalog`, et produit une liste d'`Outcome`
(trouvé/supprimé/échoué/mis en quarantaine) que `kprm-report` transforme en texte, et que la
GUI transforme en éléments de liste cochables (mode "Personnalisé"). **C'est la même logique
qui sert au mode scan et au mode suppression réelle** (comme aujourd'hui via `$bSearchOnly`),
mais exprimée par un paramètre de mode explicite plutôt qu'une variable globale mutable lue en
profondeur dans chaque fonction bas niveau — supprime toute une classe de bugs potentiels liés
à l'état global partagé mutable de l'AutoIt actuel (`Dim $bSearchOnly` répété dans quasiment
chaque fonction pour "importer" la globale, pattern fragile).

### 5.2 GUI — choix de toolkit

Contrainte forte de l'énoncé : **développer sous Linux, exécuter sous Windows**. Comparatif :

| Toolkit | Cross-compile Linux→Windows sans VM/Windows | Rendu | Verdict |
|---|---|---|---|
| **egui** (`eframe`) | ✅ Excellent — pur Rust, cible `x86_64-pc-windows-gnu` via `mingw-w64` sans dépendance MSVC ni SDK Windows pour le rendu (utilise `wgpu`/`glow`, pas de COM/Win32 GDI) | Immediate-mode, look "custom" par défaut (facile à thémer en sombre pour matcher l'identité visuelle actuelle noir/bleu/vert) | **Recommandé** pour un MVP rapide et un unique produit portable, exactement dans l'esprit de l'appli originale (fenêtre custom déjà dessinée à la main aujourd'hui) |
| **Slint** | ✅ Bon, mais licence à vérifier selon usage (Royalty-free GPLv3/commercial) — compatible avec un projet GPLv3 | Déclaratif, look natif possible | Alternative solide si vous voulez un DSL de mise en page plus proche d'un vrai design UI |
| **iced** | ✅ Bon, pur Rust | Elm-architecture, un peu plus verbeux | Alternative viable |
| **native-windows-gui / winsafe** | ❌ Nécessite le SDK Windows (MSVC) pour la génération de ressources natives — pénible à cross-compiler proprement depuis Linux | Look Win32 natif | Déconseillé ici vu la contrainte "développé sous Linux" |
| **Tauri** (webview) | ⚠️ Compile mais **le webview cible (WebView2) n'est disponible qu'au runtime Windows** — ajoute une dépendance runtime externe (WebView2, préinstallé sur Win10 22H2+/Win11 mais pas systématiquement plus ancien) | HTML/CSS/JS | Déconseillé : réintroduit une dépendance runtime externe, alors que l'original est un exécutable 100% autonome — régression par rapport à l'existant |

**Recommandation : `egui`/`eframe`.** Il permet en plus de conserver le mode CLI headless
(`kprm-cli`) et le mode GUI (`kprm-gui`) comme deux binaires distincts partageant
`kprm-engine`, exactement comme le mode `quarantines <timestamp>` de l'original est déjà, de
fait, un mode headless caché dans le même exécutable.

### 5.3 Cross-compilation depuis Linux — mise en place concrète

```bash
# Toolchain
rustup target add x86_64-pc-windows-gnu
sudo apt install mingw-w64          # ou équivalent distro

# Build
cargo build --release --target x86_64-pc-windows-gnu -p kprm-gui
```

- Pour l'embarquement de manifeste/icône/ressources de version (`build.rs` +
  `winresource`/`embed-manifest`), vérifier leur compatibilité GNU-toolchain (certains outils
  de ressources historiques exigent `rc.exe` de MSVC) : à défaut, `windres` (fourni par
  `mingw-w64`) sait compiler un `.rc` en `.res`/objet, ce qui couvre le besoin.
- Alternative pour cibler MSVC (`x86_64-pc-windows-msvc`, parfois requis par des
  antivirus/EDR plus tatillons sur les binaires "GNU-built") depuis Linux : toolchain
  **[`cargo-xwin`](https://github.com/rust-cross/cargo-xwin)**, qui télécharge le SDK/CRT
  Windows nécessaire (licence Microsoft acceptée via prompt) et permet
  `cargo xwin build --target x86_64-pc-windows-msvc`. À évaluer en fonction du taux de faux
  positifs antivirus observés en pratique (les deux toolchains ont chacune leurs biais de
  détection heuristique, à tester avec VirusTotal avant release, sujet déjà sensible pour ce
  type d'outil).
- CI recommandée (GitHub Actions) : job Linux pour build+clippy+tests unitaires du moteur
  (rapide, sur chaque PR), job **Windows runner** pour tests d'intégration réels (créer un vrai
  fichier verrouillé, une vraie clé de registre, un vrai point de restauration en VM jetable) —
  seul un vrai Windows peut valider ACL/VSS/Task Scheduler/points de restauration
  fidèlement ; ne pas chercher à les mocker "gratuitement" sous Wine (rendu GUI hasardeux,
  et les API registre/VSS/Task Scheduler ne sont pas fidèlement émulées).

### 5.4 Dépendances Cargo principales (indicatif)

```toml
[workspace.dependencies]
windows = { version = "0.58", features = [
    "Win32_Storage_FileSystem", "Win32_System_Registry", "Win32_Security",
    "Win32_System_TaskScheduler", "Win32_System_Threading", "Win32_System_Com",
    "Win32_UI_Shell", "Win32_System_SystemServices",
] }
windows-acl = "0.3"
winreg = "0.52"
wmi = "0.14"
sysinfo = "0.32"
regex = "1"
serde = { version = "1", features = ["derive"] }
toml = "0.8"
fluent = "0.16"
rust-embed = "8"
eframe = "0.29"
tracing = "0.1"
tracing-subscriber = "0.3"
anyhow = "1"
thiserror = "1"
clap = { version = "4", features = ["derive"] }
```

---

## 6. Internationalisation

- Remplacer les 8 fonctions `Lang_XX()` (des blocs de `Global $lXxx = "..."` dupliqués) par des
  fichiers **Fluent** (`.ftl`), un par langue, chargés via le crate `fluent` + `unic-langid`.
  Avantages sur l'original : pluriels, interpolation de variables (`{ $count }`) gérés
  proprement, et surtout **détection au build** des clés manquantes entre langues (le code
  actuel n'a aucune garantie que les 8 fonctions définissent toutes exactement les mêmes
  variables — une variable oubliée dans une traduction planterait silencieusement à l'usage
  d'`AutoItSetOption("MustDeclareVars")` désactivé en prod).
- Table de mapping langue OS → locale à conserver à l'identique pour la parité (`fr, it, de,
  es, pt, nl, ru, en` par défaut), en s'appuyant sur `sys-locale`/`GetUserDefaultUILanguage`
  plutôt que sur le champ `@OSLang` legacy d'AutoIt.
- Clés à couvrir (reprises 1:1 de `kp_languages.au3`, 26 chaînes) : cf. §2 pour leur usage
  contextuel exact ; les valeurs elles-mêmes sont déjà présentes dans le fichier existant et
  peuvent être copiées telles quelles dans les `.ftl` (aucune retraduction nécessaire pour la
  parité initiale).

---

## 7. Rapport et journalisation

- **Parité stricte** : conserver le format texte humain, écrit en double
  (`%HOMEDRIVE%\KPRM\kprm-<ts>.txt` + Bureau), ouvert automatiquement en fin d'exécution.
- **Amélioration proposée (au-delà de la parité)** : générer en parallèle un
  `kprm-<ts>.json` structuré (liste d'`Outcome` sérialisés : type d'action, outil, chemin/clé,
  résultat, horodatage) — permet à un technicien/MSP d'agréger des rapports sur plusieurs
  machines sans parser du texte libre, sans rien changer au rendu texte historique consommé
  par les utilisateurs habitués au format actuel.
- Utiliser `tracing` en interne (niveaux `info`/`warn`/`error`) avec un *layer* custom qui
  alimente à la fois la barre de statut GUI, le fichier de log texte "métier" (celui destiné à
  l'utilisateur) et, en mode dev, la console — sépare clairement le **rapport utilisateur**
  (stable, un contrat de parité) du **log technique de debug** (peut évoluer librement).

---

## 8. Distribution du catalogue et mises à jour

Piste d'amélioration (non nécessaire à la parité, à cadrer avec vous avant de l'implémenter) :
le catalogue de 202 outils vit aujourd'hui dans le binaire (`FileInstall`), donc **toute
nouvelle variante d'un outil de désinfection nécessite une nouvelle release complète de
KpRm**. Une option pour découpler ce cycle : embarquer le catalogue par défaut dans le binaire
(`rust-embed`, pour un fonctionnement 100% offline garanti — pas de régression par rapport à
l'original) mais permettre en plus un **rafraîchissement optionnel** depuis une URL de
confiance (signée, ex. Ed25519 sur le bundle TOML) au lancement, avec repli silencieux sur le
catalogue embarqué si hors-ligne ou si la signature ne vérifie pas. À ne construire qu'après le
MVP à parité, et à documenter clairement pour l'utilisateur (pas de télémétrie cachée — l'outil
actuel n'en a aucune, à préserver).

---

## 9. Tests

### 9.0 Exigence de projet

Les tests unitaires ne sont pas une case à cocher en fin de projet : **chaque module métier
livré doit arriver avec ses tests unitaires dans la même PR**, pas dans un futur ticket
"ajouter les tests". Concrètement :

- Aucune fonction de `kprm-engine` ou `kprm-catalog` n'est mergée sans au moins un test qui
  couvre son comportement nominal et son (ou ses) cas limite(s) le(s) plus évident(s) (entrée
  vide, regex qui ne matche rien, élément déjà absent, etc.).
- Le découpage en traits du §5.1 est **une conséquence directe** de cette exigence : si une
  fonction ne peut être testée qu'en lançant l'exécutable complet sur une vraie machine
  Windows, c'est un signal qu'elle mélange encore logique métier et effets de bord — à
  refactorer avant merge, pas à laisser de côté.
- La CI (§5.3) doit faire **échouer le build** si `cargo test` échoue ou si `cargo tarpaulin`/
  `cargo llvm-cov` détecte une régression de couverture sur `kprm-engine`/`kprm-catalog` par
  rapport à la branche cible — pas seulement `cargo build` + `clippy`.
- Objectif de couverture indicatif : **élevé (>80%) sur `kprm-catalog` et `kprm-engine`**
  (logique pure, sans excuse pour ne pas tester) ; couverture plus faible et pragmatique
  acceptée sur `kprm-windows`/`kprm-gui` (beaucoup d'appels FFI/Win32 qu'on préfère vérifier en
  intégration réelle plutôt que mocker à outrance juste pour faire un chiffre — cf. §9 dernier
  point).
- Chaque bug trouvé après coup s'accompagne d'un test de non-régression qui l'aurait détecté,
  ajouté avant le correctif (pratique "red-green").

### 9.1 Détail par crate

- **`kprm-catalog`** : chargement de tous les fichiers `tools.d/*.toml`, validation de schéma,
  compilation de toutes les regex, détection de doublons de nom d'outil, détection de champs
  requis manquants par type d'action (remplace `GetSwapOrder`/`Swap` avec des erreurs
  détectées en CI plutôt qu'à l'exécution chez l'utilisateur).
- **`kprm-engine`** : tests unitaires purs avec des implémentations *in-memory* des traits
  `FileSystem`/`Registry`/`ProcessManager` (pas besoin de Windows pour tester 90% de la logique
  métier — un gain énorme par rapport à l'AutoIt actuel qui ne peut être testé qu'en conditions
  réelles) : scénarios "un fichier quarantine sans option cochée → conservé", "process dans la
  liste blanche → jamais fermé même si le pattern matche", "chevauchement de deux règles sur le
  même chemin", "élément verrouillé → planifié au redémarrage", etc.
- **`kprm-windows`** : tests d'intégration marqués `#[ignore]` par défaut, exécutés seulement
  sur le runner CI Windows dédié (création réelle d'une clé de registre de test, d'un fichier
  verrouillé via un handle ouvert exprès, etc.), avec nettoyage systématique en fin de test
  (`Drop` guards).
- **Non-régression du catalogue migré** : un test compare, pour un échantillon d'outils migrés
  depuis `tools.xml`, que le nombre d'actions et les regex extraites sont strictement
  identiques à celles du XML d'origine (parse XML de référence gardé en fixture de test, pas en
  dépendance runtime) — garde-fou pour la phase de migration §4.2.

---

## 10. Ce que la réécriture devrait délibérément **ne pas** reproduire

Pour rester honnête sur "identique côté utilisateur, meilleur côté code", voici les points où
la parité de comportement est souhaitable mais où l'**implémentation** actuelle est à éviter
explicitement :

1. **Binaire PE embarqué en hexadécimal dans le source** (`_DosDev_Exe`) — remplacé par l'API
   registre native (§3.3). Ce point mérite d'être traité en priorité même avant le reste : un
   blob binaire non auditable exécuté avec des privilèges élevés est le genre de chose qu'un
   antivirus/EDR ou un auditeur de sécurité repère immédiatement et qui décrédibilise tout le
   projet, indépendamment de sa légitimité réelle.
2. **État global mutable partagé entre GUI et logique métier** (`Dim $bSearchOnly` etc. réimporté
   dans chaque fonction) — remplacé par un mode explicite passé en paramètre (§5.1).
3. **Doublon de `FileInstall(".\config\tools.xml", ...)`** (lignes 33 et 36 de `kpRm.au3`,
   copie-collé involontaire, sans impact fonctionnel mais révélateur d'un manque de tests) — à
   ne simplement pas reproduire.
4. **Dépendance à un parseur JSON jamais utilisé** (`jsmn.au3`) — code mort à ne pas porter, à
   moins qu'un besoin JSON réel émerge (ex. rapport structuré, §7).
5. **Récupération d'ACL/permissions Windows réimplémentée à la main via `DllCall`** — remplacée
   par des crates dédiées et testées par la communauté Rust (§3.1).
6. **Auto-suppression sans étape de confirmation supplémentaire lors du redémarrage forcé**
   (`Shutdown(6)` immédiatement après le message "Restart Now") — à **garder** pour la parité
   fonctionnelle stricte (c'est un choix produit assumé, pas un bug), mais à isoler dans une
   fonction clairement nommée et testée (`force_restart_if_needed`), pas mélangée dans le flux
   général comme aujourd'hui, pour qu'un futur changement de ce comportement précis (ajouter
   un délai annulable, par ex.) soit un diff d'une ligne et non une chasse dans 250 lignes de
   GUI.

---

## 11. Feuille de route proposée (phasage)

> Règle transverse à toutes les phases (voir §9.0) : la colonne "Sortie" inclut **toujours**
> les tests unitaires correspondants — une phase n'est pas considérée terminée si son code est
> livré sans sa suite de tests, même si la fonctionnalité "marche" manuellement.

| Phase | Contenu | Sortie (code **+ tests unitaires**) |
|---|---|---|
| **0 — Cadrage** | Décision de licence (§1.3), choix définitif GUI/CLI (§5.2), mise en place du workspace + CI cross-compile (§5.3) | Squelette qui compile pour `x86_64-pc-windows-gnu` depuis Linux, "Hello World" administrateur avec manifeste UAC ; CI configurée pour faire échouer le build sur `cargo test` (même vide au départ) |
| **1 — Catalogue** | Script de migration XML→TOML (§4.2), `kprm-catalog` avec validation CI | 202 fichiers `tools.d/*.toml` ; tests unitaires de parsing/validation de schéma par type d'action + tests de non-régression comparant chaque outil migré à sa définition XML d'origine (§9.1) |
| **2 — Moteur pur** | `kprm-engine` (traits + logique des 20 types d'action, whitelist, macros de chemin, quarantaine) testé avec des fakes in-memory, **sans aucune dépendance Windows** | Un test unitaire par type d'action (20+), plus les cas limites listés en §9.1 (quarantaine, liste blanche, chevauchement de règles, élément verrouillé) — suite verte sous Linux, sans machine Windows |
| **3 — Adaptateurs Windows** | `kprm-windows` : fichiers/registre/process (§3.1–3.2, 3.6–3.7) | `kprm-cli scan` fonctionnel sur une vraie machine Windows de test ; tests unitaires sur toute logique isolable de l'API Win32 (parsing de `CompanyName`, résolution de macros de chemin, etc.) + tests d'intégration `#[ignore]` pour le reste (§9.1) |
| **4 — Sous-systèmes avancés** | Sauvegarde registre (§3.3), points de restauration (§3.4), planificateur de tâches + quarantaine différée (§3.5, §2.7), auto-suppression (§3.8) | `kprm-cli remove --auto` en parité fonctionnelle complète ; tests unitaires sur le calcul des dates de quarantaine à 7 jours, le format des clés de registre écrites, la construction des commandes planifiées — sans dépendre d'un vrai VSS/Task Scheduler pour ces cas-là |
| **5 — GUI** | `kprm-gui` en egui, reproduisant l'écran EULA, les deux onglets, la liste cochable du mode personnalisé (§2.1–2.2) | Binaire GUI installable, testé manuellement contre les captures d'écran existantes (`screenshots/`) ; tests unitaires sur la logique de transition d'état de l'UI (ex. cocher "Supprimer dans 7 jours" doit cocher "Supprimer les outils", §2.2) indépendamment du rendu |
| **6 — i18n** | Migration des 8 langues vers Fluent (§6) | Détection de langue + 8 `.ftl` complets ; test unitaire qui vérifie que les 8 langues définissent exactement le même jeu de clés (régression impossible à détecter dans l'AutoIt d'origine, cf. §6) |
| **7 — Rapport & CI Windows** | Rapport texte parité + JSON optionnel (§7), tests d'intégration sur runner Windows (§9) | Pipeline CI complet avec seuil de couverture (§9.0), releases signées ; tests unitaires sur le formatage du rapport texte et JSON |
| **8 (optionnel)** | Mise à jour distante du catalogue signée (§8) | — à ne construire qu'après retour d'usage sur la v1 Rust ; tests unitaires sur la vérification de signature et le repli hors-ligne |

---

## 12. Annexe A — table de correspondance macros/constantes AutoIt → Rust

| AutoIt | Signification | Équivalent Rust |
|---|---|---|
| `@DesktopDir` | Bureau utilisateur courant | `SHGetKnownFolderPath(FOLDERID_Desktop)` (`windows` crate) |
| `@DesktopCommonDir` | Bureau commun | `FOLDERID_PublicDesktop` |
| `@AppDataDir` | `%APPDATA%` | `FOLDERID_RoamingAppData` |
| `@AppDataCommonDir` | `%PROGRAMDATA%` | `FOLDERID_ProgramData` |
| `@LocalAppDataDir` | `%LOCALAPPDATA%` | `FOLDERID_LocalAppData` |
| `@HomeDrive` | Lecteur système (`C:`) | `GetSystemWindowsDirectory` → lettre de lecteur, ou `%SystemDrive%` |
| `@UserProfileDir` | `%USERPROFILE%` | `FOLDERID_Profile` |
| `@TempDir` | `%TEMP%` | `std::env::temp_dir()` |
| `@WindowsDir` | `%WINDIR%` | `FOLDERID_Windows` |
| `@OSArch` | Architecture OS | `IsWow64Process2` / `std::env::consts::ARCH` (attention : arch du process ≠ arch OS, reproduire la nuance) |
| `@OSVersion`/`@OSBuild` | Version Windows | `RtlGetVersion` (via `windows`, plus fiable que `GetVersionEx` qui ment depuis Win8.1 sans manifeste adéquat) |
| `@Compiled` | Exécuté en tant que binaire compilé vs script interprété | N/A (Rust est toujours compilé) — la logique conditionnelle associée (`HaraKiri`, `bKpRmDev`) devient un flag de build (`#[cfg(debug_assertions)]` ou variable d'env dédiée) |
| `FileGetVersion(.., "CompanyName")` | Lit `CompanyName` des ressources de version d'un PE | Parsing `VS_VERSIONINFO` (§3.7) |
| `RegEnumKey`/`RegEnumVal` | Énumération registre | `RegEnumKeyExW`/`RegEnumValueW` (`windows`) ou `winreg::RegKey::enum_keys()` |
| `ProcessList()` | Snapshot process | `sysinfo::System::refresh_processes` ou `CreateToolhelp32Snapshot` |
| `Shutdown(6)` / `Shutdown(2)` | Redémarrage forcé / normal | `ExitWindowsEx(EWX_REBOOT \| EWX_FORCE, ...)` / `ExitWindowsEx(EWX_REBOOT, ...)`, nécessite le privilège `SeShutdownPrivilege` (à ajouter à la liste §3.1) |

## 13. Annexe B — schéma récapitulatif des 20 types d'action (attributs requis/optionnels)

| Type | Requis | Optionnels (+ défaut) |
|---|---|---|
| `file` | `path` | `company_name` ("") |
| `folder` | `path` | `quarantine` (false) |
| `desktop`, `desktop_common`, `download`, `home_drive`, `app_data`, `app_data_common`, `app_data_local`, `windows_folder`, `start_menu`, `user_start_menu` | `pattern`, `kind` (file/folder) | `company_name` (""), `quarantine` (false — `home_drive` seulement, ignoré ailleurs à la parité) |
| `clean_directory` | `path` | `company_name` (""), `quarantine` (false) |
| `process` | `pattern` | `company_name` (""), `force` (false) |
| `uninstall` | `folder`, `uninstaller` | — |
| `task` | `name` | — |
| `software_key` | `pattern` | — |
| `registry_key` | `key` | — |
| `search_registry_key` | `key`, `pattern`, `value` | — |

---

## 14. Sources internes consultées pour ce document

Analyse basée sur une lecture exhaustive de `src/kpRm.au3`,
`src/kp_includes/{includes,variables,kp_languages,kprm_is_running}.au3`,
`src/kp_includes/functions/*.au3` (10 fichiers), l'inventaire des fonctions publiques de
`src/kp_includes/libs/{permissions,xml_dom_wrapper,taskplaner_com,ext_msg_box,comerrorhandler}.au3`,
un échantillon représentatif de `src/config/tools.xml` (202 outils, 20 types de balises
distincts, statistiques d'attributs), `README.md` et `LICENSE`. Les binaires embarqués
(`HoboCopy.exe`/DLL) n'ont pas été désassemblés ; leur rôle est documenté d'après leur usage
dans `backup.au3` et le projet amont référencé en commentaire.
