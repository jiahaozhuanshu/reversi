{application,othello,
             [{applications,[kernel,stdlib,elixir,logger,runtime_tools,
                             gettext,argon2_elixir,comeonin,phoenix_pubsub,
                             cowboy,phoenix_html,phoenix,postgrex,
                             phoenix_ecto]},
              {description,"othello"},
              {modules,['Elixir.Othello','Elixir.Othello.Application',
                        'Elixir.Othello.Game','Elixir.Othello.GameBackUp',
                        'Elixir.OthelloWeb','Elixir.OthelloWeb.Endpoint',
                        'Elixir.OthelloWeb.ErrorHelpers',
                        'Elixir.OthelloWeb.ErrorView',
                        'Elixir.OthelloWeb.GamesChannel',
                        'Elixir.OthelloWeb.Gettext',
                        'Elixir.OthelloWeb.LayoutView',
                        'Elixir.OthelloWeb.PageController',
                        'Elixir.OthelloWeb.PageView',
                        'Elixir.OthelloWeb.Router',
                        'Elixir.OthelloWeb.Router.Helpers',
                        'Elixir.OthelloWeb.UserSocket']},
              {registered,[]},
              {vsn,"0.0.1"},
              {mod,{'Elixir.Othello.Application',[]}}]}.
