if status is-interactive

    if not set -q TMUX
        # Установка зависимостей
        if not type -q fzf
            echo "Устанавливаем fzf..."
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all --key-bindings --completion --no-update-rc
        end

        if not type -q tmux
            echo "Устанавливаем tmux..."
            sudo apt-get install -y tmux 2>/dev/null || brew install tmux 2>/dev/null
        end

        # Настройки tmux (исправляем артефакты)
        set -l TMUX_CONF $HOME/.tmux.conf
        echo "
# Базовые настройки
set -g prefix C-b
set -g detach-on-destroy off
set -g default-terminal 'xterm-256color'
set -g -as terminal-overrides ',xterm*:Tc:sitm@'
set -g focus-events on
set -g mouse on
" > $TMUX_CONF

        # Функция для показа шпаргалки
        function show_tmux_cheatsheet
            echo
            echo "=== TMUX Шпаргалка ==="
            echo "Ctrl+B c    → Новое окно"
            echo "Ctrl+B %    → Вертикальное разделение"
            echo "Ctrl+B \"    → Горизонтальное разделение"
            echo "Ctrl+B ←↑→↓ → Навигация между панелями"
            echo "Ctrl+B d    → Отсоединиться"
            echo "Ctrl+B s    → Список сессий"
            echo "Ctrl+B [    → Режим прокрутки (выход - Q)"
            echo
        end

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
            
            # Показываем шпаргалку после запуска
            # show_tmux_cheatsheet
        end
    end
show_tmux_cheatsheet
end

# Команда для переустановки
function reinstall_tmux_config
    rm -f ~/.config/fish/config.fish
    curl -sL https://github.com/devygh/fishtmux/raw/refs/heads/main/config.fish > ~/.config/fish/config.fish
    source ~/.config/fish/config.fish
    echo "Конфиг обновлён!"
end
