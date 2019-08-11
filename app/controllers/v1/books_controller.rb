module V1
  class BooksController < ApplicationController
    before_action :set_book, only: [:show, :destroy, :update]

    def index
      books = Book.preload(:author, :book_copies).page(params[:page]).per(5)
      render json: books, adapter: :json
    end

    def show
      render json: @book, adapter: :json
    end

    def create
      book = Book.new(book_params)
      if book.save
        render json: book, adapter: :json, status: 201
      else
        render json: { error: book.errors }, status: 422
      end
    end

    def update
      if @book.update(book_params)
        render json: @book, adapter: :json, status: 200
      else
        render json: { error: @book.errors }, status: 422
      end
    end

    def destroy
      @book.destroy
      head 204
    end

    private

    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.require(:book).permit(:title, :author_id)
    end

    def borrow(borrower)
      return false if user.present?

      self.user = borrower
        save
    end

    def return_book(borrower)
      return false unless user.present?

      self.user = nil
      save
    end
  end
end
