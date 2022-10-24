defmodule Hangman.Impl.Game do

  alias  Hangman.Type

  @valid_moves ?a .. ?z
               |> Enum.to_list
               |> List.to_string
               |> String.codepoints

  @type t :: %__MODULE__{
    turns_left: integer,
    game_state: Type.state,
    letters: list(String.t),
    used: MapSet.t(String.t)
  }

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game :: t
  def new_game do
    new_game(Dictionary.random_word)
  end

  @spec new_game(String.t) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints
    }
  end

  @spec make_move(t, String.t) :: { t, Type.tally }

  def make_move(game, guess) when guess not in @valid_moves do
    %{game | game_state: :invalid_guess}
  end

  def make_move(game = %{game_state: state}, _) when state in [:won, :lost ] do
    game
    |> to_game_tally_tuple
  end


  def make_move( game, guess)  do
    accept_guess( game, guess, MapSet.member?(game.used, guess))
    |> to_game_tally_tuple
  end

  defp is_lowercase({:ok, guess}) do
    case String.downcase(guess) == guess do
      true -> { :ok, guess }
      _ -> { :error, guess }
    end
  end
  defp is_lowercase({_, guess}), do: { :error, guess}

  defp accept_guess( game, _guess, true = _already_used) do
    %{ game | game_state: :already_used }
  end

  defp accept_guess( game, guess, _already_used) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess( game, true = _good_guess) do
    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: new_state }
  end

  defp score_guess(game = %{ turns_left: 1 }, _) do
    %{ game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _) do
    %{ game | game_state: :bad_guess, turns_left: game.turns_left - 1 }
  end

  defp maybe_won( true = _has_won), do: :won
  defp maybe_won(_), do: :good_guess

  defp to_game_tally_tuple(game) do
    {game, tally(game)}
  end

  defp tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list |> Enum.sort
    }
  end

  defp reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter -> MapSet.member?(game.used, letter) |> maybe_reveal(letter) end)
  end

  defp maybe_reveal(true, letter), do: letter
  defp maybe_reveal(_,_), do: "_"

end