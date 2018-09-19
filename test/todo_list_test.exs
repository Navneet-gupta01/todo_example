defmodule TodoListTest do
  use ExUnit.Case, async: true

  test "empty List" do
    assert Todo.List.size(Todo.List.new()) == 0
  end

  test "entries" do

    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-20], title: "Outing"})

    assert Todo.List.size(todo_list) == 4
    assert todo_list |> Todo.List.entries(~D[2018-12-19]) |> length() == 2
    assert todo_list |> Todo.List.entries(~D[2018-12-20]) |> length() == 2
    assert todo_list |> Todo.List.entries(~D[2018-12-21]) |> length() == 0

    titles = todo_list |> Todo.List.entries(~D[2018-12-19]) |> Enum.map(& &1.title)
    assert ["Dentist", "Movies"] = titles
    titles = todo_list |> Todo.List.entries(~D[2018-12-20]) |> Enum.map(& &1.title)
    assert ["Shopping", "Outing"] = titles
  end

  test "update Entry" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
      |> Todo.List.update_entry(2, &Map.put(&1, :title, "Updated shopping"))

    assert Todo.List.size(todo_list) == 3
    assert todo_list |> Todo.List.entries(~D[2018-12-19]) |> length() == 2
    assert todo_list |> Todo.List.entries(~D[2018-12-20]) |> length() == 1
    assert todo_list |> Todo.List.entries(~D[2018-12-21]) |> length() == 0

    titles = todo_list |> Todo.List.entries(~D[2018-12-19]) |> Enum.map(& &1.title)
    assert ["Dentist", "Movies"] = titles
    titles = todo_list |> Todo.List.entries(~D[2018-12-20]) |> Enum.map(& &1.title)
    assert ["Updated shopping"] = titles
  end

  test "delete Entry" do
    todo_list =
      Todo.List.new()
      |> Todo.List.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
      |> Todo.List.add_entry(%{date: ~D[2018-12-19], title: "Movies"})
      |> Todo.List.delete_entry(2)

    assert Todo.List.size(todo_list) == 2
    assert todo_list |> Todo.List.entries(~D[2018-12-19]) |> length() == 2
    assert todo_list |> Todo.List.entries(~D[2018-12-20]) |> length() == 0
    assert todo_list |> Todo.List.entries(~D[2018-12-21]) |> length() == 0

    titles = todo_list |> Todo.List.entries(~D[2018-12-19]) |> Enum.map(& &1.title)
    assert ["Dentist", "Movies"] = titles
    titles = todo_list |> Todo.List.entries(~D[2018-12-20]) |> Enum.map(& &1.title)
    assert [] = titles
  end
end
