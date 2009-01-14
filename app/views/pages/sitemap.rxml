xml.instruct! :xml, :version=>"1.0"
xml.pages do
	@pages.each do |page|
		xml.page( :name => page.name.to_s, :id => page.id, :rel => page_url( page, :only_path => false ) )
	end
end