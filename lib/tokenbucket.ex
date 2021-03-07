defmodule TokenBucket do
  use GenServer

  @moduledoc """
  TokenBucket is a simple implementation of the Token Bucket Algorithm;
  A new bucket is initialized with a cadence and a capacity; in the
  background the GenServer populates the bucket with tokens by calling
  itself with `:tick` based on the cadence

  The capacity of the bucket represents the size of the burst; meaning
  that if the bucket were at capacity this is the number of near
  parallel token removals that could happen.

  If you want a bucket with no burst simply define a capacity of (1)
  """

  @doc """
  Non-blocking call to remove one token from the bucket. Returns `:ok`
  if the operation were succesful and `:empty` if there were no tokens
  available

  ## Examples
      iex> TokenBucket.take(MyBucket)
      :ok

      iex> TokenBucket.take(MyBucket)
      :empty
  """
  def take(bucket) do
    GenServer.call(bucket, :take)
  end

  @doc """
  Blocking call to remove one token from the bucket. Returns `:ok` when the operation completes

  ## Examples
      iex> TokenBucket.await(MyBucket)
      :ok
  """
  def await(bucket) do
    case GenServer.call(bucket, :take) do
      :ok -> :ok
      :empty -> await(bucket)
    end
  end

  @doc """
  Starts a TokenBucket with linking under a supervision tree; the options must include `:capacity` and `:cadence`; also accepts options for the GenServer
  """
  def start_link(opts) do
    {gen_opts, state} = get_opts(opts)

    state = state ++ [bucket: 0]

    GenServer.start_link(__MODULE__, state, gen_opts)
  end

  @gen_opts [:debug, :name, :timeout, :spawn_opt, :hibernate_after]

  defp get_opts(opts) when is_atom(opts),
    do: get_opts(name: opts)

  defp get_opts(opts), do: opts |> Keyword.split(@gen_opts)

  def init(state) do
    Process.send_after(self(), :tick, state[:cadence])

    {:ok, state}
  end

  def handle_call(:take, _from, state) do
    reply =
      if state[:bucket] > 0 do
        {:reply, :ok, Keyword.update!(state, :bucket, &(&1 - 1))}
      else
        {:reply, :empty, state}
      end

    reply
  end

  def handle_info(:tick, state) do
    state =
      Keyword.update!(
        state,
        :bucket,
        &if(&1 < state[:capacity], do: &1 + 1, else: &1)
      )

    Process.send_after(self(), :tick, state[:cadence])

    {:noreply, state}
  end
end
