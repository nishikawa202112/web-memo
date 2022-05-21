# frozen_string_literal: true

require 'sinatra'
require 'pg'

class MemoFile
  def read_db
    conn = PG.connect(dbname: 'memo_db')
    conn.exec('SELECT * FROM Memo_table ORDER BY memo_id') do |result|
      @memo_list =
        result.map do |row|
          row_data = {}
          row_data[:memo_id] = row['memo_id']
          row_data[:title] = row['title']
          row_data[:memo] = row['memo']
          row_data
        end
    end
  end

  def find_data(memo_id)
    @memo_list.each do |row|
      if row[:memo_id] == memo_id
        @title = row[:title]
        @memo = row[:memo]
      end
    end
    [@title, @memo]
  end

  def write_db(title, memo)
    memo_id =
      if @memo_list == []
        '001'
      else
        (@memo_list.map { |row| row[:memo_id].to_i }.max + 1).to_s.rjust(3, '0')
      end
    conn = PG.connect(dbname: 'memo_db')
    conn.exec("PREPARE memoplan (text,text) AS INSERT INTO Memo_table (memo_id, title, memo) VALUES('#{memo_id}',$1,$2)")
    conn.exec("EXECUTE memoplan ('#{title}','#{memo}')")
    @memo_list << { memo_id: memo_id, title: title, memo: memo }
  end

  def update_db(memo_id, title, memo)
    conn = PG.connect(dbname: 'memo_db')
    conn.exec("PREPARE memoplan (text,text) AS UPDATE Memo_table SET title = $1, memo = $2 WHERE memo_id = '#{memo_id}'")
    conn.exec("EXECUTE memoplan ('#{title}','#{memo}')")
    @memo_list.map do |row|
      if row[:memo_id] == memo_id
        row[:title] = title
        row[:memo] = memo
      end
    end
  end

  def delete_db(memo_id)
    conn = PG.connect(dbname: 'memo_db')
    conn.exec("DELETE FROM Memo_table WHERE memo_id = '#{memo_id}'")
    @memo_list.delete_if { |row| row[:memo_id] == memo_id }
  end

  def read_memo_list
    @memo_list
  end
end

memofile = MemoFile.new
memofile.read_db

get '/' do
  @memo_file = memofile.read_memo_list
  erb :index
end

get '/newmemo' do
  erb :newmemo
end

post '/new' do
  title = params[:title]
  memo = params[:memo]
  memofile.write_db(title, memo)
  redirect '/'
end

get '/showmemo/:memoid' do
  @select_id = params[:memoid].rjust(3, '0')
  @select_title, @select_memo = memofile.find_data(@select_id)
  erb :showmemo
end

get '/showmemo/:memoid/edit' do
  @select_id = params[:memoid].rjust(3, '0')
  @select_title, @select_memo = memofile.find_data(@select_id)
  erb :editmemo
end

patch '/edit/:memoid' do
  select_id = params[:memoid].rjust(3, '0')
  title = params[:title]
  memo = params[:memo]
  memofile.update_db(select_id, title, memo)
  redirect '/'
end

delete '/deletememo/:memoid' do
  select_id = params[:memoid].rjust(3, '0')
  memofile.delete_db(select_id)
  redirect '/'
end
