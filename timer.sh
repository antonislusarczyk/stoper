#!/usr/bin/env bash

RED=""
GREEN=""
YELLOW=""
RESET=""

format_time() {
    printf "%02d:%02d" $(( $1 / 60 )) $(( $1 % 60 ))
}

progress_bar() {
    local current=$1 total=$2
    local percent=$(( (total-current) * 100 / total ))
    local bars=$((percent/10))
    printf "[%.*s%.*s] %d%%"         "$bars" "##########"         "$((10-bars))" "----------"         "$percent"
}

log_event() {
    echo "[$(date '+%F %H:%M')] $1" >> pomodoro.log
}

STOPPED=0  # flaga globalna do kontrolowania przerwania
interrupt() {
    echo -e "\n${YELLOW}Przerwano. Czy zakończyć? (t/n)${RESET}"
    read ans
    if [[ "$ans" == "t" ]]; then
        echo "Zakończono program."
        exit 0
    else
        STOPPED=1
    fi
}
trap interrupt SIGINT

run_pomodoro() {
    local work=${1:-25}
    local break=${2:-5}
    local cycles=${3:-4}

    for ((c=1; c<=cycles; c++)); do
        
        echo -e "${GREEN}--- POMODORO #$c: praca $work min ---${RESET}"
        total=$((work*60))

        for ((t=total; t>0; t--)); do
            echo -ne "\r$(format_time "$t")  "
            progress_bar "$t" "$total"
            sleep 1
        done

        log_event "Pomodoro #$c finished"
        echo -e "\n${GREEN}Koniec pracy!${RESET}"

        echo -e "${YELLOW}--- Przerwa $break min ---${RESET}"
        total=$((break*60))
        for ((t=total; t > 0; t--)); do
            echo -ne "\r$(format_time "$t")  "
            progress_bar "$t" "$total"
            sleep 1
        done

        echo -e "\n${YELLOW}Koniec przerwy!${RESET}"
    done
}

run_stoper() {
    local running=false
    local sec=0

    while true; do
        echo "1) Start"
        echo "2) Stop"
        echo "3) Reset"
        echo "4) Exit"
        echo -n "Wybór: "
        
        read choice

        case $choice in
            1)
                # TODO: start
                ;;
            2)
                # TODO: stop
                ;;
            3)
                # TODO: reset
                ;;
            4)
                exit 0
                ;;
            *)
                echo "Nieznana opcja"
                ;;
        esac
    done
}

case "$1" in
    pomodoro)
        run_pomodoro "$2" "$3" "$4"
        ;;
    stoper)
        run_stoper
        ;;
    *)
        echo "Użycie:"
        echo "  $0 pomodoro [czas_pracy] [czas_przerwy] [cykle]"
        echo "  $0 stoper"
        ;;
esac
