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

        # Настройки tmux
        set -l TMUX_CONF $HOME/.tmux.conf
        echo "
# Базовые настройки
set -g prefix C-b
set -g detach-on-destroy off
set -g default-terminal 'screen-256color'
set -g mouse on
" > $TMUX_CONF

        # Функция для показа шпаргалки
        function show_tmux_cheatsheet
            echo
            echo "▓▓▓ TMUX Шпаргалка ▓▓▓"
            echo "Основные команды:"
            echo "Ctrl+B c → Новое окно"
            echo "Ctrl+B % → Вертикальное разделение"
            echo "Ctrl+B \" → Горизонтальное разделение"
            echo "Ctrl+B ←↑→↓ → Навигация между панелями"
            echo "Ctrl+B d → Отсоединиться от сессии"
            echo "Ctrl+B s → Показать список сессий"
            echo "Ctrl+B [ → Режим прокрутки (выход - Q)"
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
                        show_tmux_cheatsheet
                    else
                        read -P "Введите имя новой сессии: " -l new_session
                        tmux new -s "$new_session"
                        show_tmux_cheatsheet
                    end
                else
                    read -P "Введите имя новой сессии: " -l new_session
                    tmux new -s "$new_session"
                    show_tmux_cheatsheet
                end
            else
                read -P "Введите имя для новой сессии: " -l session_name
                tmux new -s "$session_name"
                show_tmux_cheatsheet
            end
        end
    end
end

# Команда для переустановки конфига
function reinstall_tmux_config
    rm -f ~/.config/fish/config.fish
    curl -sL https://raw.githubusercontent.com/yourusername/yourrepo/main/config.fish > ~/.config/fish/config.fish
    source ~/.config/fish/config.fish
    echo "Конфиг успешно обновлён!"
end
