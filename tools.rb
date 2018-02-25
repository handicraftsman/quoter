def nav_item(label, pg, url)
  c = if pg == @page then 'nav-item active' else 'nav-item' end
  return "<li class='#{c}'><a class='nav-link' href='#{url}'>#{label}</a></li>"
end