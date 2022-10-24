defmodule Hangman do
  @moduledoc """
  Documentation for `Hangman`.
  """

  alias Hangman.Impl.Game
  alias Hangman.Type

  @opaque game :: Game.t
  @spec new_game() :: game
  defdelegate new_game, to: Game

  @spec make_move(Game.t, String.t) :: { Game.t, Type.tally }
  defdelegate make_move(game, guess), to: Game

end
