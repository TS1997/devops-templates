{ ... }:
{
  scripts.laravel-init.exec = ''
    process-compose list &> /dev/null

    if [[ $? != 0 ]]; then
        echo "Start devenv first"
        exit 1
    fi

    laravel new laraveltemplate --react --pest --npm --force --no-interaction
    rm laraveltemplate/.env
    rm laraveltemplate/.env.example
    cat laraveltemplate/.gitignore >> .gitignore
    rm laraveltemplate/.gitignore
    rsync -rl laraveltemplate/ .
    rm -r laraveltemplate
    cp .env.example .env
    php artisan key:generate
    php artisan migrate:refresh --seed
    sh init-message.sh
  '';
}
