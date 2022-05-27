# frozen_string_literal: true

require 'sinatra'
require 'csv'
require 'cgi/util'

class MemoFile
  def read_file
    @memo_file = CSV.read('memofile.csv')
    p @memo_file
    @memo_file.map.with_index(0) do |line, index|
      line.unshift(index.to_s)
    end
    p @memo_file
  end

  def write_file(title, memo)
    CSV.open('memofile.csv', 'a') do |file|
      file << [title, memo]
    end
  end

  def edit_file(edit_memo_file)
    CSV.open('memofile.csv', 'w') do |file|
      edit_memo_file.each do |line|
        file << [line[1], line[2]]
      end
    end
  end

  def delete_file(select_id)
    @memo_file.delete_if { |array| array[0] == select_id }
    CSV.open('memofile.csv', 'w') do |file|
      @memo_file.each do |array|
        file << [array[1], array[2]]
      end
    end
  end
end

memo_file = MemoFile.new

get '/' do
  @memo_file = memo_file.read_file
  erb :index
end

get '/memos' do
  erb :newmemo
end

post '/memos' do
  title = escape_html(params[:title])
  memo = escape_html(params[:memo]).gsub(/\R/, "\n")
  memo_file.write_file(title, memo)
  redirect '/'
end

get '/memos/:memo_id' do
  @select_id = params[:memo_id]
  @memo_file = memo_file.read_file
  @select_title = @memo_file[@select_id.to_i][1]
  @select_memo = @memo_file[@select_id.to_i][2]
  erb :showmemo
end

get '/memos/:memo_id/edit' do
  @select_id = params[:memo_id]
  @memo_file = memo_file.read_file
  @select_title = @memo_file[@select_id.to_i][1]
  @select_memo = @memo_file[@select_id.to_i][2]
  erb :editmemo
end

patch '/memos/:memo_id' do
  select_id = params[:memo_id]
  title = escape_html(params[:title])
  memo = escape_html(params[:memo]).gsub(/\R/, "\n")
  edit_memo_file = memo_file.read_file
  edit_memo_file[select_id.to_i][1] = title
  edit_memo_file[select_id.to_i][2] = memo
  p edit_memo_file
  memo_file.edit_file(edit_memo_file)
  redirect '/'
end

delete '/memos/:memo_id' do
  select_id = params[:memo_id]
  memo_file.delete_file(select_id)
  redirect '/'
end
