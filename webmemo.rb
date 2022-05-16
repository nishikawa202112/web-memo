# frozen_string_literal: true

require 'sinatra'
enable :method_override

class MemoFile
  def read_file
    if File.readable?('./public/memofile.txt')
      File.open('./public/memofile.txt', 'r') do |f|
        @memo_file = f.read.split('title=').map { |line| line.split('memo=') }
      end
      @memo_file.shift
      @memo_file.map.with_index(0) do |line, index|
        line.unshift(index.to_s)
      end
    end
    @memo_file
  end

  def write_file(title, memo)
    File.open('./public/memofile.txt', 'a') do |f|
      f.write("title=#{title}memo=#{memo}")
    end
  end

  def edit_file(memo_file)
    memodata = +''
    memo_file.each do |line|
      memodata << +"title=#{line[1]}memo=#{line[2]}"
    end
    File.open('./public/memofile.txt', 'w') do |f|
      f.write(memodata)
    end
  end

  def delete_file(select_id)
    memodata = +''
    @memo_file.each do |line|
      memodata << +"title=#{line[1]}memo=#{line[2]}" unless line[0] == select_id
    end
    File.open('./public/memofile.txt', 'w') do |f|
      f.write(memodata)
    end
  end
end

memofile = MemoFile.new

get '/' do
  @memo_file = memofile.read_file
  erb :index
end

get '/newmemo' do
  erb :newmemo
end

post '/new' do
  title = params[:title]
  memo = params[:memo]
  memofile.write_file(title, memo)
  redirect '/'
end

get '/showmemo/:memoid' do
  @select_id = params[:memoid]
  @memo_file = memofile.read_file
  @select_title = @memo_file[@select_id.to_i][1]
  @select_memo = @memo_file[@select_id.to_i][2]
  erb :showmemo
end

get '/showmemo/:memoid/edit' do
  @select_id = params[:memoid]
  @memo_file = memofile.read_file
  @select_title = @memo_file[@select_id.to_i][1]
  @select_memo = @memo_file[@select_id.to_i][2]
  erb :editmemo
end

patch '/edit/:memoid' do
  select_id = params[:memoid]
  title = params[:title]
  memo = params[:memo]
  memo_file = memofile.read_file
  memo_file[select_id.to_i][1] = title
  memo_file[select_id.to_i][2] = memo
  memofile.edit_file(memo_file)
  redirect '/'
end

delete '/deletememo/:memoid' do
  select_id = params[:memoid]
  memofile.delete_file(select_id)
  redirect '/'
end
