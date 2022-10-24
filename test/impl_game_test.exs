defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new_game returns game struct" do
    game = Game.new_game
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new_game(word) returns game struct with letters populated" do
    game = Game.new_game("test")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["t", "e", "s", "t"]
  end

  test "won or lost game move returns original game" do
    for state <- [:won, :lost] do
      test_game = Game.new_game("wombat")
      |> Map.put(:game_state, state)
      { game, _tally } = Game.make_move(test_game, "")
      assert game == test_game
    end
  end

  test "already used guess returns game_state :already_used" do
    test_guess = "a"
    test_game = Game.new_game("wombat")
    |> set_used(test_guess)

    {game, _tally } = Game.make_move(test_game, test_guess)
    assert game.game_state == :already_used
    assert game.turns_left == test_game.turns_left
    assert game.used == test_game.used
  end

  test "good move" do
    test_game = Game.new_game("wombat")
    test_guess = "b"
    {game, _tally} = Game.make_move(test_game, test_guess)

    assert game.game_state == :good_move
    assert game.turns_left == test_game.turns_left - 1
    assert MapSet.member?(game.used, test_guess)
  end

  test "bad move" do
    test_game = Game.new_game("wombat")
    test_guess = "z"
    {game, _tally} = Game.make_move(test_game, test_guess)

    assert game.game_state == :bad_move
    assert game.turns_left == test_game.turns_left - 1
    assert MapSet.member?(game.used, test_guess)
  end

  defp set_used(game, letter) do
    Map.put(game, :used, MapSet.put(game.used, letter))
  end
end