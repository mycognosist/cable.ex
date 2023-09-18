defmodule Cable.Message do
  @hash_response 0
  @post_response 1
  @post_request 2
  @cancel_request 3
  @channel_time_range_request 4
  @channel_state_request 5
  @channel_list_request 6
  @channel_list_response 7

  defstruct msg_type: nil,
            circuit_id: nil,
            req_id: nil,
            ttl: nil,
            hashes: nil,
            cancel_id: nil,
            channel: nil,
            time_start: nil,
            time_end: nil,
            limit: nil,
            future: nil,
            offset: nil,
            posts: nil,
            channels: nil

  @type t :: %__MODULE__{
          msg_type: integer(),
          circuit_id: [[binary()]],
          req_id: binary(),
          ttl: integer(),
          hashes: [[binary()]],
          cancel_id: binary(),
          channel: String.t(),
          time_start: integer(),
          time_end: integer(),
          limit: integer(),
          future: boolean(),
          offset: integer(),
          posts: [[binary()]],
          channels: [[String.t()]]
        }

  alias Cable.Message

  def new(), do: %Message{}

  def new(
        msg_type,
        circuit_id,
        req_id,
        ttl,
        hashes,
        cancel_id,
        channel,
        time_start,
        time_end,
        limit,
        future,
        offset,
        posts,
        channels
      ) do
    %Message{
      msg_type: msg_type,
      circuit_id: circuit_id,
      req_id: req_id,
      ttl: ttl,
      hashes: hashes,
      cancel_id: cancel_id,
      channel: channel,
      time_start: time_start,
      time_end: time_end,
      limit: limit,
      future: future,
      offset: offset,
      posts: posts,
      channels: channels
    }
  end

  def new_post_request(), do: %Message{msg_type: @post_request}

  def new_post_request(
        circuit_id,
        req_id,
        ttl,
        hashes
      ) do
    %Message{
      msg_type: @post_request,
      circuit_id: circuit_id,
      req_id: req_id,
      ttl: ttl,
      hashes: hashes
    }
  end
end
