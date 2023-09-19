defmodule Cable.Decode do
  def val_from_varint(data) do
    <<byte::binary-size(1), rest::binary>> = data
    {val, _unparsed} = Varint.LEB128.decode(byte)
    {val, rest}
  end

  def hashes(encoded_hashes) do
    {num_hashes, rest} = num_hashes(encoded_hashes)
    hashes_size = num_hashes * 32
    <<encoded_hashes::binary-size(hashes_size), rest::binary>> = rest
    hashes = for <<chunk::size(32)-binary <- encoded_hashes>>, do: chunk
    {hashes, rest}
  end

  def num_hashes(data) do
    {num_hashes, rest} = val_from_varint(data)
    {num_hashes, rest}
  end
end

alias Cable.Decode

defmodule Cable.Decoder do
  defmodule Post do
    defp decode_public_key(encoded_post) do
      <<public_key::binary-size(32), rest::binary>> = encoded_post
      {public_key, rest}
    end

    defp decode_signature(data) do
      <<signature::binary-size(64), rest::binary>> = data
      {signature, rest}
    end

    defp decode_post_type(data) do
      {post_type, rest} = Decode.val_from_varint(data)
      {post_type, rest}
    end

    defp decode_timestamp(data) do
      {timestamp, rest} = Decode.val_from_varint(data)
      {timestamp, rest}
    end

    defp decode_val(data) do
      {val_len, rest} = Decode.val_from_varint(data)
      <<val::binary-size(val_len), rest::binary>> = rest
      {val, rest}
    end

    defp decode_key_val(key_len, data, state) when key_len > 0 do
      <<key::binary-size(key_len), rest::binary>> = data
      {val, rest} = decode_val(rest)
      {key_len, rest} = Decode.val_from_varint(rest)
      decode_key_val(key_len, rest, [{key, val} | state])
    end

    defp decode_key_val(0, rest, state) do
      {state, rest}
    end

    defp decode_info(data) do
      {key_len, rest} = Decode.val_from_varint(data)
      decode_key_val(key_len, rest, [])
    end

    defp decode_text_post(header, body) do
      {channel, rest} = decode_val(body)
      {text, _rest} = decode_val(rest)
      %{header | channel: channel, text: text}
    end

    defp decode_delete_post(header, body) do
      {hashes, _rest} = Decode.hashes(body)
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

    defp decode_join_or_leave_post(header, body) do
      {channel, _rest} = decode_val(body)
      %{header | channel: channel}
    end

    defp decode_header(encoded_post) do
      {public_key, rest} = decode_public_key(encoded_post)
      {signature, rest} = decode_signature(rest)
      {links, rest} = Decode.hashes(rest)
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
        4 -> decode_join_or_leave_post(header, body)
        5 -> decode_join_or_leave_post(header, body)
      end
    end
  end

  defmodule Message do
    defp decode_msg_len(data) do
      {msg_len, rest} = Decode.val_from_varint(data)
      {msg_len, rest}
    end

    defp decode_msg_type(data) do
      {msg_type, rest} = Decode.val_from_varint(data)
      {msg_type, rest}
    end

    defp decode_ttl(data) do
      {ttl, rest} = Decode.val_from_varint(data)
      {ttl, rest}
    end

    defp decode_circuit_id(encoded_msg) do
      <<circuit_id::binary-size(4), rest::binary>> = encoded_msg
      {circuit_id, rest}
    end

    defp decode_req_id(encoded_msg) do
      <<circuit_id::binary-size(4), rest::binary>> = encoded_msg
      {circuit_id, rest}
    end

    defp decode_header(encoded_msg) do
      {_msg_len, rest} = decode_msg_len(encoded_msg)
      {msg_type, rest} = decode_msg_type(rest)
      {circuit_id, rest} = decode_circuit_id(rest)
      {req_id, rest} = decode_req_id(rest)
      {ttl, rest} = decode_ttl(rest)
      header = Cable.Message.new(msg_type, circuit_id, req_id, ttl)
      {header, rest}
    end

    defp decode_post_request(header, body) do
      {hashes, _rest} = Decode.hashes(body)
      %{header | hashes: hashes}
    end

    def decode(encoded_msg) do
      {header, body} = decode_header(encoded_msg)

      case header.msg_type do
        2 -> decode_post_request(header, body)
      end
    end
  end
end
