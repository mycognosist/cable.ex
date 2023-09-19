defmodule Cable do
  alias Cable.{Encoder, Decoder}

  def encode(data), do: Encoder.encode(data)
  def encode(data, secret_key), do: Encoder.encode(data, secret_key)

  def decode_post(data), do: Decoder.Post.decode(data)
  def decode_msg(data), do: Decoder.Message.decode(data)
end
