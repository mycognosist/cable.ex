# https://blog.swwomm.com/2020/09/elixir-ed25519-signatures-with-enacl.html

defmodule Cable.Cryptography do
  @doc """
  Generate an Ed25519 public-private key pair using sha512.
  """
  def generate_key_pair do
    :enacl.sign_keypair()
  end

  @doc """
  Sign a message with the given secret key.
  """
  def sign(message, secret_key) do
    :enacl.sign_detached(message, secret_key)
  end

  @doc """
  Validate a signature for the given message and public key.
  """
  def valid_signature?(signature, message, public_key) do
    :enacl.sign_verify_detached(signature, message, public_key)
  end

  @doc """
  Hash a message with the given secret key.
  """
  def hash(message, secret_key) do
    # Output size is set to 32 bytes (Blake2b-256).
    Blake2.hash2b(message, 32, secret_key)
  end
end
