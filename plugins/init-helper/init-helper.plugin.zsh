# use it e.g. via 'Restart apache2'
zmodload zsh/stat
local SUDO
(( EUID != 0 )) && SUDO='sudo' || SUDO=''
if [[ -d /etc/init.d || -d /etc/service ]] ; then
    __start_stop() {
        local action_="${1:l}"  # e.g Start/Stop/Restart
        local service_="$2"
        local param_="$3"

        local service_target_="$(readlink /etc/init.d/$service_)"
        if [[ $service_target_ == "/usr/bin/sv" ]]; then
            # runit
            case "${action_}" in
                start) if [[ ! -e /etc/service/$service_ ]]; then
                           $SUDO ln -s "/etc/sv/$service_" "/etc/service/"
                       else
                           $SUDO "/etc/init.d/$service_" "${action_}" "$param_"
                       fi ;;
                # there is no reload in runits sysv emulation
                reload) $SUDO "/etc/init.d/$service_" "force-reload" "$param_" ;;
                *) $SUDO "/etc/init.d/$service_" "${action_}" "$param_" ;;
            esac
        else
            if [[ "$(stat +link /sbin/init)" == "/lib/systemd/systemd" ]]; then
                # systemd
                $SUDO "systemctl" "${action_}" "${service_}.service" "$param_"
            else
                # sysvinit
                $SUDO "/etc/init.d/$service_" "${action_}" "$param_"
            fi
        fi
    }

    for i in Start Restart Stop Force-Reload Reload Status; do
        eval "$i() { __start_stop $i \"\$1\" \"\$2\" ; }"
    done
fi
