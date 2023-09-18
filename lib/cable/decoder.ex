defmodule Cable.Decoder do
  defp decode_hashes(encoded_hashes) do
    {num_hashes, rest} = decode_num_hashes(encoded_hashes)
    hashes_size = num_hashes * 32
    <<encoded_hashes::binary-size(hashes_size), rest::binary>> = rest
    hashes = for <<chunk::size(32)-binary <- encoded_hashes>>, do: chunk
    {hashes, rest}
  end

  defp decode_num_hashes(data) do
    {num_hashes, rest} = decode_len_from_byte(data)
    {num_hashes, rest}
  end

  defp decode_public_key(encoded_post) do
    <<public_key::binary-size(32), rest::binary>> = encoded_post
    {public_key, rest}
  end

  defp decode_signature(data) do
    <<signature::binary-size(64), rest::binary>> = data
    {signature, rest}
  end

  defp decode_post_type(data) do
    {post_type, rest} = decode_len_from_byte(data)
    {post_type, rest}
  end

  defp decode_timestamp(data) do
    {timestamp, rest} = decode_len_from_byte(data)
    {timestamp, rest}
  end

  defp decode_val(data) do
    {val_len, rest} = decode_len_from_byte(data)
    <<val::binary-size(val_len), rest::binary>> = rest
    {val, rest}
  end

  defp decode_key_val(key_len, data, state) when key_len > 0 do
    <<key::binary-size(key_len), rest::binary>> = data
    {val, rest} = decode_val(rest)
    {key_len, rest} = decode_len_from_byte(rest)
    decode_key_val(key_len, rest, [{key, val} | state])
  end

  defp decode_key_val(0, rest, state) do
    {state, rest}
  end

  defp decode_len_from_byte(data) do
    <<byte::binary-size(1), rest::binary>> = data
    {len, _unparsed} = Varint.LEB128.decode(byte)
    {len, rest}
  end

  defp decode_info(data) do
    {key_len, rest} = decode_len_from_byte(data)
    decode_key_val(key_len, rest, [])
  end

  defp decode_text_post(header, body) do
    {channel, rest} = decode_val(body)
    {text, _rest} = decode_val(rest)
    %{header | channel: channel, text: text}
  end

  defp decode_delete_post(header, body) do
    {hashes, _rest} = decode_hashes(body)
    %{header | hashes: hashes}
  end

  defp decode_info_post(header, body) do
    {info, _rest} = decode_info(body)
    %{header | info: info}
  end

  defp decode_topic_post(header, body) do
    {channel, rest} = decode_val(body)
    {topic, _rest} = decode_val(rest)
    %{header | channel: channel, topic: topic}
  end

  defp decode_join_post(header, body) do
    {channel, _rest} = decode_val(body)
    %{header | channel: channel}
  end

  defp decode_header(encoded_post) do
    {public_key, rest} = decode_public_key(encoded_post)
    {signature, rest} = decode_signature(rest)
    {links, rest} = decode_hashes(rest)
    {post_type, rest} = decode_post_type(rest)
    {timestamp, rest} = decode_timestamp(rest)
    header = Cable.Post.new(public_key, signature, links, post_type, timestamp)
    {header, rest}
  end

  def decode(encoded_post) do
    {header, body} = decode_header(encoded_post)

    case header.post_type do
      0 -> decode_text_post(header, body)
      1 -> decode_delete_post(header, body)
      2 -> decode_info_post(header, body)
      3 -> decode_topic_post(header, body)
      4 -> decode_join_post(header, body)
    end
  end
end
