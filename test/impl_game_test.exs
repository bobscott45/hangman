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
      { game, _tally } = Game.make_move(test_game, "a")
      assert game == test_game
    end
  end

  test "duplicate guess sets game_state to :already_used" do
    game = Game.new_game("dissolve")
    {game, _} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    {game, _} = Game.make_move(game, "y")
    assert game.game_state != :already_used
    {game, _} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "moves recorded" do
    game = Game.new_game("dissolve")
    {game, _} = Game.make_move(game, "x")
    assert game.used == MapSet.new(["x"])
    {game, _} = Game.make_move(game, "y")
    assert game.used == MapSet.new(["x", "y"])
    {game, _} = Game.make_move(game, "z")
    assert game.used == MapSet.new(["x", "y", "z"])
  end



  test "good move" do
    test_game = Game.new_game("wombat")
    test_guess = "b"
    {game, _tally} = Game.make_move(test_game, test_guess)

    assert game.game_state == :good_guess
    assert MapSet.member?(game.used, test_guess)
  end

  test "bad guess" do
    test_game = Game.new_game("wombat")
    test_guess = "z"
    {game, _tally} = Game.make_move(test_game, test_guess)

    assert game.game_state == :bad_guess
    assert game.turns_left == test_game.turns_left - 1
    assert MapSet.member?(game.used, test_guess)
  end

  test "good guess" do
    test_game = Game.new_game("wombat")
    test_guess = "b"
    {game, _tally} = Game.make_move(test_game, test_guess)

    assert game.game_state == :good_guess
    assert game.turns_left == test_game.turns_left
    assert MapSet.member?(game.used, test_guess)
  end


  test "can handle a sequence of moves to win" do
  [
    ["a", :bad_guess,    6,  ["_", "_", "_", "_", "_"],  ["a"] ],
    ["a", :already_used, 6,  ["_", "_", "_", "_", "_"],  ["a"] ],
    ["e", :good_guess,   6,  ["_", "e", "_", "_", "_"],  ["a", "e"] ],
    ["x", :bad_guess,    5,  ["_", "e", "_", "_", "_"],  ["a", "e", "x"] ],
    ["o", :good_guess,   5,  ["_", "e", "_", "_", "o"],  ["a", "e", "o", "x"] ],
    ["y", :bad_guess,    4,  ["_", "e", "_", "_", "o"],  ["a", "e", "o", "x", "y"] ],
    ["l", :good_guess,   4,  ["_", "e", "l", "l", "o"],  ["a", "e", "l", "o", "x", "y"] ],
    ["h", :won       ,   4,  ["h", "e", "l", "l", "o"],  ["a", "e", "h", "l", "o", "x", "y"] ],
  ]
  |> test_sequence_of_moves()
  end

  test "can handle a sequence of moves to lose" do
    [
      ["a", :bad_guess,    6,  ["_", "_", "_", "_", "_"],  ["a"] ],
      ["a", :already_used, 6,  ["_", "_", "_", "_", "_"],  ["a"] ],
      ["e", :good_guess,   6,  ["_", "e", "_", "_", "_"],  ["a", "e"] ],
      ["x", :bad_guess,    5,  ["_", "e", "_", "_", "_"],  ["a", "e", "x"] ],
      ["o", :good_guess,   5,  ["_", "e", "_", "_", "o"],  ["a", "e", "o", "x"] ],
      ["y", :bad_guess,    4,  ["_", "e", "_", "_", "o"],  ["a", "e", "o", "x", "y"] ],
      ["q", :bad_guess,    3,  ["_", "e", "_", "_", "o"],  ["a", "e", "o", "q", "x", "y"] ],
      ["l", :good_guess,   3,  ["_", "e", "l", "l", "o"],  ["a", "e", "l", "o", "q", "x", "y"] ],
      ["r", :bad_guess,    2,  ["_", "e", "l", "l", "o"],  ["a", "e", "l", "o", "q", "r", "x", "y"] ],
      ["s", :bad_guess ,   1,  ["_", "e", "l", "l", "o"],  ["a", "e", "l", "o", "q", "r", "s", "x", "y"] ],
      ["t", :lost      ,   0,  ["_", "e", "l", "l", "o"],  ["a", "e", "l", "o", "q", "r", "s", "t", "x", "y"] ],
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_move/2)
  end

  def check_move([guess,state, turns, letters, used] = _turn, game) do
    {game, tally} = Game.make_move(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.used == used
    assert tally.letters == letters
    game
  end
end