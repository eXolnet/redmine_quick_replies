# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope 'my' do
  match 'replies/preview', :to => 'replies#preview', :as => 'preview_reply', :via => [:get, :post, :put, :patch]
  resources :replies, controller: 'replies'
end