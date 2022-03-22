/home/pi/scripts/buzzer.sh 0.02
echo "tag : $1"
adminFile="/home/pi/admin"
admin="[04472762636280]"
isAdmin=1;
mainmenu() {
    echo -ne
    "
    MAIN MENU
    1) CMD1
    0) Exit
    Choose an option:
    "
    read -r ans
        case $ans in
         1)
            submenu
            mainmenu
            ;;
        0)
            echo
            "Bye bye."
            exit 0
            ;;
        *)
            echo
            "Wrong option."
            exit 1
            ;;
        esac
}
mainmenu
for line in $(cat $adminFile);
do
    if [ $1 = $line ]
    then
        echo "Admin"
        isAdmin=0; 
    fi
done

if [ $isAdmin -eq 1 ]
then
    echo "Classic"
fi
