local  body_modify = require "body_modify"
body_modify.modify()
-- 用于检测资源文件的访问情况
body_modify.count_visited_static_file()