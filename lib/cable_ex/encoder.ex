# References: 
#
# https://github.com/folz/bento/blob/master/lib/bento/encoder.ex
# https://github.com/alehander92/wire/blob/master/lib/wire/encoder.ex

defmodule Cable.Encode do
end

defprotocol Cable.Encoder do
  def encode(value)
end

alias Cable.Post

defimpl Cable.Encoder, for: Post do
  @text_post_type 0

  defp encode_links(%Post{} = post) do
    Varint.LEB128.encode(length(post.links)) <> Enum.join(post.links)
  end

  defp encode_timestamp(%Post{} = post), do: Varint.LEB128.encode(post.timestamp)
  defp encode_post_type(%Post{} = post), do: Varint.LEB128.encode(post.post_type)

  defp encode_header(%Post{} = post) do
    post.public_key <>
      <<0::512>> <>
      encode_links(post) <> encode_post_type(post) <> encode_timestamp(post)
  end

  defp encode_channel(%Post{post_type: @text_post_type} = post) do
    Varint.LEB128.encode(byte_size(post.channel)) <> post.channel
  end

  defp encode_text(%Post{post_type: @text_post_type} = post) do
    Varint.LEB128.encode(byte_size(post.text)) <> post.text
  end

  defp encode_text_post(%Post{post_type: @text_post_type} = post) do
    encode_header(post) <> encode_channel(post) <> encode_text(post)
  end

  def encode(post) do
    case post.post_type do
      0 -> encode_text_post(post)
    end
  end
end
