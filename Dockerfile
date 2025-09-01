FROM laravel:alpine

RUN "apt install php-8.2 composer"

WORKDIR /backend

COPY . .

CMD ["php", "artisan", "serve",]