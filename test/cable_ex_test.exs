# Reference: https://github.com/folz/bento/blob/master/test/bento_test.exs

defmodule CableTest do
  use ExUnit.Case
  doctest Cable

  @public_key "25b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d0"
  @hash "5049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b3"
  @signature "6725733046b35fa3a7e8dc0099a2b3dff10d3fd8b0f6da70d094352e3f5d27a8bc3f5586cf0bf71befc22536c3c50ec7b1d64398d43c3f4cde778e579e88af05"
  @timestamp 80
  @channel "default"
  @text "h€llo world"

  @encoded_text_post "25b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d06725733046b35fa3a7e8dc0099a2b3dff10d3fd8b0f6da70d094352e3f5d27a8bc3f5586cf0bf71befc22536c3c50ec7b1d64398d43c3f4cde778e579e88af05015049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b300500764656661756c740d68e282ac6c6c6f20776f726c64"

  setup_all do
    public_key = Base.decode16!(@public_key, case: :lower)
    hash = Base.decode16!(@hash, case: :lower)

    post = Cable.Post.new_text_post(public_key, [hash], @timestamp, @channel, @text)
    {:ok, text_post: post}
  end

  test "encodes a text post", state do
    expected_encoding = Base.decode16!(@encoded_text_post, case: :lower)
    encoded_post = Cable.Encoder.encode(state[:text_post])
    signature = Base.decode16!(@signature, case: :lower)

    assert Cable.Post.insert_signature(encoded_post, signature) == expected_encoding
  end
end
