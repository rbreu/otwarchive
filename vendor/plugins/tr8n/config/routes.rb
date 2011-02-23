ActionController::Routing::Routes.draw do |map|
  [:dashboard, :language_cases, 
   :language, :phrases, :translations, :translator, :login].each do |ctrl|   
    map.connect "tr8n/#{ctrl}/:action", :controller => "tr8n/#{ctrl}"
  end

  [:language, :translation, :translation_key, :translator, :domain].each do |ctrl|   
    map.connect "tr8n/admin/#{ctrl}/:action", :controller => "tr8n/admin/#{ctrl}"
  end
  
end
