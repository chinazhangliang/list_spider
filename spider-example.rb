require 'list-spider'
require 'delete-unvalid'

def down_dir
  'wangyin/'
end

def parse_index_item(file_name, extra_data, spider)
  content = File.read(file_name)
  doc = Nokogiri::HTML(content)
  list_group = doc.css("ul.list-group")
  link_list = list_group.css("a")

  article_list = []
  link_list.each do |link|
    href = link['href']
    local_path = down_dir + link.content + ".html"
    article_list << TaskStruct.new(href, local_path)
  end
  spider.add_task(article_list)
end

DeleteUnvalid.new("#{down_dir}/*", size_threshold: 300).start

task_list = []
task_list << TaskStruct.new('http://www.yinwang.org/', down_dir+'index.html', parse_method: method(:parse_index_item))

ListSpider.new(task_list).start

DeleteUnvalid.new("#{down_dir}/*", size_threshold: 300).start
