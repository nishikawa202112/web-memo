# frozen_string_literal: true

require 'sinatra'
require 'pg'
require 'cgi/util'

class MemoDb
  MEMO_DB = 'memo_db'
  def self.read
    conn = PG.connect(dbname: MEMO_DB)
    memo_list = []
    conn.exec('SELECT * FROM Memo_table ORDER BY id') do |result|
      result.each do |row|
        row_data = {}
        row_data[:id] = row['id']
        row_data[:title] = row['title']
        row_data[:memo] = row['memo']
        memo_list << row_data
      end
    end
    memo_list
  end

  def self.write(title, memo)
    conn = PG.connect(dbname: MEMO_DB)
    conn.exec('PREPARE memoplan (text,text) AS INSERT INTO Memo_table (title, memo) VALUES($1,$2)')
    conn.exec("EXECUTE memoplan ('#{title}','#{memo}')")
  end

  def self.edit(id, title, memo)
    conn = PG.connect(dbname: MEMO_DB)
    conn.exec("PREPARE memoplan (text,text) AS UPDATE Memo_table SET title = $1, memo = $2 WHERE id = '#{id}'")
    conn.exec("EXECUTE memoplan ('#{title}','#{memo}')")
  end

  def self.delete(id)
    conn = PG.connect(dbname: MEMO_DB)
    conn.exec("DELETE FROM Memo_table WHERE id = '#{id}'")
  end

  def self.find(id)
    memo_list = read
    memo_list.each do |memo|
      return memo if memo[:id] == id
    end
  end
end

get '/' do
  @memos = MemoDb.read
  erb :index
end

get '/memos' do
  erb :new_memo
end

post '/memos' do
  title = escape_html(params[:title])
  memo = escape_html(params[:memo]).gsub(/\R/, "\n")
  MemoDb.write(title, memo)
  redirect '/'
end

get '/memos/:memo_id' do
  @memo = MemoDb.find(params[:memo_id])
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  @memo = MemoDb.find(params[:memo_id])
  erb :edit_memo
end

patch '/memos/:memo_id' do
  title = escape_html(params[:title])
  memo = escape_html(params[:memo]).gsub(/\R/, "\n")
  MemoDb.edit(params[:memo_id], title, memo)
  redirect '/'
end

delete '/memos/:memo_id' do
  MemoDb.delete(params[:memo_id])
  redirect '/'
end
