# cable.ex

Experimental [cable](https://github.com/cabal-club/cable) protocol implementation in Elixir.

## Usage

### `Post`

Creating a `Post` of type `post/text` (similar methods exist for all other post
types):

```elixir
iex> Cable.Post.new_text_post(public_key, links, timestamp, channel, text)         
%Cable.Post{
  channel: "myco",
  hashes: nil,
  info: nil,
  links: [
    <<80, 73, 208, 137, 166, 80, 170, 137, 108, 178, 94, 195, 82, 88, 101, 59,
      228, 223, 25, 107, 74, 94, 91, 109, 183, 237, 2, 74, 170, 137, 225, 179>>
  ],
  post_type: 0,
  public_key: <<37, 178, 114, 167, 21, 85, 50, 45, 64, 239, 228, 73, 167, 249,
    154, 248, 253, 54, 75, 146, 211, 80, 241, 102, 68, 129, 178, 218, 52, 10, 2,
    208>>,
  signature: nil,
  text: "Spitzenkörper",
  timestamp: 80,
  topic: nil
}
```

Encoding and signing a `Post` type:

```elixir
iex> Cable.encode(post, secret_key)
<<37, 178, 114, 167, 21, 85, 50, 45, 64, 239, 228, 73, 167, 249, 154, 248, 253,
  54, 75, 146, 211, 80, 241, 102, 68, 129, 178, 218, 52, 10, 2, 208, 196, 239,
  209, 58, 116, 239, 180, 152, 204, 191, 108, 241, 143, 151, 248, 250, 211, 65,
  ...>>
```

Encoding can also be done without a secret key, in which case placeholder zero
bytes will be used for the signature:

```elixir
iex> Cable.encode(post)
<<37, 178, 114, 167, 21, 85, 50, 45, 64, 239, 228, 73, 167, 249, 154, 248, 253,
  54, 75, 146, 211, 80, 241, 102, 68, 129, 178, 218, 52, 10, 2, 208, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>
```

Signing an encoded post:

```elixir
iex> Cable.Post.sign(Cable.encode(post), secret_key)
<<37, 178, 114, 167, 21, 85, 50, 45, 64, 239, 228, 73, 167, 249, 154, 248, 253,
  54, 75, 146, 211, 80, 241, 102, 68, 129, 178, 218, 52, 10, 2, 208, 196, 239,
  209, 58, 116, 239, 180, 152, 204, 191, 108, 241, 143, 151, 248, 250, 211, 65,
  ...>>
```

Decoding an encoded `Post` type:

```elixir
iex> Cable.decode_post(encoded_post)
%Cable.Post{
  channel: "myco",
  hashes: nil,
  info: nil,
  links: [
    <<80, 73, 208, 137, 166, 80, 170, 137, 108, 178, 94, 195, 82, 88, 101, 59,
      228, 223, 25, 107, 74, 94, 91, 109, 183, 237, 2, 74, 170, 137, 225, 179>>
  ],
  post_type: 0,
  public_key: <<37, 178, 114, 167, 21, 85, 50, 45, 64, 239, 228, 73, 167, 249,
    154, 248, 253, 54, 75, 146, 211, 80, 241, 102, 68, 129, 178, 218, 52, 10, 2,
    208>>,
  signature: <<196, 239, 209, 58, 116, 239, 180, 152, 204, 191, 108, 241, 143,
    151, 248, 250, 211, 65, 231, 8, 134, 174, 13, 91, 150, 39, 93, 0, 96, 104,
    238, 76, 135, 102, 190, 89, 193, 159, 151, 247, 185, 121, 169, ...>>,
  text: "Spitzenkörper",
  timestamp: 80,
  topic: nil
}
```

### `Message`

Creating a `Message` of type `Channel State Request` (similar methods exist for all other
message types):

```elixir
iex> Cable.Message.new_channel_state_request(<<0, 0, 0, 0>>, <<4, 186, 175, 251>>, 1, "myco", 0)
%Cable.Message{
  cancel_id: nil,
  channel: "myco",
  channels: nil,
  circuit_id: <<0, 0, 0, 0>>,
  future: 0,
  hashes: nil,
  limit: nil,
  msg_type: 5,
  offset: nil,
  posts: nil,
  req_id: <<4, 186, 175, 251>>,
  time_end: nil,
  time_start: nil,
  ttl: 1
}
```

Encoding a `Message` type:

```elixir
iex> Cable.encode(msg)
<<16, 5, 0, 0, 0, 0, 4, 186, 175, 251, 1, 4, 109, 121, 99, 111, 0>>
```

Decoding a `Message` type:

```elixir
iex> Cable.decode_msg(encoded_msg)
%Cable.Message{
  cancel_id: nil,
  channel: "myco",
  channels: nil,
  circuit_id: <<0, 0, 0, 0>>,
  future: 0,
  hashes: nil,
  limit: nil,
  msg_type: 5,
  offset: nil,
  posts: nil,
  req_id: <<4, 186, 175, 251>>,
  time_end: nil,
  time_start: nil,
  ttl: 1
}
```

## Installation

Cable.ex is not yet available in Hex. The package can be installed from the git
repository:

1. Add cable.ex to your list of dependencies in `mix.exs`.

`{:cable_ex, git: "https://codeberg.org/glyph/cable.ex.git", tag: "0.1.0"}`

2. Then, update your dependencies.

`$ mix do deps.get + deps.compile`
