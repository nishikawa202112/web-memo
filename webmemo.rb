# frozen_string_literal: true

require 'sinatra'
require 'csv'
require 'cgi/util'

class MemoFile
  MEMO_FILE = 'memo_file.csv'
  def self.read
    memo_file = CSV.read(MEMO_FILE)
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
    CSV.open(MEMO_FILE, 'a') do |file|
      file << [title, memo]
    end
  end

  def self.edit(id, title, memo)
    memo_list = read
    CSV.open(MEMO_FILE, 'w') do |file|
      memo_list.each do |data|
        if data[:id] == id
          data[:title] = title
          data[:memo] = memo
        end
        file << [data[:title], data[:memo]]
      end
    end
  end

  def self.delete(id)
    memo_list = read
    memo_list.delete_if { |memo| memo[:id] == id }
    CSV.open(MEMO_FILE, 'w') do |file|
      memo_list.each do |memo|
        file << [memo[:title], memo[:memo]]
      end
    end
  end

  def self.find(id)
    memo_list = read
    memo_list.each do |memo|
      return memo if memo[:id] == id
    end
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
  @memo = {}
  @memo[:id] = params[:memo_id]
  @memo = MemoFile.find(@memo[:id].to_i)
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  @memo = {}
  @memo[:id] = params[:memo_id]
  @memo = MemoFile.find(@memo[:id].to_i)
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
