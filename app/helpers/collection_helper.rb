module CollectionHelper

  def tab_class(this_tab, selected_tab)
    this_tab == selected_tab ? 'current-tab' : ''
  end

end
