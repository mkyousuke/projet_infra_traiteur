# Architecture du Projet – Infrastructure & SI pour un Traiteur

## 1. Présentation générale  
Ce document décrit l’architecture du projet local “Traiteur” mis en place dans VMware.  
Il couvre la topologie réseau, la configuration des machines virtuelles, les services déployés et les bonnes pratiques de sécurité.

---

## 2. Topologie réseau  

```text
+----------------+       VMnet1 (Host-only)       +---------------+
| VM1            | 192.168.10.1                  | VM2           |
| Windows Server |◀──────────────────────────────▶| Xubuntu Client|
+----------------+ 192.168.10.20                 +---------------+
````

* **Réseau** : Host-only (VMnet1), isolé sans accès Internet
* **Masque** : 255.255.255.0 (/24)
* **Passerelle** : 192.168.10.1 (adresse du serveur)

---

## 3. Machines virtuelles

| VM                                    | OS                  | Rôle                | IP |
| ------------------------------------- | ------------------- | ------------------- | -- |
| VM1                                   | Windows Server 2022 | • Serveur Web (IIS) |    |
| • Script de sauvegarde                |                     |                     |    |
| • Planificateur de tâches             | 192.168.10.1        |                     |    |
| VM2                                   | Xubuntu 24.10       | • Poste client      |    |
| • Tests de connectivité et navigation | 192.168.10.20       |                     |    |

---

## 4. Configuration réseau

### Windows Server (VM1)

* Interface réseau connectée à **VMnet1**
* IPv4 statique :

  ```text
  Adresse :   192.168.10.1  
  Masque :    255.255.255.0  
  Passerelle : (aucune)  
  DNS :       (n/a)  
  ```

### Xubuntu (VM2)

* Interface `ens33` connectée à **VMnet1**
* IPv4 statique :

  ```text
  Adresse :   192.168.10.20  
  Masque :    255.255.255.0  
  Passerelle : 192.168.10.1  
  DNS :       8.8.8.8 (optionnel)  
  ```

---

## 5. Services déployés

### 5.1 IIS – Serveur web

* Installation :

  ```powershell
  Install-WindowsFeature Web-Server -IncludeManagementTools
  ```
* Racine du site : `C:\inetpub\wwwroot\index.html`
* Page HTML “vitrine” du traiteur

### 5.2 Sauvegarde automatisée

* Script PowerShell (`scripts/script_sauvegarde.ps1`) :

  ```powershell
  $source      = "C:\inetpub\wwwroot"
  $date        = Get-Date -Format "yyyy-MM-dd_HH-mm"
  $destination = "C:\backups\backup_$date.zip"
  Compress-Archive -Path $source -DestinationPath $destination
  ```
* Dossier de destinaton : `C:\backups`
* Planification quotidienne via le Planificateur de tâches (portée Privé, HTTP sur 80 autorisé)

---

## 6. Sécurité et pare-feu

* **Pare-feu Windows Defender**

  * Port 80 (HTTP) autorisé en entrée pour le profil Privé
  * Règle ajoutée via PowerShell :

    ```powershell
    New-NetFirewallRule `
      -DisplayName "Autoriser HTTP IIS" `
      -Direction Inbound `
      -Protocol TCP -LocalPort 80 `
      -Action Allow `
      -Profile Private
    ```
* **Principes appliqués**

  * Adressage statique
  * Isolation réseau (host-only)
  * Automatisation (basse maintenance)

---

## 7. Validation et tests

* **Ping**

  ```bash
  ping -c 4 192.168.10.1  
  ```
* **Accès web**

  * Depuis Xubuntu : `http://192.168.10.1` → page “Chez le traiteur”
* **Sauvegarde**

  * Exécution manuelle et planifiée → archives ZIP présentes dans `C:\backups`

---

