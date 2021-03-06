defmodule TokenBucket do
  use GenServer
  @moduledoc """
  Documentation for `TokenBucket`.
  """

  def take(bucket) do
    GenServer.call(bucket, :take)
  end

  def await(bucket) do
    case GenServer.call(bucket, :take) do
      :ok -> :ok
      :empty -> await(bucket)
    end
  end

  def start_link(opts) do
    {gen_opts, state} = get_opts(opts)

    { :ok, bucket } = Agent.start_link(fn -> 0 end)
    { :ok, mutex } = Mutex.start_link()

    state = state ++ [ bucket: bucket, mutex: mutex ]

    GenServer.start_link(__MODULE__, state, gen_opts)
  end

  @gen_opts [:debug, :name, :timeout, :spawn_opt, :hibernate_after]

  defp get_opts(opts) when is_atom(opts),
    do: get_opts(name: opts)

  defp get_opts(opts), do: opts |> Keyword.split(@gen_opts)

  def init(state) do
    Process.send_after(self(), :tick, state[:cadence])

    { :ok, state}
  end

  def handle_call(:take, _from, state) do
    lock = Mutex.await(state[:mutex], state[:name])
    count = Agent.get(state[:bucket], &(&1))

    reply = if count > 0 do
      Agent.update(state[:bucket], &(&1-1))

      { :reply, :ok, state}
    else
      { :reply, :empty, state}
    end

    Mutex.release(state[:mutex], lock)

    reply
  end

  def handle_info(:tick, state) do
    lock = Mutex.await(state[:mutex], state[:name])

    Agent.update(state[:bucket], &(if &1 < state[:capacity], do: &1+1, else: &1))

    Mutex.release(state[:mutex], lock)

    Process.send_after(self(), :tick, state[:cadence])

    { :noreply, state}
  end
end
