
ActionController::Routing::Routes.draw do |map|
  
  # app root
  map.root :controller => 'content'
  
  # account
  map.login 'login', :controller => 'account', :action => 'login'
  map.logout 'logout', :controller => 'account', :action => 'logout'
  map.signup 'signup', :controller => 'account', :action => 'signup'
  map.signup_with_invite 'signup/:invite_code', :controller => 'account', :action => 'signup'
  map.password_recovery 'password_recovery', :controller => 'account', :action => 'password_recovery'
  map.change_password 'change_password/:recovery_code', :controller => 'account', :action => 'change_password'
  
  # content
  map.with_options :controller => 'content' do |content|
    content.help 'help', :action => 'help' 
    content.staff 'staff', :action => 'staff'
  end

  # user
  map.bookmarks 'bookmarks', :controller => 'users', :action => 'bookmarks'
  map.uploads 'uploads', :controller => 'users', :action => 'uploads'
  map.stuck 'stuck', :controller => 'users', :action => 'stuck'
  map.messages 'messages', :controller => 'messages', :action => 'folder'

  # torrents
  map.torrents 'torrents/:action/:id', :controller => 'torrents'
  map.comments 'torrents/:torrent_id/comments/:action/:id', :controller => 'comments'
  map.upload 'upload', :controller => 'torrents', :action => 'upload'

  # forums
  map.forums 'forums/:action/:id', :controller => 'forums'
  map.topics 'forums/:forum_id/topics/:action/:id', :controller => 'topics'
  map.posts 'forums/:forum_id/posts/:action/:id', :controller => 'posts'

  # tracker (also used to generate the tracker announce urls)
  map.tracker 'tracker/:passkey/:action', :controller => 'tracker'
  
  # default
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
