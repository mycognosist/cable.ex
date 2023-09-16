defmodule Cable.Post do
  @moduledoc """
  Create a text post (with or without supplied fields):

  `text_post = Cable.Post.new_text_post()`
  `text_post = Cable.Post.new_text_post(public_key, links, timestamp, channel, text)`
  """

  @text_post_type 0

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
          info: map(),
          topic: String.t()
        }

  alias Cable.Post

  def new(), do: %Post{}

  def new(public_key, signature, links, post_type, timestamp) do
    %Post{
      public_key: public_key,
      signature: signature,
      links: links,
      post_type: post_type,
      timestamp: timestamp
    }
  end

  def new_text_post(), do: %Post{post_type: @text_post_type}

  def new_text_post(public_key, links, timestamp, channel, text) do
    %Post{
      public_key: public_key,
      links: links,
      timestamp: timestamp,
      channel: channel,
      text: text,
      post_type: @text_post_type
    }
  end

  def insert_signature(%Post{} = post, signature) do
    %{post | signature: signature}
  end

  def insert_signature(post, signature) when is_binary(post) do
    <<public_key::binary-size(32), rest::binary>> = post
    <<_head::binary-size(64), rest::binary>> = rest
    public_key <> signature <> rest
  end

  def sign_post(encoded_post, secret_key) do
    <<public_key::binary-size(32), rest::binary>> = encoded_post
    <<_head::binary-size(64), rest::binary>> = rest
    signature = Cable.Cryptography.sign(rest, secret_key)
    public_key <> signature <> rest
  end
end
