defmodule MessageTest do
  use ExUnit.Case
  doctest Cable

  # Field values sourced from https://github.com/cabal-club/cable.js#examples.

  @circuit_id <<0, 0, 0, 0>>
  @req_id "04baaffb"
  @ttl 1
  @hash_1 "15ed54965515babf6f16be3f96b04b29ecca813a343311dae483691c07ccf4e5"
  @hash_2 "97fc63631c41384226b9b68d9f73ffaaf6eac54b71838687f48f112e30d6db68"
  @hash_3 "9c2939fec6d47b00bafe6967aeff697cf4b5abca01b04ba1b31a7e3752454bfa"
  @cancel_id "31b5c9e1"
  @channel "default"
  @time_start 0
  @time_end 100
  @limit 20
  @future 0
  @offset 0
  @encoded_post "25b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d0abb083ecdca569f064564942ddf1944fbf550dc27ea36a7074be798d753cb029703de77b1a9532b6ca2ec5706e297dce073d6e508eeb425c32df8431e4677805015049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b305500764656661756c74"

  @post_request_encoded "6b020000000004baaffb010315ed54965515babf6f16be3f96b04b29ecca813a343311dae483691c07ccf4e597fc63631c41384226b9b68d9f73ffaaf6eac54b71838687f48f112e30d6db689c2939fec6d47b00bafe6967aeff697cf4b5abca01b04ba1b31a7e3752454bfa"
  @cancel_request_encoded "0e030000000004baaffb0131b5c9e1"
  @channel_time_range_request_encoded "15040000000004baaffb010764656661756c74006414"
  @channel_state_request_encoded "13050000000004baaffb010764656661756c7400"
  @channel_list_request_encoded "0c060000000004baaffb010014"
  @hash_response_encoded "6a000000000004baaffb0315ed54965515babf6f16be3f96b04b29ecca813a343311dae483691c07ccf4e597fc63631c41384226b9b68d9f73ffaaf6eac54b71838687f48f112e30d6db689c2939fec6d47b00bafe6967aeff697cf4b5abca01b04ba1b31a7e3752454bfa"
  @post_response_encoded "9701010000000004baaffb8b0125b272a71555322d40efe449a7f99af8fd364b92d350f1664481b2da340a02d0abb083ecdca569f064564942ddf1944fbf550dc27ea36a7074be798d753cb029703de77b1a9532b6ca2ec5706e297dce073d6e508eeb425c32df8431e4677805015049d089a650aa896cb25ec35258653be4df196b4a5e5b6db7ed024aaa89e1b305500764656661756c7400"

  setup_all do
    alias Cable.Message

    req_id = Base.decode16!(@req_id, case: :lower)
    hash_1 = Base.decode16!(@hash_1, case: :lower)
    hash_2 = Base.decode16!(@hash_2, case: :lower)
    hash_3 = Base.decode16!(@hash_3, case: :lower)
    cancel_id = Base.decode16!(@cancel_id, case: :lower)
    encoded_post = Base.decode16!(@encoded_post, case: :lower)

    post_request = Message.new_post_request(@circuit_id, req_id, @ttl, [hash_1, hash_2, hash_3])
    post_request_encoded = Base.decode16!(@post_request_encoded, case: :lower)

    cancel_request = Message.new_cancel_request(@circuit_id, req_id, @ttl, cancel_id)
    cancel_request_encoded = Base.decode16!(@cancel_request_encoded, case: :lower)

    channel_time_range_request =
      Message.new_channel_time_range_request(
        @circuit_id,
        req_id,
        @ttl,
        @channel,
        @time_start,
        @time_end,
        @limit
      )

    channel_time_range_request_encoded =
      Base.decode16!(@channel_time_range_request_encoded, case: :lower)

    channel_state_request =
      Message.new_channel_state_request(@circuit_id, req_id, @ttl, @channel, @future)

    channel_state_request_encoded = Base.decode16!(@channel_state_request_encoded, case: :lower)

    channel_list_request =
      Message.new_channel_list_request(@circuit_id, req_id, @ttl, @offset, @limit)

    channel_list_request_encoded = Base.decode16!(@channel_list_request_encoded, case: :lower)

    hash_response = Message.new_hash_response(@circuit_id, req_id, [hash_1, hash_2, hash_3])
    hash_response_encoded = Base.decode16!(@hash_response_encoded, case: :lower)

    post_response = Message.new_post_response(@circuit_id, req_id, [encoded_post])
    post_response_encoded = Base.decode16!(@post_response_encoded, case: :lower)

    {:ok,
     post_request: post_request,
     post_request_encoded: post_request_encoded,
     cancel_request: cancel_request,
     cancel_request_encoded: cancel_request_encoded,
     channel_time_range_request: channel_time_range_request,
     channel_time_range_request_encoded: channel_time_range_request_encoded,
     channel_state_request: channel_state_request,
     channel_state_request_encoded: channel_state_request_encoded,
     channel_list_request: channel_list_request,
     channel_list_request_encoded: channel_list_request_encoded,
     hash_response: hash_response,
     hash_response_encoded: hash_response_encoded,
     post_response: post_response,
     post_response_encoded: post_response_encoded}
  end

  test "encodes a post request", state do
    assert Cable.encode(state[:post_request]) == state[:post_request_encoded]
  end

  test "decodes a post request", state do
    assert Cable.decode_msg(state[:post_request_encoded]) == state[:post_request]
  end

  test "encodes a cancel request", state do
    assert Cable.encode(state[:cancel_request]) ==
             state[:cancel_request_encoded]
  end

  test "decodes a cancel request", state do
    assert Cable.decode_msg(state[:cancel_request_encoded]) ==
             state[:cancel_request]
  end

  test "encodes a channel time range request", state do
    assert Cable.encode(state[:channel_time_range_request]) ==
             state[:channel_time_range_request_encoded]
  end

  test "decodes a channel time range request", state do
    assert Cable.decode_msg(state[:channel_time_range_request_encoded]) ==
             state[:channel_time_range_request]
  end

  test "encodes a channel state request", state do
    assert Cable.encode(state[:channel_state_request]) ==
             state[:channel_state_request_encoded]
  end

  test "decodes a channel state request", state do
    assert Cable.decode_msg(state[:channel_state_request_encoded]) ==
             state[:channel_state_request]
  end

  test "encodes a channel list request", state do
    assert Cable.encode(state[:channel_list_request]) ==
             state[:channel_list_request_encoded]
  end

  test "decodes a channel list request", state do
    assert Cable.decode_msg(state[:channel_list_request_encoded]) ==
             state[:channel_list_request]
  end

  test "encodes a hash response", state do
    assert Cable.encode(state[:hash_response]) ==
             state[:hash_response_encoded]
  end

  test "decodes a hash response", state do
    assert Cable.decode_msg(state[:hash_response_encoded]) ==
             state[:hash_response]
  end

  test "encodes a post response", state do
    assert Cable.encode(state[:post_response]) ==
             state[:post_response_encoded]
  end

  test "decodes a post response", state do
    assert Cable.decode_msg(state[:post_response_encoded]) ==
             state[:post_response]
  end
end
