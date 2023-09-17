defmodule Cable.Encode do
end

defprotocol Cable.Encoder do
  def encode(data)
  def encode(data, secret_key)
end

alias Cable.Post

defimpl Cable.Encoder, for: Post do
  @text_post 0
  @delete_post 1

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

  defp encode_channel(%Post{post_type: @text_post} = post) do
    Varint.LEB128.encode(byte_size(post.channel)) <> post.channel
  end

  defp encode_text(%Post{post_type: @text_post} = post) do
    Varint.LEB128.encode(byte_size(post.text)) <> post.text
  end

  defp encode_hashes(%Post{post_type: @delete_post} = post) do
    Varint.LEB128.encode(length(post.hashes)) <> Enum.join(post.hashes)
  end

  defp encode_text_post(%Post{post_type: @text_post} = post) do
    encode_header(post) <> encode_channel(post) <> encode_text(post)
  end

  defp encode_delete_post(%Post{post_type: @delete_post} = post) do
    encode_header(post) <> encode_hashes(post)
  end

  defp encode_and_sign(%Post{} = post, secret_key) do
    encoded_post = encode(post)
    Post.sign_post(encoded_post, secret_key)
  end

  def encode(%Post{} = post, nil) do
    encode(post)
  end

  def encode(%Post{} = post, secret_key) do
    encode_and_sign(post, secret_key)
  end

  def encode(%Post{} = post) do
    case post.post_type do
      0 -> encode_text_post(post)
      1 -> encode_delete_post(post)
    end
  end
end
