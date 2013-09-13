# sape-rails

Вывод ссылок сапы в rails приложениях.


## Установка

Add this line to your application's Gemfile:

    gem 'sape-rails', :git => 'git://github.com/hazg/sape-rails'

And then execute:

    $ bundle

## Использование
  
Добавляем config/sape.yml, в котором

    user_id: номер в сапе

В шаблоне
  
    <%= sape_links(кол-во ссылок) =>

Последний вызов (или единственный), должен быть

    <%= sape_links() =>

## Опции

config/sape.yml

    user_id: номер в сапе
    host: Хост, где показываем ссылки
    server: Откуда берем ссылки. По умолчанию 'dispencer-01.sape.ru'
    timeout: Время между обновлениями links.db, по умолчанию: 3600

C ошибками - велкам в issues

Оригинал: http://forum.searchengines.ru/showthread.php?t=237277

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
