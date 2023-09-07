# https://elixir-lang.org/getting-started

defmodule Cable do
  @moduledoc """
  Documentation for `Cable`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Cable.hello()
      :world

  """
  def hello do
    :world
  end
  
  defmodule Post do
  @enforce_keys [:header, :body]
    defstruct [:header, :body]

    defmodule Header do
      @enforce_keys [:public_key, :signature, :links, :post_type, :timestamp]
      defstruct [:public_key, :signature, :links, :post_type, :timestamp]
    end

    defmodule Body do
    end
  end

  defmodule Message do
    defmodule Header do
    end

    defmodule Body do
    end
  end
end
