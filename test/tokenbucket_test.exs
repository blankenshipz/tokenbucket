defmodule TokenBucketTest do
  use ExUnit.Case

  describe "removing from the bucket" do
    test "if a token is available" do
      state = [cadence: 0, capacity: 1, bucket: 1]

      {:reply, :ok, _} = TokenBucket.handle_call(:take, self(), state)
    end

    test "if a token is not available" do
      state = [cadence: 0, capacity: 1, bucket: 0]

      {:reply, :empty, _} = TokenBucket.handle_call(:take, self(), state)
    end
  end

  describe "adding to the bucket" do
    test "if the bucket is at capacity" do
      state = [cadence: 0, capacity: 1, bucket: 1]

      {:noreply, actual} = TokenBucket.handle_info(:tick, state)

      # no increase
      assert(actual[:bucket] == state[:bucket])
    end

    test "if the bucket is not at capacity" do
      state = [cadence: 0, capacity: 1, bucket: 0]

      {:noreply, actual} = TokenBucket.handle_info(:tick, state)

      # increase by 1
      assert(actual[:bucket] == state[:bucket] + 1)
    end
  end
end
