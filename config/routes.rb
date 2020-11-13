Panicboat::Engine.routes.draw do
  resources :healthcheck, only: [:index]
end
