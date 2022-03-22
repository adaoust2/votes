#!/bin/bash

adminFile="/home/pi/projet/admin"
externeFile="/home/pi/projet/externe"
listeVotantFile="/home/pi/projet/listeVotant"
listePingFile="/home/pi/projet/listePing"
voteFile="/home/pi/projet/vote"

score() {
    nbLigne=$(wc -l $listePingFile |cut -d' ' -f1)
    for ((i=0;i<=$nbLigne;i++))
    do
        tab[$i]=0
    done

    while read line;
    do
        tab[$line]=$((tab[line]+1))
    done < $voteFile
    
    i=0
    while read line;
    do
        echo "$line : "$((tab[i]))" Votes"
        i=$((i+1))
    done < $listePingFile
}
affcherPing() {
    echo "Liste des pings"
    i=0
    while read line;
    do
        echo "$i) $line"
        i=$((i+1))
    done < $listePingFile
}

votePing() {
    nbLigne=$(wc -l $listePingFile |cut -d' ' -f1)
 
    read -r vote
    
    until [ $vote -ge 0 ] && [ $vote -lt $nbLigne ]
    do
        echo "Enculer rentre un ping correct"
        read -r vote
    done
    echo "$vote" >> $voteFile
}

voteExterne() {
    echo "Veuiller enter votre login:"
    read login
    echo "Veuiller enter votre password:"
    read -s pass
    
    isVote=1
    for line in $(cat $listeVotantFile);
    do
        if [ $login = $line ]
        then
            echo "Vous avez deja votez"
            isVote=0; 
        fi
    done

    if [ $isVote -eq 1 ]
    then
        passDb=$(cat $externeFile | grep $login | cut -d' ' -f2)
        if [ $passDb == $pass ]
        then

            echo "Choisissez votre ping pref :"
            affcherPing
            votePing
            score
            echo "$login" >> $listeVotantFile
        else
            echo "Wrong Password :"
        fi
    else
        score
    fi
}

addExterne() {
    echo "Entre Votre login"
    read login

    isUsed=0
    for line in $(cat $externeFile | cut -d' ' -f1);
    do
        if [ $login = $line ]
        then
            isUsed=1; 
        fi
    done

    if [ $isUsed -eq 1 ]
    then
        echo "Erreur login existant Recommencez"
        addExterne
    fi


    echo "Password:"
    read -s pass1
    echo "Repeat Password:"
    read -s pass2
    if [ $pass1 != $pass2 ]
    then
        echo "Erreur password Recommencez"
        addExterne
    else
        echo "Bravo externe ajoutée"
        echo "$login $pass1" >> $externeFile
    fi
}

addAdmin() {
    echo "Presenter le future badge admin"
    badge=$(/home/pi/projet/reader)
    isAdmin=1
    for line in $(cat $adminFile);
    do
        if [ $badge = $line ]
        then
            isAdmin=0; 
        fi
    done

    if [ $isAdmin -eq 0 ]
    then
        echo "Vous etes déja admin"
    else
        echo "$badge" >> $adminFile
        echo "Le Badge $badge est maintenant admin"
    fi
}

delVote() {

    rm $voteFile
    touch $voteFile

    rm $listeVotantFile
    touch $listeVotantFile
    echo "Votes Reinitialiser"
}

delData() {
    delVote
    rm $listePingFile
    touch $listePingFile
    echo "Liste Ping Reinitialiser"
}

addPing() {
    echo "Entrer le nouveau sujet"
    read sujet
    echo "$sujet" >> $listePingFile
}
admin() {
    badge=$(/home/pi/projet/reader)
    /home/pi/projet/buzzer.sh 0.02
    isAdmin=1
    for line in $(cat $adminFile);
    do
        if [ $badge = $line ]
        then
            isAdmin=0; 
        fi
    done
    if [ $isAdmin -eq 1 ]
    then
        echo "Vous n'etes pas admin"
    else
        echo "
    MENU Admin
    
    7) Reinitialiser tous les datas(ping et vote)
    6) Reinitialiser tous les votes
    5) Add projet ping
    4) Add externe
    3) Add Admin
    2) Afficher le resultat des votes
    1) Afficher ListVotant
    0) Back to main menu
    Choose an option:"
        read -r ans
        case $ans in
        7)
            delData
            admin
            ;;
        6)
            delVote
            admin
            ;;
        5)
            addPing
            admin
            ;;
        4)
            addExterne
            ;;
        3)
            addAdmin
            admin
            ;;
        2)
            score
            admin
            ;;
        1)
            afficherVotant
            mainmenu
            ;;
        0)
            ;;
        *)
            echo
            "Wrong option."
            exit 1
            ;;
        esac
    fi
}

afficherVotant() {
    i=0
    while read line;
    do
        echo "$i) $line"
        i=$((i+1))
    done < $listeVotantFile
}




vote() {
    echo "Veuiller Biper votre carte"
    badge=$(/home/pi/projet/reader)
    /home/pi/projet/buzzer.sh 0.02
    echo "Badge: $badge"
    isVote=1
    for line in $(cat $listeVotantFile);
    do
        if [ $badge = $line ]
        then
            echo "Vous avez deja votez"
            isVote=0; 
        fi
    done

    if [ $isVote -eq 1 ]
    then
        echo "Choisissez votre ping pref :"
        affcherPing
        votePing
        score
        echo "$badge" >> $listeVotantFile
    else
        score
    fi

}


mainmenu() {
    echo "
    MENU Principal
    4) Connection Admin
    3) Voir les pings
    2) Vote externe
    1) Voter
    0) Exit
    Choose an option:"
    read -r ans
    case $ans in

    4)
        admin
        mainmenu
        ;; 
    3)
        affcherPing
        mainmenu
        ;;
    2)
        voteExterne
        mainmenu
        ;;
       
    1)
        vote
        mainmenu
        ;;
    0)
        echo "Bye bye."
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}
mainmenu