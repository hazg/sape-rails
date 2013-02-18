# sape-rails

Вывод ссылок сапы в rails приложениях.
Оригинал: http://forum.searchengines.ru/showthread.php?t=237277

Работает в rails 3.2


## Installation

Add this line to your application's Gemfile:

    gem 'sape-rails', :git => 'git://github.com/hazg/sape-rails'

And then execute:

    $ bundle

## Usage
  
Добавляем config/sape.yml, в котором

  user_id: номер в сапе

В шаблоне
  
  <%= sape_links(кол-во ссылок) =>

Последний вызов (или единственный), должен быть

  <%= sape_links() =>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
