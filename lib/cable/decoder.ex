defmodule Cable.Decoder do
  defp decode_hashes(encoded_hashes) do
    {num_hashes, rest} = decode_num_hashes(encoded_hashes)
    hashes_size = num_hashes * 32
    <<encoded_hashes::binary-size(hashes_size), rest::binary>> = rest
    hashes = for <<chunk::size(32)-binary <- encoded_hashes>>, do: chunk
    {hashes, rest}
  end

  defp decode_num_hashes(data) do
    <<hashes_byte::binary-size(1), rest::binary>> = data
    {num_hashes, _unparsed} = Varint.LEB128.decode(hashes_byte)
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
    <<post_type_byte::binary-size(1), rest::binary>> = data
    {post_type, _unparsed} = Varint.LEB128.decode(post_type_byte)
    {post_type, rest}
  end

  defp decode_timestamp(data) do
    <<timestamp_byte::binary-size(1), rest::binary>> = data
    {timestamp, _unparsed} = Varint.LEB128.decode(timestamp_byte)
    {timestamp, rest}
  end

  defp decode_channel(data) do
    <<channel_byte::binary-size(1), rest::binary>> = data
    {channel_len, _unparsed} = Varint.LEB128.decode(channel_byte)
    <<channel::binary-size(channel_len), rest::binary>> = rest
    {channel, rest}
  end

  defp decode_text(data) do
    <<text_byte::binary-size(1), rest::binary>> = data
    {text_len, _unparsed} = Varint.LEB128.decode(text_byte)
    <<text::binary-size(text_len), rest::binary>> = rest
    {text, rest}
  end

  defp decode_text_post(signed_post, data) do
    {channel, rest} = decode_channel(data)
    {text, _rest} = decode_text(rest)
    %{signed_post | channel: channel, text: text}
  end

  defp decode_delete_post(signed_post, data) do
    {hashes, _rest} = decode_hashes(data)
    %{signed_post | hashes: hashes}
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
    end
  end
end
