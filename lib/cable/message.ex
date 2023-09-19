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
          future: integer(),
          offset: integer(),
          posts: [[binary()]],
          channels: [[String.t()]]
        }

  alias Cable.Message

  def new(), do: %Message{}

  def new(
        msg_type,
        circuit_id,
        req_id
      ) do
    %Message{
      msg_type: msg_type,
      circuit_id: circuit_id,
      req_id: req_id
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

  def new_cancel_request(), do: %Message{msg_type: @cancel_request}

  def new_cancel_request(
        circuit_id,
        req_id,
        ttl,
        cancel_id
      ) do
    %Message{
      msg_type: @cancel_request,
      circuit_id: circuit_id,
      req_id: req_id,
      ttl: ttl,
      cancel_id: cancel_id
    }
  end

  def new_channel_time_range_request(), do: %Message{msg_type: @channel_time_range_request}

  def new_channel_time_range_request(
        circuit_id,
        req_id,
        ttl,
        channel,
        time_start,
        time_end,
        limit
      ) do
    %Message{
      msg_type: @channel_time_range_request,
      circuit_id: circuit_id,
      req_id: req_id,
      ttl: ttl,
      channel: channel,
      time_start: time_start,
      time_end: time_end,
      limit: limit
    }
  end

  def new_channel_state_request(), do: %Message{msg_type: @channel_state_request}

  def new_channel_state_request(
        circuit_id,
        req_id,
        ttl,
        channel,
        future
      ) do
    %Message{
      msg_type: @channel_state_request,
      circuit_id: circuit_id,
      req_id: req_id,
      ttl: ttl,
      channel: channel,
      future: future
    }
  end

  def new_channel_list_request(), do: %Message{msg_type: @channel_list_request}

  def new_channel_list_request(
        circuit_id,
        req_id,
        ttl,
        offset,
        limit
      ) do
    %Message{
      msg_type: @channel_list_request,
      circuit_id: circuit_id,
      req_id: req_id,
      ttl: ttl,
      offset: offset,
      limit: limit
    }
  end

  def new_hash_response(), do: %Message{msg_type: @hash_response}

  def new_hash_response(
        circuit_id,
        req_id,
        hashes
      ) do
    %Message{
      msg_type: @hash_response,
      circuit_id: circuit_id,
      req_id: req_id,
      hashes: hashes
    }
  end
end
