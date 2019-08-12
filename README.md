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

## Cоздаем контроллеры
## Tokens – API keys
$ rails g migration add_api_key_to_users api_key:index
$ rails g migration add_admin_to_users admin:boolean

### в модель User добавляем before_create :generate_api_key
### в ApplicationController добавляем include ActionController::HttpAuthentication::Token::ControllerMethods  и методы взаимодействия
## добавляем токен всем юзерам в rails console
```ruby
User.all.each { |u| u.send(:generate_api_key); u.save }
```
### в ApplicationController добавляем before_action :authenticate_admin
### в консоли
```
User.where(api_key: "rvUIU0lMU35eSh0laX7G6TKWE4wanY/t27NEfjpf").update(admin: true)
```
$ curl -X GET -H "Authorization: Token token=rvUIU0lMU35eSh0laX7G6TKWE4wanY/t27NEfjpf" http://localhost:3000/books/3

## gem 'rack-attack'
### Add it to the application.rb: config.middleware.use Rack::Attack
$ touch config/initializers/rack_attack.rb
## pundit
### gem 'pundit', '~> 2.0', '>= 2.0.1'
$ bundle install
$ rails g pundit:install
###Let’s add more filters and method to the ApplicationController
```ruby
class ApplicationController < ActionController::API
  include Pundit
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  
  before_action :authenticate_admin
  
  ...
    
  def current_user
    @user ||= admin_user
  end
  
  def admin_user
    return unless @admin && params[:user_id]

    User.find_by(id: params[:user_id])
  end
  
  def pundit_user
    Contexts::UserContext.new(current_user, current_admin)
  end

  def authenticate
    authenticate_admin_with_token || authenticate_user_with_token || render_unauthorized_request
  end
  
  ...
    
  def current_user_presence
    unless current_user
      render json: { error: 'Missing a user' }, status: 422
    end
  end
  
  ...
    
  def not_authorized
    render json: { error: 'Unauthorized' }, status: 403
  end
end
```
## Let’s first add the UserContext class (to app/policies/contexts/user_context.rb):
## редактируем ApplicationPolicy
## When we’re done with the main policy, let’s add a book copy policy (under app/policies).
## We’re missing the borrow and the return_book methods. Let’s add them to the BookCopiesController:
```ruby
module V1
  class BookCopiesController < ApplicationController
    skip_before_action :authenticate_admin, only: [:return_book, :borrow]
    before_action :authenticate, only: [:return_book, :borrow]
    before_action :current_user_presence, only: [:return_book, :borrow]
    before_action :set_book_copy, only: [:show, :destroy, :update, :borrow, :return_book]
    
    ...
    
    def borrow
      if @book_copy.borrow(current_user)
        render json: @book_copy, adapter: :json, status: 200
      else
        render json: { error: 'Cannot borrow this book.' }, status: 422
      end
    end

    def return_book
      authorize(@book_copy)

      if @book_copy.return_book(current_user)
        render json: @book_copy, adapter: :json, status: 200
      else
        render json: { error: 'Cannot return this book.' }, status: 422
      end
    end
    
    ...
  end
end
```
## Now, we need to update the BookCopy class – add the borrow and the return_book methods:
```ruby

```
## And one more thing, routes! We need to update our router:
```ruby
resources :book_copies, only: [:index, :create, :update, :destroy, :show] do
  member do
    put :borrow
    put :return_book
  end
end
```
-
-
# Rspec

-  gem 'rspec-rails'
-  gem 'shoulda-matchers'
-  gem 'factory_bot_rails'
$ rails generate rspec:install
### rails_helper.rb
```
config.include FactoryBot::Syntax::Methods
```
```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end
```
### Also we need to enable pundit test methods. Add pundit to rails_helper.rb (top of the file): require 'pundit/rspec'
### Create a folder called factories under specs and add the first factory – admin and all models.
## Model Spec
### Create an author_spec.rb file under the specs/models: and other models
### Create all controller specs
### Create spec/policies/book_copy_policy_spec.rb
