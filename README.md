
# web-memo
このアプリはフィヨルドブートキャンプの「Sinatraを使ってWebアプリケーションの基本を理解する」のプラクティスの課題として作成しました。
# 使い方
プルリクエストの段階ですが現時点でのの使い方です。

任意のディレクトリに`git clone`してください。

`$ git clone https://github.com/nishikawa202112/web-memo.git`

`web-memo`ディレクトリができるのでそのディレクトリに移動します。

プルリクエストを`git fetch`します。
  
- webmemo(db)

  `$ git fetch origin pull/4/head:my-webmemo-db`
  
    新しいブランチが作られます。
    
    ブランチを移動します。
    
  `$ git checkout my-webmemo-db`
  
    データベースを作成します。
    
    `memo_db.txt`ファイルを参照し、データベースとそのテーブルを作成してください。
    

プログラムを起動します。

`bundle exec ruby webmemo.rb`を実行し、

ブラウザで`http://localhost:4567`でアプリを表示してください。


  
  
