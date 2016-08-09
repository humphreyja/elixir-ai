# Broadcast Hierarchy

### Goal
 - To broadcast a message from a parent process to each of its children as even as possible
 - To receive messages from all children and only listen to replies during a certain timeframe after broadcast

### Accomplished
 - Call genserver, use task and yield with time frame to listen for only a little while

#### To run

```elixir
iex> {:ok, pid} = BroadcastHierarchy.Parent.start_link(10)
iex> BroadcastHierarchy.Parent.broadcast(pid, "test")
#>>> [#PID<0.671.0>, #PID<0.672.0>, #PID<0.676.0>, #PID<0.678.0>, #PID<0.679.0>]
```
