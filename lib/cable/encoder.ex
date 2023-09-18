defmodule Cable.Encode do
  def value(value), do: Varint.LEB128.encode(byte_size(value)) <> value
  def key_value({key, value}), do: value(key) <> value(value)
end

defprotocol Cable.Encoder do
  def encode(data)
  def encode(data, secret_key)
end

alias Cable.{Post, Message, Encode}

defimpl Cable.Encoder, for: Post do
  # TODO: Move these to a Types module.
  @text_post 0
  @delete_post 1
  @info_post 2
  @topic_post 3
  @join_post 4
  @leave_post 5

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

  defp encode_hashes(%Post{post_type: @delete_post} = post) do
    Varint.LEB128.encode(length(post.hashes)) <> Enum.join(post.hashes)
  end

  defp encode_info(%Post{post_type: @info_post} = post) do
    Enum.reduce(post.info, <<>>, fn x, acc -> acc <> Encode.key_value(x) end) <> <<0>>
  end

  defp encode_topic(%Post{post_type: @topic_post} = post) do
    Encode.value(post.channel) <> Encode.value(post.topic)
  end

  defp encode_text_post(%Post{post_type: @text_post} = post) do
    encode_header(post) <> Encode.value(post.channel) <> Encode.value(post.text)
  end

  defp encode_delete_post(%Post{post_type: @delete_post} = post) do
    encode_header(post) <> encode_hashes(post)
  end

  defp encode_info_post(%Post{post_type: @info_post} = post) do
    encode_header(post) <> encode_info(post)
  end

  defp encode_topic_post(%Post{post_type: @topic_post} = post) do
    encode_header(post) <> encode_topic(post)
  end

  defp encode_join_post(%Post{post_type: @join_post} = post) do
    encode_header(post) <> Encode.value(post.channel)
  end

  defp encode_leave_post(%Post{post_type: @leave_post} = post) do
    encode_header(post) <> Encode.value(post.channel)
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
      2 -> encode_info_post(post)
      3 -> encode_topic_post(post)
      4 -> encode_join_post(post)
      5 -> encode_leave_post(post)
    end
  end

  defimpl Cable.Encoder, for: Message do
    @post_request 2

    defp encode_msg_type(%Message{} = msg), do: Varint.LEB128.encode(msg.msg_type)
    defp encode_ttl(%Message{} = msg), do: Varint.LEB128.encode(msg.ttl)

    defp encode_header(%Message{} = msg) do
      encode_msg_type(msg) <> msg.circuit_id <> msg.req_id
    end

    defp encode_hashes(%Message{msg_type: @post_request} = msg) do
      Varint.LEB128.encode(length(msg.hashes)) <> Enum.join(msg.hashes)
    end

    defp encode_post_request(%Message{} = msg) do
      Encode.value(encode_header(msg) <> encode_ttl(msg) <> encode_hashes(msg))
    end

    def encode(%Message{} = msg, nil) do
      encode(msg)
    end

    def encode(%Message{} = msg) do
      case msg.msg_type do
        2 -> encode_post_request(msg)
      end
    end
  end
end
