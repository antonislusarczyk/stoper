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

    echo "1) Start"
    echo "2) Stop"
    echo "3) Reset"
    echo "4) Exit"
    echo -n "Wybór: "

    # zmienna poczetek - czast oistatniego startu
    # zmienna sumka - wszystkich zakonczonych odcinkow
    poczatek=0;
    sumka=0;
    czyleci=0
    #date +%s%N
    while true; do
      read -rsn1 -t 0.1 input
      #echo "sumka po readzie: " $sumka

      case $input in
              1)
                  # TODO: start
                  # podmiernic poczetek
                  #echo "start"
                  poczatek=$(date +%s%N)
                  czyleci=1
                  ;;
              2)
                  # TODO: stop
                  # dodac do sumki aktulany -0 poczatek
                  #echo "stop"
                  # shellcheck disable=SC1073
                  akt=$(date +%s%N)
                  sumka=$((sumka+akt-poczatek))
                  czyleci=0
                  poczatek=$(date +%s%N)
                  ;;
              3)
                  # wyzerowac sumke - reset
                  sumka=0;
                  ;;
              4)
                  exit 0
                  ;;
              *)
                  #echo "Nieznana opcja"
                  ;;
      esac
      #echo "sumka po casie: " $sumka
      # pobierz
      # wypisz czas sumka + aktualny - poczek (chyba z ejstesmy w stopie to wtedy tylko sumka) w tej jednej linijce
      #aktu=$(date +%s%N)
      akt=$(date +%s%N)
      local t=$(( $sumka ))
      if [ "$czyleci" -eq 1 ]; then
          #echo "leci t: " $t
          t=$((t + akt - poczatek))
      fi
      t=$(( $t / 1000000000 ))


      #echo "t: "$t
      echo -ne "\r$(format_time "$t")  "
      #sleep 0.1

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
