
ActionController::Routing::Routes.draw do |map|
  
  # app root
  map.root :controller => 'content'
  
  # account
  map.login 'login', :controller => 'login', :action => 'login'
  map.logout 'logout', :controller => 'login', :action => 'logout'
  map.signup 'signup', :controller => 'signup'
  map.signup_with_invite 'signup/:invite_code', :controller => 'signup'
  map.password_recovery 'password_recovery', :controller => 'password_recovery'
  map.change_password 'change_password/:recovery_code', :controller => 'password_recovery', :action => 'change_password'
  
  # content
  map.with_options :controller => 'content' do |content|
    content.help 'help', :action => 'help' 
    content.staff 'staff', :action => 'staff'
  end

  # user  
  map.my_bookmarks 'my_bookmarks', :controller => 'users', :action => 'my_bookmarks'
  map.my_uploads 'my_uploads', :controller => 'users', :action => 'my_uploads'
  map.my_wishes 'my_requests', :controller => 'users', :action => 'my_wishes'
  map.stuck 'stuck', :controller => 'users', :action => 'stuck'
  map.users 'users/:action/:id', :controller => 'users'
  
  # messages (in this case :id is being used to define the folder)
  map.messages 'messages/:action/:id', :controller => 'messages'
  
  # torrents  
  map.comments 'torrents/:torrent_id/comments/:action/:id', :controller => 'comments'
  map.upload 'upload', :controller => 'torrents', :action => 'upload'
  map.rewards 'torrents/:torrent_id/rewards/:action/:id', :controller => 'rewards'
  map.torrents 'torrents/:action/:id', :controller => 'torrents'

  # wishes (appears as 'requests' for the user)  
  map.wish_comments 'requests/:wish_id/comments/:action/:id', :controller => 'wish_comments'
  map.wish_bounties 'requests/:wish_id/bounties/:action/:id', :controller => 'wish_bounties'
  map.wishes 'requests/:action/:id', :controller => 'wishes'

  # forums  
  map.posts 'forums/:forum_id/posts/:action/:id', :controller => 'posts'
  map.topics 'forums/:forum_id/topics/:action/:id', :controller => 'topics'
  map.forums 'forums/:action/:id', :controller => 'forums'

  # logs
  map.logs 'logs', :controller => 'logs'

  # stats
  map.stats 'stats', :controller => 'stats'

  # tracker
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
