defmodule Othello.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Othello.Play.Game

  schema "users" do
    # User's data
    field :name, :string
    field :email, :string

    # Session data
    field :last_session, :utc_datetime
    field :password_hash, :string
    field :pwd_tries, :integer

    #Password data
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    # Relationship between the User(s) and the Game
    has_many :player1s_game, Game, foreign_key: :player1_id
    has_many :player2s_game, Game, foreign_key: :player2_id
    has_many :player1s_opponent, through: [:player2s_game, :player1]
    has_many :player2s_opponent, through: [:player1s_game, :player2]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password,:password_confirmation, :pwd_tries, :last_session])
    |> validate_confirmation(:password)
    |> validate_password(:password)
    |> put_pass_hash()                                    # https://hexdocs.pm/comeonin/Comeonin.Bcrypt.html#add_hash/2
    |> validate_required([:name, :email, :password_hash])
    |> unique_constraint(:email)
  end

 # Attribute:
 # http://www.ccs.neu.edu/home/ntuck/courses/2018/01/cs4550/notes/17-passwords/user.ex
 # Password validation
 # From Comeonin docs
 def validate_password(changeset, field, options \\ []) do
   validate_change(changeset, field, fn _, password ->
     case valid_password?(password) do
       {:ok, _} -> []
       {:error, msg} -> [{field, options[:message] || msg}]
     end
   end)
 end

 def put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
   change(changeset, Comeonin.Argon2.add_hash(password))
 end
 def put_pass_hash(changeset), do: changeset

 def valid_password?(password) when byte_size(password) > 7 do
   {:ok, password}
 end
 def valid_password?(_), do: {:error, "The password is too short"}


end
