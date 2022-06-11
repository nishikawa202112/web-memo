# frozen_string_literal: true

require 'sinatra'
require 'pg'
require 'cgi/util'

class MemoDb
  MEMO_DB = 'memo_db'

  def initialize
    @conn = PG.connect(dbname: MEMO_DB)
  end

  def read
    memo_list = []
    @conn.exec('SELECT * FROM Memo_table ORDER BY id') do |result|
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

  def write(title, memo)
    @conn.prepare('memoplan', 'INSERT INTO Memo_table (title, memo) VALUES($1,$2)')
    @conn.exec_prepared('memoplan', [title, memo])
    @conn.exec('DEALLOCATE memoplan')
  end

  def edit(id, title, memo)
    @conn.prepare('memoplan', 'UPDATE Memo_table SET title = $2, memo = $3 WHERE id = $1')
    @conn.exec_prepared('memoplan', [id, title, memo])
    @conn.exec('DEALLOCATE memoplan')
  end

  def delete(id)
    @conn.prepare('memoplan', 'DELETE FROM Memo_table WHERE id = $1')
    @conn.exec_prepared('memoplan', [id])
    @conn.exec('DEALLOCATE memoplan')
  end

  def find(id)
    memo_list = read
    memo_list.each do |memo|
      return memo if memo[:id] == id
    end
  end
end

memofile = MemoDb.new

get '/' do
  @memos = memofile.read
  erb :index
end

get '/memos' do
  erb :new_memo
end

post '/memos' do
  title = params[:title]
  memo = params[:memo].gsub(/\R/, "\n")
  memofile.write(title, memo)
  redirect '/'
end

get '/memos/:memo_id' do
  @memo = memofile.find(params[:memo_id])
  erb :show_memo
end

get '/memos/:memo_id/edit' do
  @memo = memofile.find(params[:memo_id])
  erb :edit_memo
end

patch '/memos/:memo_id' do
  title = params[:title]
  memo = params[:memo].gsub(/\R/, "\n")
  memofile.edit(params[:memo_id], title, memo)
  redirect '/'
end

delete '/memos/:memo_id' do
  memofile.delete(params[:memo_id])
  redirect '/'
end
