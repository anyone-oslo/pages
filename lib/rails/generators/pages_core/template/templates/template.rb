<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  # name "<%= human_name %>"
<% if view_name == file_name -%>
  # filename "<%= view_name %>"
<% else -%>
  filename "<%= view_name %>"
<% end -%>

  # comments false
  # comments_allowed true
  # files false
  # images false
  # tags false

<% if subtemplate == default_subtemplate -%>
  # subtemplate :<%= subtemplate %>
<% else -%>
  subtemplate :<%= subtemplate %>
<% end -%>
  # enabled_blocks :headline, :excerpt, :body
end
<% end -%>
