defmodule CableTest do
  use ExUnit.Case
  doctest Cable

  # Field values sourced from https://github.com/cabal-club/cable.js#examples.

  @public_key "25b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d0"
  @secret_key "f12a0b72a720f9ce6898a1f4c685bee4cc838102143db98f467c5512a726e69225b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d0"
  @post_hash "5049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b3"
  @timestamp 80
  @channel "default"
  @text "h€llo world"
  @hash_1 "15ed54965515babf6f16be3f96b04b29ecca813a343311dae483691c07ccf4e5"
  @hash_2 "97fc63631c41384226b9b68d9f73ffaaf6eac54b71838687f48f112e30d6db68"
  @hash_3 "9c2939fec6d47b00bafe6967aeff697cf4b5abca01b04ba1b31a7e3752454bfa"

  @text_post_signature "6725733046b35fa3a7e8dc0099a2b3dff10d3fd8b0f6da70d094352e3f5d27a8bc3f5586cf0bf71befc22536c3c50ec7b1d64398d43c3f4cde778e579e88af05"
  @delete_post_signature "affe77e3b3156cda7feea042269bb7e93f5031662c70610d37baa69132b4150c18d67cb2ac24fb0f9be0a6516e53ba2f3bbc5bd8e7a1bff64d9c78ce0c2e4205"

  @text_post_encoded "25b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d06725733046b35fa3a7e8dc0099a2b3dff10d3fd8b0f6da70d094352e3f5d27a8bc3f5586cf0bf71befc22536c3c50ec7b1d64398d43c3f4cde778e579e88af05015049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b300500764656661756c740d68e282ac6c6c6f20776f726c64"
  @delete_post_encoded "25b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d0affe77e3b3156cda7feea042269bb7e93f5031662c70610d37baa69132b4150c18d67cb2ac24fb0f9be0a6516e53ba2f3bbc5bd8e7a1bff64d9c78ce0c2e4205015049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b301500315ed54965515babf6f16be3f96b04b29ecca813a343311dae483691c07ccf4e597fc63631c41384226b9b68d9f73ffaaf6eac54b71838687f48f112e30d6db689c2939fec6d47b00bafe6967aeff697cf4b5abca01b04ba1b31a7e3752454bfa"

  setup_all do
    alias Cable.Post

    public_key = Base.decode16!(@public_key, case: :lower)
    post_hash = Base.decode16!(@post_hash, case: :lower)
    secret_key = Base.decode16!(@secret_key, case: :lower)
    hash_1 = Base.decode16!(@hash_1, case: :lower)
    hash_2 = Base.decode16!(@hash_2, case: :lower)
    hash_3 = Base.decode16!(@hash_3, case: :lower)

    text_post = Post.new_text_post(public_key, [post_hash], @timestamp, @channel, @text)
    text_post_encoded = Base.decode16!(@text_post_encoded, case: :lower)
    text_post_signature = Base.decode16!(@text_post_signature, case: :lower)

    delete_post =
      Post.new_delete_post(public_key, [post_hash], @timestamp, [hash_1, hash_2, hash_3])

    delete_post_encoded = Base.decode16!(@delete_post_encoded, case: :lower)
    delete_post_signature = Base.decode16!(@delete_post_signature, case: :lower)

    {:ok,
     secret_key: secret_key,
     text_post: text_post,
     text_post_encoded: text_post_encoded,
     text_post_signature: text_post_signature,
     delete_post: delete_post,
     delete_post_encoded: delete_post_encoded,
     delete_post_signature: delete_post_signature}
  end

  test "encodes and signs a text post", state do
    assert Cable.encode(state[:text_post], state[:secret_key]) == state[:text_post_encoded]
  end

  test "decodes a text post", state do
    signed_post = %{state[:text_post] | signature: state[:text_post_signature]}
    assert Cable.decode(state[:text_post_encoded]) == signed_post
  end

  test "encodes and signs a delete post", state do
    assert Cable.encode(state[:delete_post], state[:secret_key]) == state[:delete_post_encoded]
  end

  test "decodes a delete post", state do
    signed_post = %{state[:delete_post] | signature: state[:delete_post_signature]}
    assert Cable.decode(state[:delete_post_encoded]) == signed_post
  end
end
