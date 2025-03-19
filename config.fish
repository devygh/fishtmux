if status is-interactive
    # Не запускать внутри tmux
    if not set -q TMUX
        # Установка зависимостей
        if not type -q fzf
            echo "Устанавливаем fzf..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all --key-bindings --completion --no-update-rc
        end

        if not type -q tmux
            echo "Устанавливаем tmux..."
            sudo apt-get install -y tmux || brew install tmux
        end

        # Настройки tmux
        set -l TMUX_CONF $HOME/.tmux.conf
        touch $TMUX_CONF

        # Базовые настройки
        echo "
# Сохраняем дефолтный префикс Ctrl+B
set -g detach-on-destroy off
set -g default-terminal 'screen-256color'
set -g mouse on

# Плагины (опционально)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
" > $TMUX_CONF

        # Предложение запустить tmux
        read -P "Запустить tmux? [Y/n] " -l response
        if test "$response" = 'y' -o "$response" = '' -o "$response" = 'Y'
            set -l sessions (tmux list-sessions -F "#S" 2>/dev/null)
            
            if test -n "$sessions"
                read -P "Загрузить существующую сессию? [Y/n] " -l load_choice
                if test "$load_choice" = 'y' -o "$load_choice" = '' -o "$load_choice" = 'Y'
                    set -l selected_session (tmux list-sessions -F "#S" | fzf --height 40% --reverse)
                    if test -n "$selected_session"
                        tmux attach -t "$selected_session"
                    else
                        read -P "Введите имя новой сессии: " -l new_session
                        tmux new -s "$new_session"
                    end
                else
                    read -P "Введите имя новой сессии: " -l new_session
                    tmux new -s "$new_session"
                end
            else
                read -P "Введите имя для новой сессии: " -l session_name
                tmux new -s "$session_name"
            end
        end

        # Напоминание о горячих клавишах
        echo
        echo "▓▓▓ TMUX Шпаргалка ▓▓▓"
        echo "Ctrl+B → префикс"
        echo "Ctrl+B + c → новое окно"
        echo "Ctrl+B + % → вертикальное разделение"
        echo "Ctrl+B + \" → горизонтальное разделение"
        echo "Ctrl+B + ←↑→↓ → навигация"
        echo "Ctrl+B + d → отсоединиться"
        echo "Ctrl+B + s → список сессий"
        echo "Ctrl+B + [ → режим прокрутки"
    end
end

# Функция для переустановки конфига
function reinstall_tmux_config
    rm -f ~/.config/fish/config.fish
    curl -sL https://raw.githubusercontent.com/devygh/fishtmux/main/config.fish > ~/.config/fish/config.fish
    source ~/.config/fish/config.fish
    echo "Конфиг успешно обновлён!"
end
