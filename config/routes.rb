ActionController::Routing::Routes.draw do |map|

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.resource :session

  map.resources :users, :member => { :home => :get } do |user|
    user.resources :skills, :collection => { :new_from_linked_in => :post, :create_from_linked_in => :post }
  end
  
  map.friends 'users/:user_id/friends', :controller => 'users', :action => 'friends'
  map.invite 'users/:user_id/invite/:id', :controller => 'users', :action => 'invite'#, :conditions => { :method => :post }
  map.accept 'users/:user_id/accept/:id', :controller => 'users', :action => 'accept'#, :conditions => { :method => :put }
  map.reject 'users/:user_id/reject/:id', :controller => 'users', :action => 'reject'#, :conditions => { :method => :put }
  map.revoke 'users/:user_id/revoke/:id', :controller => 'users', :action => 'revoke'#, :conditions => { :method => :put }
  map.unfriend 'users/:user_id/unfriend/:id', :controller => 'users', :action => 'unfriend'#, :conditions => { :method => :delete }

  map.root :controller => 'users', :action => 'home'

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
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
