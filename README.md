# README
* rails new . --api --database=postgresql -T
* add three gems – active_model_serializers, faker and rack-cors

$ rails generate model author first_name last_name
$ rails g model book title author:references
$ rails g model user first_name last_name email
$ rails g model book_copy book:references isbn published:date format:integer user:references

###  following migrations add null:false

```ruby
class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.string :first_name, null: false
      t.string :last_name, index: true, null: false

      t.timestamps
    end
  end
end

class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.references :author, foreign_key: true, null: false
      t.string :title, index: true, null: false

      t.timestamps
    end
  end
end

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: true

      t.timestamps
    end
  end
end

class CreateBookCopies < ActiveRecord::Migration[5.2]
  def change
    create_table :book_copies do |t|
      t.references :book, foreign_key: true, null: false
      t.string :isbn, null: false, index: true
      t.date :published, null: false
      t.integer :format, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
```
$ rake db:migrate
## добавляем в модели отношения и валидации
## Создаем маршруты

```ruby
Rails.application.routes.draw do
  scope module: :v1 do
    resources :authors, only: [:index, :create, :update, :destroy, :show]
    resources :books, only: [:index, :create, :update, :destroy, :show]
    resources :book_copies, only: [:index, :create, :update, :destroy, :show]
    resources :users, only: [:index, :create, :update, :destroy, :show]
  end
end
```

## создаем сериализаторы
$ rails g serializer user
```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :book_copies
end
```

$ rails g serializer book title author book_copies

```ruby
class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author, :book_copies

  def author
    instance_options[:without_serializer] ? object.author : AuthorSerializer.new(object.author, without_serializer: true)
  end
end
```
$ rails g serializer  book_copy
