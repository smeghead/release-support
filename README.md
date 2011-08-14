# release suport #

help to release notify process.


## sample configuration file. ##

   - ~/etc/release-support.conf

   [starbug1]
   productname = 'Starbug1'
   title = 'Starbug1 {VERSION} リリースのお知らせ'
   template_prefix = "Starbug1は、軽量、高速なバグトラッキングシステム(BTS: Bug Tarcking System)です。\\nC で書かれているため少ないリソースのサーバ(例えば10年前のパソコンなど)に設置した場合でも快適に動作します。\\n\\n  * 公式サイト http://starbug1.com/\\n  * ダウンロードは、Sourceforge.jp http://sourceforge.jp/projects/starbug1/ から\\n\\nStarbug1 {VERSION} をリリースしました。主な変更内容は以下です。\\n"
   template_suffix = ""
   change_log = '/home/smeghead/work/starbug1/ChangeLog'
   urls = 'http://sourceforge.jp/frs/admin/index.php?group_id=3135', 'http://groups.google.com/group/starbug1-users', 'http://blog.starbug1.com/wp-admin/index.php'
   
   [wordpress]
   url = 'http://blog.starbug1.com/xmlrpc.php'
   loginid = 'username'
   password = 'passwd'


