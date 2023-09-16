defmodule Cable do
  alias Cable.{Encoder, Decoder}

  def encode(data), do: Encoder.encode(data)
  def encode(data, secret_key), do: Encoder.encode(data, secret_key)

  def decode(data), do: Decoder.decode(data)
end
