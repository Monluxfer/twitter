defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  alias Twitter.Guardian

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/", TwitterWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterWeb do
  #   pipe_through :api
  # end

  scope "/api", TwitterWeb do
    pipe_through :api

    resources "/users", UsersController, only: [:create]
    post "/follow", UsersController, :follow

    resources "/tweets", TweetsController, only: [:index, :create]
    get "/tweets/:id/replies", TweetsController, :replies
    post "/likes", TweetsController, :likes
    get "/tweets/:id/likes", TweetsController, :rated
    get "/users/:id/follow", TweetsController, :feed
    get "/users/:id/likes", TweetsController, :following_likes
  end

  scope "/api/v1", TwitterWeb do
    pipe_through :api

    post "/sign_up", UsersController, :create
    post "/sign_in", UsersController, :sign_in
  end

  scope "/api/v1", TwitterWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/my_user", UsersController, :show
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TwitterWeb.Telemetry
    end
  end
end
