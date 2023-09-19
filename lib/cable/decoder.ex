defmodule Cable.Decode do
  def val(data) do
    {val_len, rest} = val_from_varint(data)
    <<val::binary-size(val_len), rest::binary>> = rest
    {val, rest}
  end

  def val_from_varint(data), do: Varint.LEB128.decode(data)

  def hashes(encoded_hashes) do
    {num_hashes, rest} = num_hashes(encoded_hashes)
    hashes_size = num_hashes * 32
    <<encoded_hashes::binary-size(hashes_size), rest::binary>> = rest
    hashes = for <<chunk::size(32)-binary <- encoded_hashes>>, do: chunk
    {hashes, rest}
  end

  def num_hashes(data), do: val_from_varint(data)
end

alias Cable.Decode

defmodule Cable.Decoder do
  defmodule Post do
    defp decode_post_type(data), do: Decode.val_from_varint(data)
    defp decode_timestamp(data), do: Decode.val_from_varint(data)

    defp decode_public_key(encoded_post) do
      <<public_key::binary-size(32), rest::binary>> = encoded_post
      {public_key, rest}
    end

    defp decode_signature(data) do
      <<signature::binary-size(64), rest::binary>> = data
      {signature, rest}
    end

    defp decode_key_val(0, rest, state), do: {state, rest}

    defp decode_key_val(key_len, data, state) when key_len > 0 do
      <<key::binary-size(key_len), rest::binary>> = data
      {val, rest} = Decode.val(rest)
      {key_len, rest} = Decode.val_from_varint(rest)
      decode_key_val(key_len, rest, [{key, val} | state])
    end

    defp decode_info(data) do
      {key_len, rest} = Decode.val_from_varint(data)
      decode_key_val(key_len, rest, [])
    end

    defp decode_text_post(header, body) do
      {channel, rest} = Decode.val(body)
      {text, _rest} = Decode.val(rest)
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
      {channel, rest} = Decode.val(body)
      {topic, _rest} = Decode.val(rest)
      %{header | channel: channel, topic: topic}
    end

    defp decode_join_or_leave_post(header, body) do
      {channel, _rest} = Decode.val(body)
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
    defp decode_msg_len(data), do: Decode.val_from_varint(data)
    defp decode_msg_type(data), do: Decode.val_from_varint(data)
    defp decode_ttl(data), do: Decode.val_from_varint(data)
    defp decode_channel(encoded_msg), do: Decode.val(encoded_msg)
    defp decode_time_start_or_end(encoded_msg), do: Decode.val_from_varint(encoded_msg)
    defp decode_limit(data), do: Decode.val_from_varint(data)
    defp decode_future(encoded_msg), do: Decode.val_from_varint(encoded_msg)
    defp decode_offset(encoded_msg), do: Decode.val_from_varint(encoded_msg)

    defp decode_circuit_id(encoded_msg) do
      <<circuit_id::binary-size(4), rest::binary>> = encoded_msg
      {circuit_id, rest}
    end

    defp decode_req_id(encoded_msg) do
      <<req_id::binary-size(4), rest::binary>> = encoded_msg
      {req_id, rest}
    end

    defp decode_post(0, rest, state), do: {state, rest}

    defp decode_post(post_len, data, state) when post_len > 0 do
      <<post::binary-size(post_len), rest::binary>> = data
      {post_len, rest} = Decode.val_from_varint(rest)
      decode_post(post_len, rest, [post | state])
    end

    defp decode_posts(data) do
      {post_len, rest} = Decode.val_from_varint(data)
      decode_post(post_len, rest, [])
    end

    defp decode_hash_response(header, body) do
      {hashes, _rest} = Decode.hashes(body)
      %{header | hashes: hashes}
    end

    defp decode_post_response(header, body) do
      {posts, _rest} = decode_posts(body)
      %{header | posts: posts}
    end

    defp decode_post_request(header, body) do
      {ttl, rest} = decode_ttl(body)
      {hashes, _rest} = Decode.hashes(rest)
      %{header | ttl: ttl, hashes: hashes}
    end

    defp decode_cancel_request(header, body) do
      {ttl, rest} = decode_ttl(body)
      {cancel_id, _rest} = decode_req_id(rest)
      %{header | ttl: ttl, cancel_id: cancel_id}
    end

    defp decode_channel_time_range_request(header, body) do
      {ttl, rest} = decode_ttl(body)
      {channel, rest} = decode_channel(rest)
      {time_start, rest} = decode_time_start_or_end(rest)
      {time_end, rest} = decode_time_start_or_end(rest)
      {limit, _rest} = decode_limit(rest)

      %{
        header
        | ttl: ttl,
          channel: channel,
          time_start: time_start,
          time_end: time_end,
          limit: limit
      }
    end

    defp decode_channel_state_request(header, body) do
      {ttl, rest} = decode_ttl(body)
      {channel, rest} = decode_channel(rest)
      {future, _rest} = decode_future(rest)
      %{header | ttl: ttl, channel: channel, future: future}
    end

    defp decode_channel_list_request(header, body) do
      {ttl, rest} = decode_ttl(body)
      {offset, rest} = decode_offset(rest)
      {limit, _rest} = decode_limit(rest)
      %{header | ttl: ttl, offset: offset, limit: limit}
    end

    defp decode_header(encoded_msg) do
      {_msg_len, rest} = decode_msg_len(encoded_msg)
      {msg_type, rest} = decode_msg_type(rest)
      {circuit_id, rest} = decode_circuit_id(rest)
      {req_id, rest} = decode_req_id(rest)
      header = Cable.Message.new(msg_type, circuit_id, req_id)
      {header, rest}
    end

    def decode(encoded_msg) do
      {header, body} = decode_header(encoded_msg)

      case header.msg_type do
        0 -> decode_hash_response(header, body)
        1 -> decode_post_response(header, body)
        2 -> decode_post_request(header, body)
        3 -> decode_cancel_request(header, body)
        4 -> decode_channel_time_range_request(header, body)
        5 -> decode_channel_state_request(header, body)
        6 -> decode_channel_list_request(header, body)
      end
    end
  end
end
