# frozen_string_literal: true

require 'sinatra'
require 'csv'
require 'cgi/util'

class MemoFile
  def self.read
    memo_file = CSV.read('memofile.csv')
    memo_list = []
    memo_file.each.with_index do |memo, index|
      memo_data = {}
      memo_data[:id] = index
      memo_data[:title] = memo[0]
      memo_data[:memo] = memo[1]
      memo_list << memo_data
    end
    memo_list
  end

  def self.write(title, memo)
    CSV.open('memofile.csv', 'a') do |file|
      file << [title, memo]
    end
  end

  def self.edit(edit_id, edit_title, edit_memo)
    memo_list = read
    CSV.open('memofile.csv', 'w') do |file|
      memo_list.each do |memo|
        if memo[:id] == edit_id
          memo[:title] = edit_title
          memo[:memo] = edit_memo
        end
        file << [memo[:title], memo[:memo]]
      end
    end
  end

  def self.delete(delete_id)
    memo_list = read
    memo_list.delete_if { |memo| memo[:id] == delete_id }
    CSV.open('memofile.csv', 'w') do |file|
      memo_list.each do |memo|
        file << [memo[:title], memo[:memo]]
      end
    end
  end

  def self.find_data(find_id)
    memo_list = read
    memo_list.each do |memo|
      if memo[:id] == find_id
        @find_title = memo[:title]
        @find_memo = memo[:memo]
      end
    end
    [@find_title, @find_memo]
  end
end

get '/' do
  @memos = MemoFile.read
  erb :index
end

get '/memos' do
  erb :new_memo
end

post '/memos' do
  title = escape_html(params[:title])
  memo = escape_html(params[:memo]).gsub(/\R/, "\n")
  MemoFile.write(title, memo)
  redirect '/'
end

get '/memos/:memo_id' do
  @id = params[:memo_id]
  @title, @memo = MemoFile.find_data(@id.to_i)
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  @id = params[:memo_id]
  @title, @memo = MemoFile.find_data(@id.to_i)
  erb :edit_memo
end

patch '/memos/:memo_id' do
  id = params[:memo_id]
  title = escape_html(params[:title])
  memo = escape_html(params[:memo]).gsub(/\R/, "\n")
  MemoFile.edit(id.to_i, title, memo)
  redirect '/'
end

delete '/memos/:memo_id' do
  id = params[:memo_id]
  MemoFile.delete(id.to_i)
  redirect '/'
end
