defmodule Cable.Post do
  @text_post 0
  @delete_post 1
  @info_post 2
  @topic_post 3
  @join_post 4
  @leave_post 5

  defstruct public_key: nil,
            signature: nil,
            links: nil,
            timestamp: nil,
            post_type: nil,
            channel: nil,
            text: nil,
            hashes: nil,
            info: nil,
            topic: nil

  @type t :: %__MODULE__{
          public_key: binary(),
          signature: binary(),
          links: [[binary()]],
          timestamp: integer(),
          post_type: integer(),
          channel: String.t(),
          text: String.t(),
          hashes: [[binary()]],
          info: [[tuple()]],
          topic: String.t()
        }

  alias Cable.{Post, Cryptography}

  def new(), do: %Post{}

  @doc """
  Construct a new `Post` type with the given header parameters.
  """
  def new(public_key, signature, links, post_type, timestamp) do
    %Post{
      public_key: public_key,
      signature: signature,
      links: links,
      post_type: post_type,
      timestamp: timestamp
    }
  end

  def new_text_post(), do: %Post{post_type: @text_post}

  def new_text_post(public_key, links, timestamp, channel, text) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      channel: channel,
      text: text,
      post_type: @text_post
    }
  end

  def new_delete_post(), do: %Post{post_type: @delete_post}

  def new_delete_post(public_key, links, timestamp, hashes) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      hashes: hashes,
      post_type: @delete_post
    }
  end

  def new_info_post(), do: %Post{post_type: @info_post}

  def new_info_post(public_key, links, timestamp, info) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      info: info,
      post_type: @info_post
    }
  end

  def new_topic_post(), do: %Post{post_type: @topic_post}

  def new_topic_post(public_key, links, timestamp, channel, topic) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      channel: channel,
      topic: topic,
      post_type: @topic_post
    }
  end

  def new_join_post(), do: %Post{post_type: @join_post}

  def new_join_post(public_key, links, timestamp, channel) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      channel: channel,
      post_type: @join_post
    }
  end

  def new_leave_post(), do: %Post{post_type: @leave_post}

  def new_leave_post(public_key, links, timestamp, channel) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      channel: channel,
      post_type: @leave_post
    }
  end

  @doc """
  If passed a post as the first paramter, set the value of the signature field
  to the given signature.

  If passed an encoded post as the first parameter, insert a signature into an
  encoded post - replacing any previous signature or placeholder bytes.
  """
  def insert_signature(%Post{} = post, signature) do
    %{post | signature: signature}
  end

  def insert_signature(encoded_post, signature) when is_binary(encoded_post) do
    <<public_key::binary-size(32), rest::binary>> = encoded_post
    <<_head::binary-size(64), rest::binary>> = rest
    public_key <> signature <> rest
  end

  @doc """
  Sign an encoded post and insert the signature.
  """
  def sign_post(encoded_post, secret_key) do
    <<public_key::binary-size(32), rest::binary>> = encoded_post
    <<_head::binary-size(64), rest::binary>> = rest
    signature = Cryptography.sign(rest, secret_key)
    public_key <> signature <> rest
  end

  @doc """
  Verify that the given encoded post includes a valid signature.
  """
  def valid_signature?(encoded_post) do
    if byte_size(encoded_post) < 96 do
      false
    end

    <<public_key::binary-size(32), signature::binary-size(64), rest::binary>> = encoded_post
    Cryptography.valid_signature?(signature, rest, public_key)
  end

  @doc """
  Verify that the given post has been signed.
  """
  def is_signed?(post) do
    is_signature?(post.signature)
  end

  defp is_signature?(nil), do: false

  defp is_signature?(signature) when is_binary(signature) do
    signature = :binary.bin_to_list(signature)
    Enum.any?(signature, fn byte -> byte != 0 end)
  end
end
