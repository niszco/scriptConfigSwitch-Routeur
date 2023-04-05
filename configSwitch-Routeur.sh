#!/bin/bash
#Ce script peut être utilisé pour créer un fichier de configuration de switch ou de routeur automatiquement selon les besoins de l'utilisateur.
#ATTENTION : Il faudra créer un fichier texte au préalable qui pourra contenir les choix de l'utilisateur !

echo -n "Saisissez le nom de votre fichier : "
read file
if [ -f $file.txt ]
then 
rm $file.txt
else 
echo "Le fichier n'existe pas !"
fi

function choixSwitchRouteur {
    while true 
    do
        echo "Souhaitez-vous configurer un switch ou un routeur ? (S / R) : "
        read choix
        if [[ $choix =~ ^[sS]{1}$ ]]; then
        echo "Vous avez choisi de configurer un switch"
        return 1
        fi
        if [[ $choix =~ ^[rR]{1}$ ]]; then
        echo "Vous avez choisi de configurer un routeur"
        return 1
        fi
    done
}

function activationDomainLookup {
   while true
    do
        echo -n "Voulez-vous activer le 'no ip domain-lookup' : (O / N)"
        read activation
        case $activation in
        O)
            echo no ip domain-lookup >> $file.txt
            return 1
            ;;
        N)
        echo "no ip domain-lookup n'est pas activé"
        return 1
        ;;
        esac
    done 
}

function setClockTimezone {
    while true 
    do  
        echo -n "Souhaitez-vous mettre à jour l'horloge interne de votre appareil ? (O / N)"
        read clock
        case $clock in
            O)
                echo clock timezone UTC +2 >> $file.txt
                return 1
                ;;
            N)
                echo "L'horloge interne de l'appareil n'as pas été changé !"
                return 1
                ;;
            esac
        done
}

function nomHote {
    while true
    do
        echo -n "Veuillez renseigner le nom d'hôte : "
        read nom
        if [[ $nom =~ ^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$ ]]; then
            echo hostname $nom >> $file.txt
            return 1
        fi
    done
}

function lignesChoisir {
    while true
    do
        echo -n "Choisissez le nombres de lignes vty que vous désirez affecter : "
        read nbLignes
        let ligneNum=nbLignes+0
        let ligneMax=15
        let ligneMin=0
        if [[ $ligneNum -ge $ligneMin && $ligneNum -le $ligneMax && $nbLignes =~ ^[0-9]+$ ]]; then
            echo line vty 0 $nbLignes >> $file.txt
            return 1
        fi
    done
}

function chiffrementMdp {
   while true
    do
        echo -n "Voulez-vous chiffrer les mots de passe ? : (O / N)"
        read activation
        case $activation in
        O)
            echo service password-encryption >> $file.txt
            return 1
            ;;
        N)
        echo "ok"
        return 1
        ;;
        esac
    done 
}

function addressageIp {
    while true
    do  
        echo -n "Veuillez renseigner l'adresse ip : "
        read ipAddress
        echo -n "Veuillez renseigner le masque de sous-réseaux de votre adresse ip : "
        read subnetMask
        if [[ $ipAddress =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0))$ && $subnetMask =~ ^(255\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0))$ ]]; then
            echo ip address $ipAddress $subnetMask >> $file.txt
            return 1
        fi
    done
}

function activationSSH {
    while true
    do
        echo -n "Voulez-vous activer le SSH : (O / N)"
        read activation
        case $activation in
        O)
            while true
            do
                echo -n "Choisissez le nombres de lignes vty que vous désirez affecter : "
                read nbLignes
                let ligneNum=nbLignes+0
                let ligneMax=15
                let ligneMin=0
                if [[ $ligneNum -ge $ligneMin && $ligneNum -le $ligneMax && $nbLignes =~ ^[0-9]+$ ]]; then
                    echo line vty 0 $nbLignes >> $file.txt
                    echo exec-timeout 5 30 >> $file.txt
                    echo transport input ssh >> $file.txt
                    nomDomaine
                    configurationSSH
                    UtilisateurCreation
                    return 1
                fi
            done
            ;;
        N)
        echo "ok"
        return 1
        ;;
        esac
    done 
}

function nomDomaine {
    while true
    do
        echo -n "Veuillez renseigner le nom de domaine de votre choix : "
        read nomDomaine
        if [[ $nomDomaine =~ ^[a-zA-Z0-9.:/-]{0,100}$ ]]; then
            echo ip domain name $nomDomaine >> $file.txt
            return 1
        fi
    done
}

function configurationSSH {
    while true
    do
        echo -n "Veuillez indiquer la valeur pour la clé en bits (360, 512, 1024, 2048) : "
        read cleValeur
        if [[ $cleValeur = "360" || $cleValeur = "512" || $cleValeur = "1024" || $cleValeur = "2048" ]]; then
            echo crypto key generate rsa modulus $cleValeur >> $file.txt
            return 1
        fi
    done
}

function UtilisateurCreation {
    while true
    do
        echo -n "Veuillez renseigner votre nom d'utilisateur : "
        read username
        echo -n "Veuillez renseigner votre mot de passe pour l'utilisateur : "
        read mdpUser
        echo username $username secret $mdpUser >> $file.txt
        echo "login (local)" >> $file.txt
        echo transport input ssh >> $file.txt
        return 1
    done
}

while true
do
    choixSwitchRouteur
    echo enable >> $file.txt
    activationDomainLookup
    echo configure terminal >> $file.txt
    setClockTimezone
    nomHote
    echo -n "Le message de bannière :"
    read banniere
    diese=#
    messageBanniere=$diese+$banniere+$diese
    echo banner motd $messageBanniere >> $file.txt
    echo line console 0 >> $file.txt
    echo -n "le mot de passe pour la console : "
    read mdpConsole
    echo password $mdpConsole >> $file.txt
    echo -n "le mot de passe pour le privilège : "
    read mdpSecret
    echo enable secret $mdpSecret >> $file.txt
    lignesChoisir
    echo -n "le mot de passe pour les lignes vty : "
    read mdpLigne
    echo password $mdpLigne >> $file.txt
    echo login >> $file.txt
    chiffrementMdp
    echo interface vlan 1 >> $file.txt
    addressageIp
    activationSSH
    echo exit >> $file.txt
    echo voici un bilan
    echo "le nom de l'hôte = " $nom
    echo "l'adresse ip = " $ipAddress
    echo  "le masque de sous-réseaux = " $subnetMask
    echo -n "Appuyez sur entrée pour quitter : "
    read entree
    exit 0
done

